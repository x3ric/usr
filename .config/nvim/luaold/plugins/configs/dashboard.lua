local dashboard = require("dashboard")
math.randomseed(os.time())
local logo = {
archx = [[


========   ======   ========   ========   ===============     ===============   =========  ========
\\ . . \\ /| . .\\  |\ . . |\ /| . . /|  //. . . . . . .\\   //. . . . . . .\\  \\. . .\\// . . .//
||. . . \\||. . .|| ||. . .|| ||. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\/ . . . ||
|| . . . \\| . . || || . . || || . . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . .||
||. . . . \|. . .|| ||. . .`==='. . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . . ||
|| . . . . ` . . || || . . . . . . _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\\ . ./| . ||
||. .|. . . . . .|| `-__________.-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `| \\ ./ |. .||
|| . |\\. . . . _||  \_____    ||    || ||    ||   ||_ . || || . _||   ||    || ||   |  \\/  | . ||
||. .| \\. . _-' ||  /    \\.--||    || ||    \\   || `-_|| ||_-' ||   |/    || ||   |`-_|_- |-_.||
|| . |  \\.-'    || ||      `-_||    || ||      `-_||    || ||    ||_-'      || ||   |     | |  `||
||. _|  |\\      || ||         `'    || ||         `'    || ||    `'         || ||   |     | |   ||
||-' |  | \\   .==' `\==.         .==='.`===.         .==='.`===.         .===' /==. |     | |   ||
||   |  |  \\=='   \   -_ `===. .==='   _-|-_ `===. .===' _-|-_   `===. .===' _/   `==     | |   ||
||   |  |   \\   _-'    `-_  `='    _-'     `-_  `='  _-'     `-_    `='  _-'   `-_  /     | |   ||
||   |  |    `-'          `-__\\._-'           `-_|_-'           `-_./__-'         `'      | |   ||
||.==\  |                                                                                  \ /==.||
=='   \/                                    N E O V I M                                     \/  `==
\\   _-'                                                                                     `-_  /
 `''                                                                                           ``' 

]],
}

if vim.o.filetype == "lazy" then
  vim.cmd.close()
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
  local stats = require("lazy").stats()
  local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
  dashboard.setup({
    theme = "doom",
    hide = {
      statusline = 0,
      tabline = 0,
      winbar = 0,
    },
    shortcut = {
      { desc = " Update", group = "@property", action = "Lazy update", key = "u" },
    },
    config = {
      header = vim.split("\n" .. logo["archx"], "\n"), --your header
      center = {
        {
          icon = "   ",
          icon_hl = "DashboardRecent",
            desc = "Recent Files                                    ",
            -- desc_hi = "String",
            key = "r",
            key_hl = "DashboardRecent",
            action = "Telescope oldfiles",
        },
        {
          icon = "   ",
          icon_hl = "DashboardSession",
          desc = "Last Session",
            -- desc_hi = "String",
            key = "s",
            key_hl = "DashboardSession",
            action = "lua require('persistence').load({last = true})",
        },
        {
          icon = "   ",
          icon_hl = "DashboardConfiguration",
            desc = "Config",
            -- desc_hi = "String",
            key = "c",
            key_hl = "DashboardConfiguration",
            action = "edit $MYVIMRC",
        },
        {
          icon = "󰤄   ",
          icon_hl = "DashboardLazy",
          desc = "Lazy",
          -- desc_hi = "String",
          key = "l",
          key_hl = "DashboardLazy",
          action = "Lazy",
        },
        {
            icon = "   ",
            icon_hl = "DashboardServer",
            desc = "Mason",
            -- desc_hi = "String",
            key = "m",
            key_hl = "DashboardServer",
            action = "Mason",
          },
          {
          icon = "   ",
          icon_hl = "DashboardQuit",
            desc = "Quit",
            -- desc_hi = "String",
            key = "q",
            key_hl = "DashboardQuit",
            action = "qa",
        },
      },
      footer = {
        "󱦟 Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms",
      },
    },
  })
  end,
})