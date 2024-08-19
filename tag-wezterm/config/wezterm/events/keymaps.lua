local wezterm = require 'wezterm'

local M = {}

local act = wezterm.action

function M.setup(config)
  config.mouse_bindings = {
  -- 右键复制粘贴
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      -- 检查是否有选中的文本
      local has_selection = window:get_selection_text_for_pane(pane) ~= ''
      if has_selection then
        -- 有选中的文本，复制到剪切板
        window:perform_action(act.CopyTo 'Clipboard', pane)
        window:perform_action(act.ClearSelection, pane)
      else
        -- 没有选中，粘贴剪贴板内容
        window:perform_action(act.PasteFrom 'Clipboard', pane)
      end
    end)
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}
end

return M