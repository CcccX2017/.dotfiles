# 我的 MacBook Pro 配置文件

- 配置文件用 [rcm](https://github.com/thoughtbot/rcm) 管理

## 新机 / 重装系统：一键配置

```bash
git clone git@github.com:CcccX2017/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

脚本会依次完成：

1. 检查 Xcode Command Line Tools、macOS 版本与架构
2. **交互选择包管理器**：MacPorts / Homebrew / 不装软件
3. 用所选包管理器安装命令行工具（同一份清单，自动换算 MacPorts 端口名）
4. 安装 GUI 应用与 FiraCode Nerd Font
5. 用 rcm 把 `tag-*` 里的配置软链到主目录（会先备份冲突文件）
6. 安装 oh-my-zsh、powerlevel10k 与三个插件
7. 安装 nvm + Node + pnpm（nvm install 失败时自动改用官方二进制包）
8. 安装 tmux 插件（tpm）
9. 生成 SSH 密钥、写入 `~/.ssh/config`、设置 git 身份
10. 可选：从备份目录恢复 iTerm2 / Alfred / Joplin / kitty 的配置

### 常用用法

```bash
./bootstrap.sh                          # 交互式（推荐）
./bootstrap.sh -m macports -y           # 全自动，用 MacPorts
./bootstrap.sh -m homebrew -y           # 全自动，用 Homebrew
./bootstrap.sh -n                       # 预演，只打印将执行的操作
./bootstrap.sh --only-dotfiles -y       # 只恢复配置，不装任何软件
./bootstrap.sh -m macports --restore ~/Desktop/MacBackup-20261028-2156/01-configs
./bootstrap.sh -h                       # 全部参数
```

### 说明

- 脚本可重复执行：已安装的软件、已建立的软链都会跳过。
- 冲突的旧文件会移到 `~/.dotfiles-backup-<时间戳>/`，不会直接删除。
- MacPorts 路径下 Alfred / Joplin / Neovide 没有端口，脚本会提示官方下载地址；
  Homebrew 路径下用 `--cask` 安装。
- 日志：`~/.dotfiles-bootstrap.log`

### 手动维护

| 命令 | 作用 |
|---|---|
| `rcup -v` | 重新部署软链 |
| `rcup -t tmux` | 只处理某个标签 |
| `lsrc` | 查看会部署哪些文件 |
| `rcdn` | 撤销所有软链 |
| `mkrc ~/.config/foo` | 把新配置收进仓库 |
