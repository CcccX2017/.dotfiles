#!/usr/bin/env bash
#
# bootstrap.sh —— macOS 新机 / 重装系统后的一键配置脚本
#
#   ./bootstrap.sh                  交互式：菜单选择 MacPorts 或 Homebrew
#   ./bootstrap.sh -m macports -y   全自动，不提问
#   ./bootstrap.sh -n               预演（dry-run），只打印将执行的操作
#
# 脚本做四件事：
#   1. 按你选择的包管理器安装命令行工具（两者用同一份清单，自动换算包名）
#   2. 用 rcm 把 ~/.dotfiles 里的配置软链到主目录
#   3. 装齐 zsh 生态（oh-my-zsh / powerlevel10k / 插件）、nvm + Node + pnpm、tmux 插件
#   4. 可选：从备份目录恢复 iTerm2 / Alfred / Joplin / kitty 的配置
#
# 设计原则：可重复执行（幂等）。已经装好的会跳过，已经软链的不会重复处理。

set -euo pipefail

VERSION="1.0.0"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.dotfiles-backup-$STAMP"
LOG_FILE="$HOME/.dotfiles-bootstrap.log"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-bootstrap.XXXXXX")"

# ---------------------------------------------------------------------------
# 默认参数（可被命令行覆盖）
# ---------------------------------------------------------------------------
MANAGER=""            # macports | homebrew | none
ASSUME_YES=0
DRY_RUN=0
DO_PACKAGES=1
DO_APPS=1
DO_DOTFILES=1
DO_NODE=1
DO_TMUX=1
DO_SSH=1
DO_RESTORE=1
DO_DEFAULTS=0
RESTORE_DIR=""
EXTRA_PKGS=""
NODE_VERSION="${NODE_VERSION:-26}"
NVM_VERSION="${NVM_VERSION:-v0.40.8}"
GIT_NAME="${GIT_NAME:-}"
GIT_EMAIL="${GIT_EMAIL:-}"

SUDO_KEEPALIVE_PID=""

# ---------------------------------------------------------------------------
# 输出
# ---------------------------------------------------------------------------
if [ -t 1 ] && [ "${TERM:-dumb}" != "dumb" ]; then
  C_RESET='\033[0m'; C_RED='\033[31m'; C_GREEN='\033[32m'
  C_YELLOW='\033[33m'; C_BLUE='\033[36m'; C_BOLD='\033[1m'; C_DIM='\033[2m'
else
  C_RESET=''; C_RED=''; C_GREEN=''; C_YELLOW=''; C_BLUE=''; C_BOLD=''; C_DIM=''
fi

STEP=0
step()  { STEP=$((STEP + 1)); printf "\n${C_BLUE}${C_BOLD}==> [%d] %s${C_RESET}\n" "$STEP" "$*"; }
info()  { printf "    %s\n" "$*"; }
ok()    { printf "    ${C_GREEN}✓${C_RESET} %s\n" "$*"; }
warn()  { printf "    ${C_YELLOW}!${C_RESET} %s\n" "$*"; }
fail()  { printf "    ${C_RED}✗${C_RESET} %s\n" "$*"; }
die()   { printf "\n${C_RED}${C_BOLD}错误：${C_RESET}%s\n" "$*" >&2; exit 1; }

record() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" >>"$LOG_FILE"; }

# 执行（或 dry-run 时只打印）
run() {
  if [ "$DRY_RUN" = "1" ]; then
    printf "    ${C_DIM}[dry-run] %s${C_RESET}\n" "$*"
    return 0
  fi
  record "RUN: $*"
  "$@"
}

have() { command -v "$1" >/dev/null 2>&1; }

# 从 /dev/tty 读，避免脚本被管道调用时 read 拿到空
read_tty() {
  local __var="$1" __prompt="$2" __default="${3:-}" __reply=""
  if [ "$ASSUME_YES" = "1" ]; then
    eval "$__var=\"\$__default\""
    return 0
  fi
  printf "%s" "$__prompt"
  if [ -r /dev/tty ]; then
    IFS= read -r __reply </dev/tty || __reply=""
  else
    IFS= read -r __reply || __reply=""
  fi
  [ -z "$__reply" ] && __reply="$__default"
  eval "$__var=\"\$__reply\""
}

ask_yes_no() {
  local prompt="$1" default="${2:-y}" answer=""
  if [ "$ASSUME_YES" = "1" ]; then
    [ "$default" = "y" ]
    return $?
  fi
  if [ "$default" = "y" ]; then prompt="$prompt [Y/n] "; else prompt="$prompt [y/N] "; fi
  read_tty answer "$prompt" "$default"
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

# ---------------------------------------------------------------------------
# 参数解析
# ---------------------------------------------------------------------------
usage() {
  cat <<'EOF'
用法: ./bootstrap.sh [选项]

包管理器:
  -m, --manager <macports|homebrew|none>   指定包管理器（不指定则交互选择）
      --extra "<pkg1 pkg2>"                额外安装的软件包（用 brew 名，自动换算 MacPorts 名）

执行范围:
      --only-dotfiles      只部署配置文件，不装任何软件
      --no-packages        跳过命令行工具
      --no-apps            跳过 GUI 应用与字体
      --no-dotfiles        跳过 rcm 部署
      --no-node            跳过 nvm / Node / pnpm
      --no-tmux            跳过 tmux 插件
      --no-ssh             跳过 SSH 密钥与 git 身份配置
      --restore <目录>     从备份目录恢复应用配置（iterm2/alfred/joplin/kitty/tmux）
      --no-restore         跳过配置恢复
      --defaults           顺带应用常用的 macOS 系统设置

其它:
  -y, --yes                所有提问取默认值（无人值守）
  -n, --dry-run            预演，只打印将执行的操作
      --git-name  <名字>   直接指定 git user.name
      --git-email <邮箱>   直接指定 git user.email
  -h, --help               显示帮助

环境变量:
  NODE_VERSION   nvm 安装的 Node 大版本，默认 26
  NVM_VERSION    nvm 的 tag，默认 v0.40.8

例子:
  ./bootstrap.sh                              # 交互式
  ./bootstrap.sh -m homebrew -y               # 全自动用 Homebrew
  ./bootstrap.sh -m macports --restore ~/Desktop/MacBackup/01-configs
  ./bootstrap.sh --only-dotfiles -y           # 只恢复 dotfiles
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -m|--manager)   MANAGER="${2:-}"; shift 2 ;;
    --extra)        EXTRA_PKGS="${2:-}"; shift 2 ;;
    --restore)      RESTORE_DIR="${2:-}"; shift 2 ;;
    --git-name)     GIT_NAME="${2:-}"; shift 2 ;;
    --git-email)    GIT_EMAIL="${2:-}"; shift 2 ;;
    --only-dotfiles) DO_PACKAGES=0; DO_APPS=0; DO_NODE=0; DO_TMUX=0; DO_SSH=0; DO_RESTORE=0; shift ;;
    --no-packages)  DO_PACKAGES=0; shift ;;
    --no-apps)      DO_APPS=0; shift ;;
    --no-dotfiles)  DO_DOTFILES=0; shift ;;
    --no-node)      DO_NODE=0; shift ;;
    --no-tmux)      DO_TMUX=0; shift ;;
    --no-ssh)       DO_SSH=0; shift ;;
    --no-restore)   DO_RESTORE=0; shift ;;
    --defaults)     DO_DEFAULTS=1; shift ;;
    -y|--yes)       ASSUME_YES=1; shift ;;
    -n|--dry-run)   DRY_RUN=1; shift ;;
    -h|--help)      usage; exit 0 ;;
    *)              die "未知参数：$1（用 -h 查看帮助）" ;;
  esac
done

# ---------------------------------------------------------------------------
# 包清单
#   以 Homebrew 的 formula 名为准；MacPorts 用 port_name() 换算
# ---------------------------------------------------------------------------
PKGS="git-delta fzf eza bat zoxide lazygit tmux neovim
wget jq ripgrep fd tree htop fastfetch onefetch yazi chafa
tree-sitter rcm imagemagick pkg-config cmake
python@3.12 python@3.15 ruby rust bun luajit"

CASKS="iterm2 alfred joplin kitty wezterm neovide-app font-fira-code-nerd-font"

# Homebrew 名 -> MacPorts 端口名（同名的不列）
port_name() {
  case "$1" in
    imagemagick)    echo "ImageMagick7" ;;   # brew 的 imagemagick 是 IM7，MacPorts 对应端口叫 ImageMagick7
    pkg-config)     echo "pkgconfig" ;;      # Node/Ruby/Rust 硬依赖这个端口名，不能用 pkgconf
    python@3.12)    echo "python312" ;;
    python@3.15)    echo "python315" ;;
    ruby)           echo "ruby34" ;;
    *)              echo "$1" ;;
  esac
}

# ---------------------------------------------------------------------------
# 0. 预检
# ---------------------------------------------------------------------------
preflight() {
  step "环境检查"

  [ "$(uname -s)" = "Darwin" ] || die "这个脚本只适用于 macOS。"

  local os_ver arch
  os_ver="$(sw_vers -productVersion)"
  arch="$(uname -m)"
  info "macOS $os_ver ($(sw_vers -buildVersion)) / $arch"
  [ "$arch" = "arm64" ] && info "Apple Silicon：Homebrew 前缀为 /opt/homebrew" \
                        || info "Intel：Homebrew 前缀为 /usr/local"

  # Xcode Command Line Tools：git / clang / make 的来源
  if ! xcode-select -p >/dev/null 2>&1; then
    warn "未检测到 Xcode Command Line Tools"
    if ask_yes_no "现在触发安装？安装完成后需要重新运行本脚本" y; then
      run xcode-select --install || true
    fi
    die "请先完成 Command Line Tools 安装，然后重新运行 ./bootstrap.sh"
  fi
  ok "Xcode Command Line Tools 已就绪：$(xcode-select -p)"

  if ! have git; then
    die "找不到 git，请先安装 Command Line Tools。"
  fi

  : >"$LOG_FILE"
  record "bootstrap v$VERSION 开始，参数：manager=$MANAGER dry_run=$DRY_RUN yes=$ASSUME_YES"
  info "日志：$LOG_FILE"
}

# ---------------------------------------------------------------------------
# 1. 选择并准备包管理器
# ---------------------------------------------------------------------------
detect_manager() {
  if [ -x /opt/local/bin/port ] || have port; then
    echo "macports"
  elif have brew; then
    echo "homebrew"
  else
    echo ""
  fi
}

choose_manager() {
  [ -n "$MANAGER" ] && return 0

  # 不需要装任何软件时（--only-dotfiles / --no-packages --no-apps），不必选包管理器
  if [ "$DO_PACKAGES" = "0" ] && [ "$DO_APPS" = "0" ]; then
    MANAGER="none"
    return 0
  fi

  local detected
  detected="$(detect_manager)"

  # 无人值守模式：自动沿用已安装的那个
  if [ "$ASSUME_YES" = "1" ]; then
    MANAGER="${detected:-macports}"
    info "无人值守模式，自动选择：$MANAGER"
    return 0
  fi

  printf "\n${C_BOLD}请选择用哪个包管理器安装命令行工具：${C_RESET}\n"
  printf "  1) MacPorts   /opt/local     %s\n" "$([ "$detected" = macports ] && echo '（本机已安装，推荐）')"
  printf "  2) Homebrew   /usr/local 或 /opt/homebrew   %s\n" "$([ "$detected" = homebrew ] && echo '（本机已安装，推荐）')"
  printf "  3) 都不装，只部署配置文件\n"

  local choice default="1"
  [ "$detected" = "homebrew" ] && default="2"

  read_tty choice "选择 [1/2/3]，回车默认 $default: " "$default"
  case "$choice" in
    1) MANAGER="macports" ;;
    2) MANAGER="homebrew" ;;
    3) MANAGER="none"; DO_PACKAGES=0; DO_APPS=0 ;;
    *) die "无效选择：$choice" ;;
  esac
}

sudo_keepalive() {
  [ "$DRY_RUN" = "1" ] && return 0
  info "需要管理员权限，请输入一次密码（后续不再询问）"
  sudo -v || die "无法获取管理员权限，MacPorts 安装需要 sudo。"
  ( while true; do sudo -n true 2>/dev/null; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &
  SUDO_KEEPALIVE_PID=$!
}

cleanup() {
  if [ -n "$SUDO_KEEPALIVE_PID" ]; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
  fi
  rm -rf "$TMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

install_macports() {
  if [ -x /opt/local/bin/port ]; then
    ok "MacPorts 已安装：$(/opt/local/bin/port version | head -1)"
    return 0
  fi

  info "未检测到 MacPorts，准备从官方 GitHub Release 下载安装包"

  # 资产名形如 MacPorts-2.12.7-14-Sonoma.pkg，用系统版本号匹配
  local os_ver short api url pkg
  os_ver="$(sw_vers -productVersion)"
  case "$os_ver" in
    10.*) short="$(echo "$os_ver" | cut -d. -f1,2)" ;;
    *)    short="$(echo "$os_ver" | cut -d. -f1)" ;;
  esac
  api="https://api.github.com/repos/macports/macports-base/releases/latest"

  url="$(curl -fsSL "$api" \
        | grep -o '"browser_download_url": *"[^"]*\.pkg"' \
        | sed 's/.*"\(https[^"]*\)".*/\1/' \
        | grep -- "-${short}-" | head -1 || true)"

  [ -n "$url" ] || die "找不到适配 macOS $os_ver 的 MacPorts 安装包，请手动安装：https://www.macports.org/install.php"

  pkg="$TMP_DIR/$(basename "$url")"
  info "下载 $(basename "$url")"
  run curl -fL --progress-bar "$url" -o "$pkg"
  info "安装（需要管理员密码）"
  run sudo installer -pkg "$pkg" -target /
  have port || [ -x /opt/local/bin/port ] || die "MacPorts 安装后仍找不到 port 命令。"

  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
  run sudo /opt/local/bin/port -v selfupdate
  ok "MacPorts 安装完成"
}

install_homebrew() {
  if have brew; then
    ok "Homebrew 已安装：$(brew --version | head -1)"
  else
    info "未检测到 Homebrew，使用官方脚本安装（过程中可能要求输入密码）"
    if [ "$DRY_RUN" = "1" ]; then
      info "[dry-run] 将执行 Homebrew 官方安装脚本"
      return 0
    fi
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
      || die "Homebrew 安装失败，请手动安装后重试：https://brew.sh"
  fi

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  have brew || die "Homebrew 安装后仍找不到 brew 命令。"

  run brew update
  ok "Homebrew 就绪：$(brew --version | head -1)"
}

prepare_manager() {
  case "$MANAGER" in
    macports)
      step "准备 MacPorts"
      sudo_keepalive
      install_macports
      export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
      ;;
    homebrew)
      step "准备 Homebrew"
      install_homebrew
      ;;
    none)
      step "跳过软件安装"
      info "只部署配置文件（--only-dotfiles 等价行为）"
      DO_APPS=0
      ;;
    *) die "未知的包管理器：$MANAGER（可选 macports / homebrew / none）" ;;
  esac
}

# ---------------------------------------------------------------------------
# 2. 命令行工具
# ---------------------------------------------------------------------------
# 注意：`port -q installed <name>` 在端口未安装时也返回 0（只是无输出），
# 所以必须检查输出内容，不能只看退出码。
port_installed() {
  [ -x /opt/local/bin/port ] || return 1
  /opt/local/bin/port -q installed "$1" 2>/dev/null | grep -q "^  $1 @"
}

is_installed() {
  local brew_pkg="$1" mp_pkg
  if [ "$MANAGER" = "macports" ]; then
    mp_pkg="$(port_name "$brew_pkg")"
    port_installed "$mp_pkg"
  else
    have brew || return 1
    brew list --formula "$brew_pkg" >/dev/null 2>&1
  fi
}

install_packages() {
  [ "$DO_PACKAGES" = "1" ] || return 0
  [ "$MANAGER" = "none" ] && return 0

  step "安装命令行工具（$MANAGER）"

  if [ "$MANAGER" = "macports" ] && [ ! -x /opt/local/bin/port ]; then
    warn "未安装 MacPorts，跳过软件安装"
    return 0
  fi
  if [ "$MANAGER" = "homebrew" ] && ! have brew; then
    warn "未安装 Homebrew，跳过软件安装"
    return 0
  fi

  local all="$PKGS"
  [ -n "$EXTRA_PKGS" ] && all="$all $EXTRA_PKGS"

  local missing="" p name count=0
  for p in $all; do
    if is_installed "$p"; then
      printf "    ${C_DIM}已安装${C_RESET} %s\n" "$p"
    else
      name="$p"
      [ "$MANAGER" = "macports" ] && name="$(port_name "$p")"
      missing="$missing $name"
      count=$((count + 1))
    fi
  done

  if [ "$count" -eq 0 ]; then
    ok "命令行工具已齐全，无需安装"
    return 0
  fi

  info "待安装 $count 个：$missing"
  if [ "$MANAGER" = "macports" ]; then
    info "Intel 机器上部分端口需要源码编译，首次安装可能较久（30 分钟以上）"
    # shellcheck disable=SC2086
    if ! run sudo /opt/local/bin/port -N install $missing; then
      warn "批量安装有失败项，逐个重试以定位问题"
      for p in $missing; do
        run sudo /opt/local/bin/port -N install "$p" || fail "安装失败：$p"
      done
    fi
  else
    # shellcheck disable=SC2086
    if ! run brew install $missing; then
      warn "批量安装有失败项，逐个重试以定位问题"
      for p in $missing; do
        run brew install "$p" || fail "安装失败：$p"
      done
    fi
  fi

  ok "命令行工具处理完毕"
}

# ---------------------------------------------------------------------------
# 3. GUI 应用与字体
# ---------------------------------------------------------------------------
install_apps() {
  [ "$DO_APPS" = "1" ] || return 0
  [ "$MANAGER" = "none" ] && return 0

  step "安装 GUI 应用与字体（$MANAGER）"

  if [ "$MANAGER" = "homebrew" ]; then
    have brew || { warn "未安装 Homebrew，跳过"; return 0; }
    local missing="" c
    for c in $CASKS; do
      if brew list --cask "$c" >/dev/null 2>&1; then
        printf "    ${C_DIM}已安装${C_RESET} %s\n" "$c"
      else
        missing="$missing $c"
      fi
    done
    if [ -z "$missing" ]; then
      ok "GUI 应用与字体已齐全"
      return 0
    fi
    info "待安装：$missing"
    # shellcheck disable=SC2086
    run brew install --cask $missing || warn "部分 cask 安装失败，见上方输出"
    return 0
  fi

  # MacPorts：有端口的用端口，没有的给出官方下载地址
  # 注意：如果 .app 已经存在（比如之前用 cask 或手工装过），就不再重复装端口版，
  # 否则 /Applications 下会出现两份同名应用。
  local mp_gui="iTerm2 kitty wezterm"
  local missing="" p bundle
  for p in $mp_gui; do
    case "$p" in
      iTerm2)  bundle="/Applications/iTerm.app" ;;
      kitty)   bundle="/Applications/kitty.app" ;;
      wezterm) bundle="/Applications/WezTerm.app" ;;
      *)       bundle="" ;;
    esac
    if port_installed "$p"; then
      printf "    ${C_DIM}已安装（端口）${C_RESET} %s\n" "$p"
    elif [ -n "$bundle" ] && [ -d "$bundle" ]; then
      printf "    ${C_DIM}已安装（应用）${C_RESET} %s\n" "$p"
    else
      missing="$missing $p"
    fi
  done
  if [ -n "$missing" ]; then
    info "待安装：$missing"
    # shellcheck disable=SC2086
    run sudo /opt/local/bin/port -N install $missing || warn "部分应用安装失败"
  fi

  # 字体：nerd-fonts 官方 zip，两个包管理器都能用
  if [ -d "$HOME/Library/Fonts/FiraCodeNerdFont" ] || \
     ls "$HOME/Library/Fonts" 2>/dev/null | grep -qi "FiraCode.*Nerd"; then
    ok "FiraCode Nerd Font 已安装"
  else
    info "下载 FiraCode Nerd Font"
    if run curl -fL -o "$TMP_DIR/FiraCode.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"; then
      run mkdir -p "$HOME/Library/Fonts/FiraCodeNerdFont"
      run unzip -oq "$TMP_DIR/FiraCode.zip" -d "$HOME/Library/Fonts/FiraCodeNerdFont"
      ok "字体已安装到 ~/Library/Fonts/FiraCodeNerdFont"
    else
      warn "字体下载失败，可稍后手动安装：https://www.nerdfonts.com/font-downloads"
    fi
  fi

  # 这三个在 MacPorts 里没有端口，检查是否已有 .app，没有才提示
  local manual=""
  [ -d "/Applications/Alfred 5.app" ] || [ -d "/Applications/Alfred.app" ] || \
    manual="$manual
  Alfred : https://www.alfredapp.com"
  [ -d "/Applications/Joplin.app" ] || \
    manual="$manual
  Joplin : https://joplinapp.org/download/"
  [ -d "/Applications/Neovide.app" ] || \
    manual="$manual
  Neovide: https://github.com/neovide/neovide/releases"

  if [ -n "$manual" ]; then
    warn "以下应用 MacPorts 没有端口，需要手动安装："
    printf "%s\n" "$manual" | while IFS= read -r line; do
      [ -n "$line" ] && info "$line"
    done
  else
    ok "Alfred / Joplin / Neovide 均已安装"
  fi
}

# ---------------------------------------------------------------------------
# 4. dotfiles（rcm）
# ---------------------------------------------------------------------------
ensure_rcm() {
  have rcup && return 0
  warn "未找到 rcup，尝试安装 rcm"
  case "$MANAGER" in
    macports) run sudo /opt/local/bin/port -N install rcm || return 1 ;;
    homebrew) run brew install rcm || return 1 ;;
    *) return 1 ;;
  esac
  have rcup
}

# 把会妨碍 rcup 建链的现有文件移到备份目录
stage_path() {
  local target="$1" dest
  [ -e "$target" ] || [ -L "$target" ] || return 0
  # 已经指向本仓库的软链不用动
  if [ -L "$target" ]; then
    case "$(readlink "$target")" in
      "$DOTFILES_DIR"/*) return 0 ;;
    esac
  fi
  dest="$BACKUP_DIR/$(echo "${target#$HOME/}" | tr '/' '_')"
  info "备份现有 ${target#$HOME/} -> $dest"
  run mkdir -p "$BACKUP_DIR"
  run mv "$target" "$dest"
}

deploy_dotfiles() {
  [ "$DO_DOTFILES" = "1" ] || return 0

  step "部署 dotfiles（rcm）"

  [ -d "$DOTFILES_DIR/tag-rcm" ] || die "当前目录不像 dotfiles 仓库：$DOTFILES_DIR"

  if ! ensure_rcm; then
    warn "rcm 不可用，跳过 dotfiles 部署"
    warn "可手动安装后执行：ln -s $DOTFILES_DIR/tag-rcm/rcrc ~/.rcrc && rcup -v"
    return 0
  fi

  # 关键顺序：rcup 依赖 ~/.rcrc，而 ~/.rcrc 本身也由 rcup 创建
  stage_path "$HOME/.rcrc"
  if [ -L "$HOME/.rcrc" ] && [ "$(readlink "$HOME/.rcrc")" = "$DOTFILES_DIR/tag-rcm/rcrc" ]; then
    ok "~/.rcrc 已指向仓库"
  else
    run ln -sfn "$DOTFILES_DIR/tag-rcm/rcrc" "$HOME/.rcrc" \
      || warn "创建 ~/.rcrc 失败，请手动执行：ln -sfn $DOTFILES_DIR/tag-rcm/rcrc ~/.rcrc"
  fi

  # 这些位置若是实体文件/旧软链，rcup 会冲突，先移到备份
  stage_path "$HOME/.zshrc"
  stage_path "$HOME/.zshenv"
  stage_path "$HOME/.tmux.conf"
  stage_path "$HOME/.tmux.conf.local"
  stage_path "$HOME/.ideavimrc"
  stage_path "$HOME/.config/bat"
  stage_path "$HOME/.config/wezterm"
  stage_path "$HOME/.config/lazygit/config.yml"

  if [ "$DRY_RUN" = "1" ]; then
    info "[dry-run] 将执行 rcup -v"
  else
    rcup -v || warn "rcup 返回非零，请检查上方输出"
  fi

  # 校验（dry-run 下什么都没建，跳过）
  if [ "$DRY_RUN" = "1" ]; then
    info "[dry-run] 将校验上述软链"
    return 0
  fi

  local f dest bad=0
  for f in .zshrc .zshenv .tmux.conf .ideavimrc .rcrc .config/wezterm .config/bat .config/lazygit/config.yml; do
    if [ -L "$HOME/$f" ]; then
      dest="$(readlink "$HOME/$f")"
      ok "$f -> ${dest#$HOME/}"
    elif [ -e "$HOME/$f" ]; then
      warn "$f 是实体文件（未建立软链）"
      bad=$((bad + 1))
    else
      warn "$f 不存在"
      bad=$((bad + 1))
    fi
  done
  [ "$bad" -eq 0 ] && ok "dotfiles 部署完成" || warn "有 $bad 项未按预期部署"
}

install_omz() {
  [ "$DO_DOTFILES" = "1" ] || return 0

  step "安装 oh-my-zsh / powerlevel10k / 插件"

  local zsh_dir="$HOME/.oh-my-zsh" custom="$HOME/.oh-my-zsh/custom"
  if [ -d "$zsh_dir" ]; then
    ok "oh-my-zsh 已存在"
  else
    run git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$zsh_dir" \
      || { warn "oh-my-zsh 克隆失败（网络？）"; return 0; }
  fi

  if [ -d "$custom/themes/powerlevel10k" ]; then
    ok "powerlevel10k 已存在"
  else
    run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
      "$custom/themes/powerlevel10k" || warn "powerlevel10k 克隆失败"
  fi

  local item name repo
  for item in \
    "zsh-completions:zsh-users/zsh-completions" \
    "zsh-autosuggestions:zsh-users/zsh-autosuggestions" \
    "zsh-syntax-highlighting:zsh-users/zsh-syntax-highlighting"; do
    name="${item%%:*}"
    repo="${item##*:}"
    if [ -d "$custom/plugins/$name" ]; then
      ok "插件已存在：$name"
    else
      run git clone --depth=1 "https://github.com/$repo.git" "$custom/plugins/$name" \
        || warn "插件克隆失败：$name"
    fi
  done
}

# ---------------------------------------------------------------------------
# 5. nvm / Node / pnpm
# ---------------------------------------------------------------------------
install_node() {
  [ "$DO_NODE" = "1" ] || return 0

  step "安装 nvm / Node $NODE_VERSION / pnpm"

  local nvm_dir="$HOME/.nvm"
  if [ -s "$nvm_dir/nvm.sh" ]; then
    ok "nvm 已存在：$(set +u; . "$nvm_dir/nvm.sh" >/dev/null 2>&1; nvm --version 2>/dev/null)"
  else
    info "克隆 nvm $NVM_VERSION 到 ~/.nvm（不修改 .zshrc，配置由 dotfiles 提供）"
    run git clone --depth=1 --branch "$NVM_VERSION" \
      https://github.com/nvm-sh/nvm.git "$nvm_dir" || {
        warn "nvm 克隆失败，尝试官方安装脚本"
        if [ "$DRY_RUN" != "1" ]; then
          PROFILE=/dev/null bash -c \
            "$(curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh")" || true
        fi
      }
  fi

  [ "$DRY_RUN" = "1" ] && { info "[dry-run] 将安装 Node $NODE_VERSION 与 pnpm"; return 0; }
  [ -s "$nvm_dir/nvm.sh" ] || { warn "nvm 不可用，跳过 Node 安装"; return 0; }

  # nvm 与 set -u 不兼容，进出都要切换
  set +u
  # shellcheck disable=SC1090
  . "$nvm_dir/nvm.sh" >/dev/null 2>&1 || true
  set -u

  if ( set +u; . "$nvm_dir/nvm.sh" >/dev/null 2>&1; nvm which "$NODE_VERSION" >/dev/null 2>&1 ); then
    ok "Node $NODE_VERSION 已安装"
  else
    info "安装 Node $NODE_VERSION（优先二进制包）"
    if ! ( set +u; . "$nvm_dir/nvm.sh" >/dev/null 2>&1; nvm install "$NODE_VERSION" ); then
      warn "nvm install 失败，改用官方二进制包直装"
      install_node_tarball "$NODE_VERSION" || { fail "Node 安装失败"; return 0; }
    fi
  fi

  ( set +u; . "$nvm_dir/nvm.sh" >/dev/null 2>&1; nvm alias default "$NODE_VERSION" >/dev/null 2>&1 || true )

  info "安装 pnpm"
  ( set +u; . "$nvm_dir/nvm.sh" >/dev/null 2>&1; nvm use "$NODE_VERSION" >/dev/null 2>&1; \
    npm install -g pnpm@latest ) || warn "pnpm 安装失败，稍后可手动执行：npm i -g pnpm"

  ( set +u; . "$nvm_dir/nvm.sh" >/dev/null 2>&1; nvm use "$NODE_VERSION" >/dev/null 2>&1; \
    printf "    node %s | npm %s | pnpm %s\n" "$(node -v)" "$(npm -v)" "$(pnpm -v 2>/dev/null || echo '-')" )
}

# 无二进制包 / nvm install 失败时的兜底：直接下官方 tarball 并校验 SHA256
install_node_tarball() {
  local want="$1" version arch url sha file dir
  info "查询 Node $want 的最新版本号"
  version="$(curl -fsSL https://nodejs.org/dist/index.json \
    | grep -o '"version":"v'"$want"'\.[0-9.]*"' | head -1 | sed 's/.*"v//; s/"//')"
  [ -n "$version" ] || { fail "查询不到 Node $want 的版本"; return 1; }

  case "$(uname -m)" in
    arm64) arch="arm64" ;;
    *)     arch="x64" ;;
  esac

  url="https://nodejs.org/dist/v$version/node-v$version-darwin-$arch.tar.gz"
  file="$TMP_DIR/node-v$version.tar.gz"
  info "下载 node-v$version-darwin-$arch.tar.gz"
  curl -fL --progress-bar "$url" -o "$file" || return 1

  sha="$(curl -fsSL "https://nodejs.org/dist/v$version/SHASUMS256.txt" \
         | grep "darwin-$arch.tar.gz" | awk '{print $1}' | head -1)"
  if [ -n "$sha" ]; then
    if [ "$(shasum -a 256 "$file" | awk '{print $1}')" = "$sha" ]; then
      ok "SHA256 校验通过"
    else
      fail "SHA256 不匹配，已中止"; return 1
    fi
  else
    warn "拿不到官方校验值，跳过校验"
  fi

  mkdir -p "$HOME/.nvm/versions/node"
  tar -xzf "$file" -C "$HOME/.nvm/versions/node" || return 1
  [ -d "$HOME/.nvm/versions/node/node-v$version-darwin-$arch" ] || return 1
  mv "$HOME/.nvm/versions/node/node-v$version-darwin-$arch" \
     "$HOME/.nvm/versions/node/v$version"
  ok "Node v$version 已就位"
}

# ---------------------------------------------------------------------------
# 6. tmux 插件
# ---------------------------------------------------------------------------
install_tmux_plugins() {
  [ "$DO_TMUX" = "1" ] || return 0
  step "安装 tmux 插件（tpm）"

  if ! have tmux; then
    warn "未安装 tmux，跳过"
    return 0
  fi

  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    run git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" \
      || { warn "tpm 克隆失败"; return 0; }
  else
    ok "tpm 已存在"
  fi

  if [ "$DRY_RUN" = "1" ]; then
    info "[dry-run] 将执行 tpm install_plugins"
    return 0
  fi
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 \
    && ok "tmux 插件安装完成" \
    || warn "tmux 插件安装返回非零，可稍后在 tmux 里按 prefix + I 手动安装"
}

# ---------------------------------------------------------------------------
# 7. SSH 密钥 / git 身份
# ---------------------------------------------------------------------------
setup_ssh_git() {
  [ "$DO_SSH" = "1" ] || return 0
  step "SSH 密钥与 git 身份"

  local name email
  name="$(git config --global user.name 2>/dev/null || true)"
  email="$(git config --global user.email 2>/dev/null || true)"
  [ -n "$GIT_NAME" ] && name="$GIT_NAME"
  [ -n "$GIT_EMAIL" ] && email="$GIT_EMAIL"

  if [ -z "$name" ] || [ -z "$email" ]; then
    if [ "$ASSUME_YES" = "0" ] && [ "$DRY_RUN" = "0" ]; then
      read_tty GIT_NAME "git 用户名（user.name）: " "$name"
      read_tty GIT_EMAIL "git 邮箱（user.email）: " "$email"
      name="$GIT_NAME"; email="$GIT_EMAIL"
    fi
  fi
  if [ -n "$name" ] && [ -n "$email" ]; then
    run git config --global user.name "$name"
    run git config --global user.email "$email"
    ok "git 身份：$name <$email>"
  else
    warn "未设置 git 身份，可稍后执行 git config --global user.name/user.email"
  fi

  if [ -f "$HOME/.ssh/id_ed25519" ]; then
    ok "SSH 密钥已存在：~/.ssh/id_ed25519"
  else
    if ask_yes_no "生成新的 SSH 密钥（ed25519）？" y; then
      local pass=""
      if [ "$ASSUME_YES" = "0" ] && [ "$DRY_RUN" = "0" ]; then
        printf "私钥密码短语（留空表示不设置）: "
        if [ -r /dev/tty ]; then IFS= read -rs pass </dev/tty || pass=""; else IFS= read -rs pass || pass=""; fi
        printf "\n"
      fi
      run mkdir -p "$HOME/.ssh"
      run chmod 700 "$HOME/.ssh"
      if [ "$DRY_RUN" = "1" ]; then
        info "[dry-run] ssh-keygen -t ed25519 -C \"$email\" -f ~/.ssh/id_ed25519"
      else
        ssh-keygen -t ed25519 -C "${email:-$(whoami)@$(hostname)}" \
          -f "$HOME/.ssh/id_ed25519" -N "$pass" >/dev/null
        ok "已生成 ~/.ssh/id_ed25519(.pub)"
      fi
    fi
  fi

  # ssh config：macOS 钥匙串记住 passphrase
  if [ -f "$HOME/.ssh/id_ed25519" ] && ! grep -q "IdentityFile ~/.ssh/id_ed25519" "$HOME/.ssh/config" 2>/dev/null; then
    if [ "$DRY_RUN" = "1" ]; then
      info "[dry-run] 写入 ~/.ssh/config（AddKeysToAgent / UseKeychain）"
    else
      {
        echo ""
        echo "Host *"
        echo "  AddKeysToAgent yes"
        echo "  UseKeychain yes"
        echo "  IdentityFile ~/.ssh/id_ed25519"
      } >>"$HOME/.ssh/config"
      chmod 600 "$HOME/.ssh/config"
      ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" 2>/dev/null || true
      ok "已配置 ~/.ssh/config 并加入钥匙串"
    fi
  fi

  if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    info "公钥（pbcopy < ~/.ssh/id_ed25519.pub 可复制）："
    sed 's/^/      /' "$HOME/.ssh/id_ed25519.pub"
    info "添加到 GitHub：Settings -> SSH and GPG keys -> New SSH key"
  fi
}

# ---------------------------------------------------------------------------
# 8. 从备份恢复应用配置（可选）
# ---------------------------------------------------------------------------
restore_backups() {
  [ "$DO_RESTORE" = "1" ] || return 0
  [ -n "$RESTORE_DIR" ] || return 0
  step "从备份恢复应用配置"

  [ -d "$RESTORE_DIR" ] || { warn "备份目录不存在：$RESTORE_DIR"; return 0; }

  if [ "$DRY_RUN" = "0" ]; then
    # 运行中的 App 会覆盖刚恢复的文件，先尝试退出
    osascript -e 'tell application "iTerm2" to quit' >/dev/null 2>&1 || true
    pkill -x Alfred >/dev/null 2>&1 || true
    pkill -x Joplin >/dev/null 2>&1 || true
    pkill -x kitty >/dev/null 2>&1 || true
    sleep 1
  fi

  local as="$HOME/Library/Application Support"
  run mkdir -p "$BACKUP_DIR"
  local d
  for d in "$as/iTerm2" "$as/Alfred" "$HOME/.config/joplin-desktop" "$HOME/.config/kitty"; do
    [ -e "$d" ] && run cp -a "$d" "$BACKUP_DIR/$(basename "$d").before-restore"
  done

  # iTerm2：Application Support（窗口/标签页状态、命令历史）
  if [ -f "$RESTORE_DIR/iterm2-appsupport.tgz" ]; then
    info "恢复 iTerm2 Application Support"
    run mkdir -p "$as/iTerm2"
    if [ "$DRY_RUN" = "0" ]; then
      mkdir -p "$TMP_DIR/iterm2"
      tar -xzf "$RESTORE_DIR/iterm2-appsupport.tgz" -C "$TMP_DIR/iterm2" 2>/dev/null || true
      if [ -d "$TMP_DIR/iterm2/Library/Application Support/iTerm2" ]; then
        rsync -a --exclude '*.lock' --exclude '*.socket*' \
          "$TMP_DIR/iterm2/Library/Application Support/iTerm2/" "$as/iTerm2/"
        ok "iTerm2 状态已恢复"
      else
        warn "归档结构不符合预期，跳过：$RESTORE_DIR/iterm2-appsupport.tgz"
      fi
    fi
  fi

  # iTerm2 偏好（profile / 配色 / 字体 / 快捷键）
  if [ -f "$RESTORE_DIR/prefs/iterm2.plist" ]; then
    info "恢复 iTerm2 偏好设置"
    run cp "$RESTORE_DIR/prefs/iterm2.plist" "$HOME/Library/Preferences/com.googlecode.iterm2.plist"
    run chmod 600 "$HOME/Library/Preferences/com.googlecode.iterm2.plist"
    run killall cfprefsd || true
    ok "iTerm2 plist 已恢复"
  fi

  # 其它应用：直接按归档解压到主目录
  local pair name file
  for pair in "alfred:alfred.tgz" "joplin:joplin.tgz" "kitty:config-kitty.tgz" "tmux:tmux.tgz"; do
    name="${pair%%:*}"; file="${pair##*:}"
    [ -f "$RESTORE_DIR/$file" ] || continue
    info "恢复 $name（$file）"
    if [ "$name" = "joplin" ]; then
      run tar -xzf "$RESTORE_DIR/$file" -C "$HOME" \
        --exclude '*.log' --exclude '*log-*.txt' \
        --exclude '.config/joplin-desktop/cache' \
        --exclude '.config/joplin-desktop/tmp' 2>/dev/null || warn "解压有警告：$file"
    else
      run tar -xzf "$RESTORE_DIR/$file" -C "$HOME" 2>/dev/null || warn "解压有警告：$file"
    fi
    ok "$name 配置已恢复"
  done

  [ "$DRY_RUN" = "0" ] && info "恢复前状态已备份到：$BACKUP_DIR"
  warn "如果 iTerm2 的字体/配色没生效：⌘Q 完全退出后重开（不是关窗口）"
}

# ---------------------------------------------------------------------------
# 9. macOS 常用设置（可选）
# ---------------------------------------------------------------------------
apply_defaults() {
  [ "$DO_DEFAULTS" = "1" ] || return 0
  step "应用 macOS 常用设置"
  if [ "$ASSUME_YES" = "0" ] && ! ask_yes_no "确认修改这些系统设置？" n; then
    info "跳过"
    return 0
  fi
  run defaults write NSGlobalDomain KeyRepeat -int 2
  run defaults write NSGlobalDomain InitialKeyRepeat -int 15
  run defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  run defaults write com.apple.finder AppleShowAllFiles -bool true
  run defaults write com.apple.finder ShowPathbar -bool true
  run killall Finder || true
  ok "已应用（部分设置需要注销后生效）"
}

# ---------------------------------------------------------------------------
# 10. 汇总
# ---------------------------------------------------------------------------
summary() {
  printf "\n${C_BOLD}========== 完成 ==========${C_RESET}\n"
  printf "包管理器 : %s\n" "${MANAGER:-未使用}"
  printf "dotfiles : %s\n" "$DOTFILES_DIR"
  printf "日志     : %s\n" "$LOG_FILE"
  if [ -d "$BACKUP_DIR" ]; then
    printf "备份     : %s\n" "$BACKUP_DIR"
  fi

  printf "\n${C_BOLD}接下来手动做两件事：${C_RESET}\n"
  printf "  1. 完全退出终端再重开（iTerm2 用 ⌘Q），验证提示符与配色\n"
  printf "  2. 首次进入会弹出 powerlevel10k 配置向导；~/.p10k.zsh 不存在属正常\n"

  if [ "$MANAGER" = "macports" ]; then
    printf "\n${C_YELLOW}MacPorts 提示：${C_RESET}Alfred / Joplin / Neovide 无端口，需手动安装（见上方链接）\n"
  fi
  printf "\n常用命令：rcup -v（重新部署）| rcdn（撤销软链）| lsrc（查看将部署的文件）\n"
}

main() {
  printf "${C_BOLD}dotfiles bootstrap v%s${C_RESET}\n" "$VERSION"
  printf "仓库目录：%s\n" "$DOTFILES_DIR"

  preflight
  choose_manager
  prepare_manager
  install_packages
  install_apps
  deploy_dotfiles
  install_omz
  install_node
  install_tmux_plugins
  setup_ssh_git
  restore_backups
  apply_defaults
  summary
}

main "$@"
