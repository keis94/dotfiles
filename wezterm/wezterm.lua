---@module 'wezterm'
---@type Wezterm
local wezterm = require('wezterm')
local act = wezterm.action

local config = wezterm.config_builder()

config.font = wezterm.font('PlemolJP Console NF')
config.use_ime = true
config.font_size = 12.0
config.colors = require('colorscheme.everforest_dark_hard')
config.adjust_window_size_when_changing_font_size = false

if wezterm.target_triple:find('windows') then
  config.default_prog = { 'pwsh' }
  config.wsl_domains = {
    {
      name = 'WSL:Ubuntu',
      distribution = 'Ubuntu',
      default_cwd = '~',
    }
  }
  config.default_domain = 'WSL:Ubuntu'
end

-- config.term = 'wezterm'
config.debug_key_events = true
config.leader = { key = 'j', mods = 'CTRL' }
config.keys = {
  -- tab, pane (tmux like)
  { key = 'c',  mods = 'LEADER',       action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n',  mods = 'LEADER',       action = act.ActivateTabRelative(1) },
  { key = 'p',  mods = 'LEADER',       action = act.ActivateTabRelative(-1) },
  { key = 'x',  mods = 'LEADER',       action = act.CloseCurrentTab { confirm = true } },
  { key = '\"', mods = 'LEADER|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = '%',  mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'h',  mods = 'LEADER',       action = act.ActivatePaneDirection 'Left' },
  { key = 'j',  mods = 'LEADER',       action = act.ActivatePaneDirection 'Down' },
  { key = 'k',  mods = 'LEADER',       action = act.ActivatePaneDirection 'Up' },
  { key = 'l',  mods = 'LEADER',       action = act.ActivatePaneDirection 'Right' },

  -- Open PowerShell
  {
    key = 'p',
    mods = 'CTRL|ALT',
    action = act.SpawnCommandInNewTab { domain = { DomainName = 'local' }, cwd = "~" }
  },

  -- switch mode
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
  { key = '/', mods = 'LEADER', action = act.Search 'CurrentSelectionOrEmptyString' },
}

if wezterm.target_triple:find('darwin') then
  -- Mac環境向け：Cmd を Alt(Meta) の Readline ショートカットに変換
  -- karabiner elements で Cmd -> Option を変更すると Option + Tab で App Switcher を開く設定が書けなかったので
  local readline_cmd_to_alt = {
    -- Alt + b : 1単語戻る (backward-word)
    { key = 'b',         mods = 'CMD', action = act.SendKey { key = 'b', mods = 'ALT' } },
    -- Alt + f : 1単語進む (forward-word)
    { key = 'f',         mods = 'CMD', action = act.SendKey { key = 'f', mods = 'ALT' } },
    -- Alt + d : カーソル位置から単語の末尾まで削除 (kill-word)
    { key = 'd',         mods = 'CMD', action = act.SendKey { key = 'd', mods = 'ALT' } },
    -- Alt + Backspace : カーソル位置から単語の先頭まで削除 (backward-kill-word)
    { key = 'Backspace', mods = 'CMD', action = act.SendKey { key = 'Backspace', mods = 'ALT' } },
    -- Alt + t : カーソル位置の単語と、その直前の単語を入れ替える (transpose-words)
    { key = 't',         mods = 'CMD', action = act.SendKey { key = 't', mods = 'ALT' } },
  }

  for _, binding in ipairs(readline_cmd_to_alt) do
    table.insert(config.keys, binding)
  end
end

config.key_tables = {
  copy_mode = {
    { key = '[',          mods = 'CTRL',  action = act.CopyMode 'Close' },
    { key = 'Tab',        mods = 'NONE',  action = act.CopyMode 'MoveForwardWord' },
    { key = 'Tab',        mods = 'SHIFT', action = act.CopyMode 'MoveBackwardWord' },
    { key = 'Enter',      mods = 'NONE',  action = act.CopyMode 'MoveToStartOfNextLine' },
    { key = 'Escape',     mods = 'NONE',  action = act.CopyMode 'Close' },
    { key = 'Space',      mods = 'NONE',  action = act.CopyMode { SetSelectionMode = 'Cell' } },
    { key = '$',          mods = 'NONE',  action = act.CopyMode 'MoveToEndOfLineContent' },
    { key = '$',          mods = 'SHIFT', action = act.CopyMode 'MoveToEndOfLineContent' },
    { key = ',',          mods = 'NONE',  action = act.CopyMode 'JumpReverse' },
    { key = '0',          mods = 'NONE',  action = act.CopyMode 'MoveToStartOfLine' },
    { key = ';',          mods = 'NONE',  action = act.CopyMode 'JumpAgain' },
    { key = 'F',          mods = 'NONE',  action = act.CopyMode { JumpBackward = { prev_char = false } } },
    { key = 'F',          mods = 'SHIFT', action = act.CopyMode { JumpBackward = { prev_char = false } } },
    { key = 'G',          mods = 'NONE',  action = act.CopyMode 'MoveToScrollbackBottom' },
    { key = 'G',          mods = 'SHIFT', action = act.CopyMode 'MoveToScrollbackBottom' },
    { key = 'H',          mods = 'NONE',  action = act.CopyMode 'MoveToViewportTop' },
    { key = 'H',          mods = 'SHIFT', action = act.CopyMode 'MoveToViewportTop' },
    { key = 'L',          mods = 'NONE',  action = act.CopyMode 'MoveToViewportBottom' },
    { key = 'L',          mods = 'SHIFT', action = act.CopyMode 'MoveToViewportBottom' },
    { key = 'M',          mods = 'NONE',  action = act.CopyMode 'MoveToViewportMiddle' },
    { key = 'M',          mods = 'SHIFT', action = act.CopyMode 'MoveToViewportMiddle' },
    { key = 'O',          mods = 'NONE',  action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
    { key = 'O',          mods = 'SHIFT', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
    { key = 'T',          mods = 'NONE',  action = act.CopyMode { JumpBackward = { prev_char = true } } },
    { key = 'T',          mods = 'SHIFT', action = act.CopyMode { JumpBackward = { prev_char = true } } },
    { key = 'V',          mods = 'NONE',  action = act.CopyMode { SetSelectionMode = 'Line' } },
    { key = 'V',          mods = 'SHIFT', action = act.CopyMode { SetSelectionMode = 'Line' } },
    { key = '^',          mods = 'NONE',  action = act.CopyMode 'MoveToStartOfLineContent' },
    { key = '^',          mods = 'SHIFT', action = act.CopyMode 'MoveToStartOfLineContent' },
    { key = 'b',          mods = 'NONE',  action = act.CopyMode 'MoveBackwardWord' },
    { key = 'b',          mods = 'ALT',   action = act.CopyMode 'MoveBackwardWord' },
    { key = 'b',          mods = 'CTRL',  action = act.CopyMode 'PageUp' },
    { key = 'c',          mods = 'CTRL',  action = act.CopyMode 'Close' },
    { key = 'd',          mods = 'CTRL',  action = act.CopyMode { MoveByPage = (0.5) } },
    { key = 'e',          mods = 'NONE',  action = act.CopyMode 'MoveForwardWordEnd' },
    { key = 'f',          mods = 'NONE',  action = act.CopyMode { JumpForward = { prev_char = false } } },
    { key = 'f',          mods = 'ALT',   action = act.CopyMode 'MoveForwardWord' },
    { key = 'f',          mods = 'CTRL',  action = act.CopyMode 'PageDown' },
    { key = 'g',          mods = 'NONE',  action = act.CopyMode 'MoveToScrollbackTop' },
    { key = 'g',          mods = 'CTRL',  action = act.CopyMode 'Close' },
    { key = 'h',          mods = 'NONE',  action = act.CopyMode 'MoveLeft' },
    { key = 'j',          mods = 'NONE',  action = act.CopyMode 'MoveDown' },
    { key = 'k',          mods = 'NONE',  action = act.CopyMode 'MoveUp' },
    { key = 'l',          mods = 'NONE',  action = act.CopyMode 'MoveRight' },
    { key = 'm',          mods = 'ALT',   action = act.CopyMode 'MoveToStartOfLineContent' },
    { key = 'o',          mods = 'NONE',  action = act.CopyMode 'MoveToSelectionOtherEnd' },
    { key = 'q',          mods = 'NONE',  action = act.CopyMode 'Close' },
    { key = 't',          mods = 'NONE',  action = act.CopyMode { JumpForward = { prev_char = true } } },
    { key = 'u',          mods = 'CTRL',  action = act.CopyMode { MoveByPage = (-0.5) } },
    { key = 'v',          mods = 'NONE',  action = act.CopyMode { SetSelectionMode = 'Cell' } },
    { key = 'v',          mods = 'CTRL',  action = act.CopyMode { SetSelectionMode = 'Block' } },
    { key = 'w',          mods = 'NONE',  action = act.CopyMode 'MoveForwardWord' },
    { key = 'y',          mods = 'NONE',  action = act.Multiple { { CopyTo = 'ClipboardAndPrimarySelection' }, { CopyMode = 'Close' } } },
    { key = 'PageUp',     mods = 'NONE',  action = act.CopyMode 'PageUp' },
    { key = 'PageDown',   mods = 'NONE',  action = act.CopyMode 'PageDown' },
    { key = 'End',        mods = 'NONE',  action = act.CopyMode 'MoveToEndOfLineContent' },
    { key = 'Home',       mods = 'NONE',  action = act.CopyMode 'MoveToStartOfLine' },
    { key = 'LeftArrow',  mods = 'NONE',  action = act.CopyMode 'MoveLeft' },
    { key = 'LeftArrow',  mods = 'ALT',   action = act.CopyMode 'MoveBackwardWord' },
    { key = 'RightArrow', mods = 'NONE',  action = act.CopyMode 'MoveRight' },
    { key = 'RightArrow', mods = 'ALT',   action = act.CopyMode 'MoveForwardWord' },
    { key = 'UpArrow',    mods = 'NONE',  action = act.CopyMode 'MoveUp' },
    { key = 'DownArrow',  mods = 'NONE',  action = act.CopyMode 'MoveDown' },
  },
  search_mode = {
    { key = 'Enter',  mods = 'NONE', action = act.CopyMode 'PriorMatch' },
    { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
    { key = '[',      mods = 'CTRL', action = act.CopyMode 'Close' },
    { key = 'n',      mods = 'CTRL', action = act.CopyMode 'NextMatch' },
    { key = 'p',      mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
    { key = 'r',      mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
    { key = 'u',      mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
  },

}
return config
