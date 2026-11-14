 local wezterm = require("wezterm")
 local config = wezterm.config_builder()

--  1. デフォルトで起動するシェル
 config.default_prog = { "pwsh.exe", "-NoLogo" }

 -- 2. フォントと文字サイズ
 config.font_size = 10.0

 -- 3. カラースキーム
 config.color_scheme = "Tokyo Night"

 -- 4. ウィンドウの外観・透過設定
 config.window_background_opacity = 0.85
 config.win32_system_backdrop = "Acrylic"
 config.window_decorations = "RESIZE"
 config.initial_cols = 120
 config.initial_rows = 32

 -- 5. タブバー・描画設定
 config.hide_tab_bar_if_only_one_tab = false
 config.tab_bar_at_bottom = true
 config.use_fancy_tab_bar = false
 config.front_end = "WebGpu"

 -- 6. キーバインド
 local act = wezterm.action
 config.keys = {
   { key = "D", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
   { key = "E", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
   { key = "W", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
   { key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection("Left") },
   { key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
   { key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection("Up") },
   { key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection("Down") },
 }

 -- 7. 左右ステータスバーの統合更新処理（ここに関数ラッパーを追加）
 wezterm.on("update-status", function(window, pane)
   -- === 1. 左端（ワークスペース・モード表示） ===
   local workspace = window:active_workspace()
   local key_table = window:active_key_table()

   local badge_text = "  " .. workspace .. " "
   local badge_bg = "#7aa2f7"
   local badge_fg = "#1a1b26"

   if window:leader_is_active() then
     badge_text = "  LEADER "
     badge_bg = "#e0af68"
   elseif key_table == "copy_mode" then
     badge_text = "  COPY "
     badge_bg = "#9ece6a"
   elseif key_table == "search_mode" then
     badge_text = "  SEARCH "
     badge_bg = "#bb9af7"
   end

   window:set_left_status(wezterm.format({
     { Background = { Color = badge_bg } },
     { Foreground = { Color = badge_fg } },
     { Attribute = { Intensity = "Bold" } },
     { Text = badge_text },
   }))

   -- === 2. 右端（バッテリー・日時表示） ===
   local bat = ""
   for _, b in ipairs(wezterm.battery_info()) do
     local charge = string.format("%.0f%%", b.state_of_charge * 100)
     local state = (b.state == "Charging" and "⚡") or ""
     bat = string.format(" %s%s ", state, charge)
   end

   local date = wezterm.strftime(" %m/%d (%a) %H:%M ")

   window:set_right_status(wezterm.format({
     { Foreground = { Color = "#7aa2f7" } },
     { Text = bat },
     { Foreground = { Color = "#565f89" } },
     { Text = "|" },
     { Foreground = { Color = "#c0caf5" } },
     { Text = date },
   }))
 end)

  return config
