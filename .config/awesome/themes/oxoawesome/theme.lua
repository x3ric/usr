-- Vars
	local gears = require("gears")
	local utils  = require("lib.utils")
	local awful = require("awful")
	local wibox = require("wibox")
	local menubar = require("menubar")
	local keys = require("keys")
	local dpi   = require("beautiful.xresources").apply_dpi
	local hotkeys_popup = require("lib.awesome.awful.hotkeys_popup").widget
	local os = os
	local awful = require("awful")
local theme = {}
theme.colormain = '#97A4E2'
theme.colorurgent = '#6EE5EF'
theme.icon_theme = 'Papirus'
function theme:init()
	-- Main
		self.wallpaper = os.getenv("HOME") .. "/.config/awesome/themes/oxoawesome/Default.jpg"
		self.desktopbg = self.wallpaper
		self.path = awful.util.get_configuration_dir() .. "themes/oxoawesome"
		self.homedir = os.getenv("HOME")
		self.panel_height        = 28 -- panel height
		self.border_width        = 0  -- window border width
		self.useless_gap         = 1  -- useless gap
		self.cellnum = { x = 96, y = 58 } -- grid layout property
	-- Colors
		self.color = {
			main      = self.colormain or '#97A4E2',
			urgent    = self.colorurgent or '#6EE5EF',
			gray    = "#575757",
			bg        = "#161616",
			bg_second = "#181818",
			wibox     = "#000000",
			icon      = "#a0a0a0",
			text      = "#aaaaaa",
			highlight = "#e0e0e0",
			border    = "#404040",
			shadow1   = "#141414",
			shadow2   = "#313131",
			shadow3   = "#1c1c1c",
			shadow4   = "#767676",
			button    = "#575757",
			pressed   = "#404040",
			desktop_gray = "#252525",
			desktop_icon = "#606060",
		}
	-- Fonts
		self.fonts = {
			main     = "OCR A 10",      -- main font
			menu     = "OCR A 12",      -- main menu font
			tooltip  = "OCR A 12",      -- tooltip font
			notify   = "Terminus bold 14",   -- lib notify popup font
			qlaunch  = "Terminus bold 14",   -- quick launch key label font
			logout   = "OCR A bold 14",   -- logout screen labels
			keychain = "Terminus bold 16",   -- key sequence tip font
			title    = "OCR A bold 13", -- widget titles font
			tiny     = "OCR A bold 10", -- smallest font for widgets
			titlebar = "OCR A bold 13", -- client titlebar font
			clock    = "OCR A 12",
			logout   = {
				label   = "OCR A 14", -- logout option labels
				counter = "OCR A 24", -- logout counter
			},
			hotkeys  = {
				main  = "OCR A 10",             -- hotkeys helper main font
				key   = "OCR A 12", -- hotkeys helper key font (use monospace for align)
				title = "OCR A bold 14",        -- hotkeys helper group title font
			},
			player   = {
				main = "Terminus bold 13", -- player widget main font
				time = "Terminus bold 15", -- player widget current time font
			},
			calendar = {
				clock = "OCR A 20", date = "OCR A 13", week_numbers = "OCR A 12", weekdays_header = "OCR A 10",
				days  = "OCR A 10", default = "OCR A 9", focus = "OCR A 13 Bold", controls = "OCR A 12"
			},
		}
		self.cairo_fonts = {
			tag         = { font = "Play", size = 16, face = 1 }, -- tag widget font
			appswitcher = { font = "Play", size = 20, face = 1 }, -- appswitcher widget font
			navigator   = {
				title = { font = "Play", size = 28, face = 1, slant = 0 }, -- window navigation title font
				main  = { font = "Play", size = 22, face = 1, slant = 0 }  -- window navigation  main font
			},
			desktop = {
				textbox = { font = "prototype", size = 24, face = 0 },
			},
		}
	-- Icons
		self.icon = {
			check          = self.path .. "/icons/common/check.svg",
			blank          = self.path .. "/icons/common/blank.svg",
			submenu        = self.path .. "/icons/common/submenu.svg",
			warning        = self.path .. "/icons/common/warning.svg",
			awesome        = self.path .. "/icons/common/awesome.svg",
			system         = self.path .. "/icons/common/system.svg",
			mark           = self.path .. "/icons/common/mark.svg",
			left           = self.path .. "/icons/common/arrow_left.svg",
			right          = self.path .. "/icons/common/arrow_right.svg",
			unknown        = self.path .. "/icons/common/unknown.svg",
			volume         = self.path .. "/icons/volume/volume.png",
			volumelow      = self.path .. "/icons/volume/volume-low.png",
			volumeoff      = self.path .. "/icons/volume/volume-off.png",
			brightness     = self.path .. "/icons/brightness/brightness.png",
			brightnesslow  = self.path .. "/icons/brightness/brightness-low.png",
			brightnessoff  = self.path .. "/icons/brightness/brightness-off.png",
		}
		self.wicon = {
			battery    = self.path .. "/icons/widget/battery.svg",
			wireless   = self.path .. "/icons/widget/wireless.svg",
			monitor    = self.path .. "/icons/widget/monitor.svg",
			audio      = self.path .. "/icons/widget/audio.svg",
			headphones = self.path .. "/icons/widget/headphones.svg",
			brightness = self.path .. "/icons/widget/brightness.svg",
			keyboard   = self.path .. "/icons/widget/keyboard.svg",
			mail       = self.path .. "/icons/widget/mail.svg",
			package    = self.path .. "/icons/widget/package.svg",
			search     = self.path .. "/icons/widget/search.svg",
			mute       = self.path .. "/icons/widget/mute.svg",
			up         = self.path .. "/icons/widget/up.svg",
			down       = self.path .. "/icons/widget/down.svg",
			onscreen   = self.path .. "/icons/widget/onscreen.svg",
			resize     = {
				full       = self.path .. "/icons/widget/resize/full.svg",
				horizontal = self.path .. "/icons/widget/resize/horizontal.svg",
				vertical   = self.path .. "/icons/widget/resize/vertical.svg",
			},
			updates    = {
				normal = self.path .. "/icons/widget/updates/normal.svg",
				silent = self.path .. "/icons/widget/updates/silent.svg",
				weekly = self.path .. "/icons/widget/updates/weekly.svg",
				daily  = self.path .. "/icons/widget/updates/daily.svg",
			},
			logout = {
				logout    = self.path .. "/icons/widget/logout/logout.svg",
				lock      = self.path .. "/icons/widget/logout/lock.svg",
				hibernate = self.path .. "/icons/widget/logout/hibernate.svg",
				poweroff  = self.path .. "/icons/widget/logout/poweroff.svg",
				suspend   = self.path .. "/icons/widget/logout/suspend.svg",
				reboot    = self.path .. "/icons/widget/logout/reboot.svg",
				switch    = self.path .. "/icons/widget/logout/switch.svg",
			},
		}
	-- Service
		self.service = {}
		self.service.navigator = {
			border_width = 1,  -- window placeholder border width
			gradstep     = 60, -- window placeholder background stripes width
			marksize = {       -- window information plate size
				width  = 160, -- width
				height = 80,  -- height
				r      = 20   -- corner roundness
			},
			linegap   = 32, -- gap between two lines on window information plate
			timeout   = 1,  -- highlight duration
			notify    = {}, -- lib notify style (see self.float.notify)
			titlefont = self.cairo_fonts.navigator.title, -- first line font on window information plate
			font      = self.cairo_fonts.navigator.main,  -- second line font on window information plate
			num = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "F1", "F3", "F4", "F5" },
			color = {
				border = self.color.main,         -- window placeholder border color
				mark = self.color.gray,           -- window information plate background color
				text = self.color.wibox,          -- window information plate text color
				fbg1 = self.color.main .. "40",   -- first background color for focused window placeholder
				fbg2 = self.color.main .. "20",   -- second background color for focused window placeholder
				hbg1 = self.color.urgent .. "40", -- first background color for highlighted window placeholder
				hbg2 = self.color.urgent .. "20", -- second background color for highlighted window placeholder
				bg1  = self.color.gray .. "40",   -- first background color for window placeholder
				bg2  = self.color.gray .. "20"    -- second background color for window placeholder
			}
		}
	-- Layout tips
		self.service.navigator.keytip = {}
		self.service.navigator.keytip["base"] = { geometry = { width = 600 }, exit = true }
		self.service.navigator.keytip["fairv"] = { geometry = { width = 600}, exit = true }
		self.service.navigator.keytip["fairh"] = self.service.navigator.keytip["fairv"]
		self.service.navigator.keytip["spiral"] = self.service.navigator.keytip["fairv"]
		self.service.navigator.keytip["dwindle"] = self.service.navigator.keytip["fairv"]
		self.service.navigator.keytip["tile"] = { geometry = { width = 600 }, exit = true }
		self.service.navigator.keytip["tileleft"]   = self.service.navigator.keytip["tile"]
		self.service.navigator.keytip["tiletop"]    = self.service.navigator.keytip["tile"]
		self.service.navigator.keytip["tilebottom"] = self.service.navigator.keytip["tile"]
		self.service.navigator.keytip["cornernw"] = { geometry = { width = 600 }, exit = true }
		self.service.navigator.keytip["cornerne"] = self.service.navigator.keytip["cornernw"]
		self.service.navigator.keytip["cornerse"] = self.service.navigator.keytip["cornernw"]
		self.service.navigator.keytip["cornersw"] = self.service.navigator.keytip["cornernw"]
		self.service.navigator.keytip["magnifier"] = { geometry = { width = 600}, exit = true }
		self.service.navigator.keytip["grid"] = { geometry = { width = 1400 }, column = 2, exit = true }
		self.service.navigator.keytip["usermap"] = { geometry = { width = 1400 }, column = 2, exit = true }
	-- Logout
		self.service.logout = {
			button_size               = { width = 128, height = 128 },
			icon_margin               = 22,
			text_margin               = 18,
			button_spacing            = 64,
			counter_top_margin        = 800,
			label_font                = self.fonts.logout.label,
			counter_font              = self.fonts.logout.counter,
			keytip                    = { geometry = { width = 400 } },
			graceful_shutdown         = true,
			double_key_activation     = true,
			client_kill_timeout       = 5,
			icons                     = {},
			color                     = self.color, -- colors (main used)
		}
		self.service.logout.icons.logout = self.wicon.logout.logout
		self.service.logout.icons.lock = self.wicon.logout.lock
		self.service.logout.icons.hibernate = self.wicon.logout.hibernate
		self.service.logout.icons.poweroff = self.wicon.logout.poweroff
		self.service.logout.icons.suspend = self.wicon.logout.suspend
		self.service.logout.icons.reboot = self.wicon.logout.reboot
		self.service.logout.icons.switch = self.wicon.logout.switch
	-- Desktop file parser
		self.service.dfparser = {
			-- list of path to check desktop files
			desktop_file_dirs = {
				'/usr/share/applications/',
				'/usr/local/share/applications/',
				'~/.local/share/applications',
			},
			-- icon theme settings
			icons = {
				theme         = self.homedir .. "/.icons/ACYLS", -- user icon theme path
				df_icon       = self.icon.system, -- default (fallback) icon
				custom_only   = true, -- use icons from user theme (no system fallback like 'hicolor' allowed) only
				scalable_only = true  -- use vector(svg) icons (no raster icons allowed) only
			},
			wm_name = nil -- window manager name
		}
	-- Menu
		-- Menu
			self.menu = {
				border_width      = self.border_width, -- menu border width
				screen_gap        = self.useless_gap + self.border_width, -- minimal space from screen edge on placement
				height            = 32,  -- menu item height
				width             = 250, -- menu item width
				icon_margin       = { 8, 8, 8, 8 }, -- space around left icon in menu item
				ricon_margin      = { 9, 9, 9, 9 }, -- space around right icon in menu item
				nohide            = false, -- do not hide menu after item activation
				auto_expand       = true,  -- show submenu on item selection (without item activation)
				auto_hotkey       = false, -- automatically set hotkeys for all menu items
				select_first      = true,  -- auto select first item when menu shown
				hide_timeout      = 1,     -- auto hide timeout (auto hide disables if this set to 0)
				font              = self.fonts.menu,   -- menu font
				submenu_icon      = self.icon.submenu, -- icon for submenu items
				keytip            = { geometry = { width = 400 } }, -- hotkeys helper settings
				shape             = nil, -- wibox shape
				action_on_release = false, -- active menu item on mouse release instead of press
				svg_scale         = { false, false }, -- use vector scaling for left, right icons in menu item
			}
			self.menu.color = {
				border       = self.color.wibox,     -- menu border color
				text         = self.color.text,      -- menu text color
				highlight    = self.color.highlight, -- menu text and icons color for selected item
				main         = self.color.main,      -- menu selection color
				wibox        = self.color.wibox,     -- menu background color
				submenu_icon = self.color.icon,      -- submenu icon color
				right_icon   = nil,                  -- right icon color in menu item
				left_icon    = nil,                  -- left icon color in menu item
			}
		-- Gauge
			-- init
				self.gauge = { tag = {}, task = {}, icon = {}, audio = {}, monitor = {}, graph = {} }
			-- Bar
				self.gauge.graph.bar = {
					color = self.color -- colors (main used)
				}
			-- Plain monitor (label and progressbar below)
				self.gauge.monitor.plain = {
					width      = 50,                          -- widget width
					font       = self.cairo_fonts.tag,        -- widget font
					text_shift = 19,                          -- shift from upper border of widget to lower border of text
					label      = "MON",                       -- widget text
					step       = 0.05,                        -- progressbar painting step
					line       = { height = 4, y = 27 },      -- progressbar style
					color      = self.color                   -- colors (main used)
				}
			-- Simple monitor with sigle vertical dashed progressbar
				self.gauge.monitor.dash = {
					width = 11,         -- widget width
					color = self.color, -- colors (main used)
					-- progressbar line style
					line = {
						num    = 5, -- number of chunks in progressbar
						height = 3  -- height of progressbar chunk
					},
				}
			-- Icon indicator (decoration in some panel widgets)
				self.gauge.icon.single = {
					icon        = self.icon.system,  -- default icon
					is_vertical = false,             -- use vertical gradient (horizontal if false)
					step        = 0.02,              -- icon painting step
					color       = self.color         -- colors (main used)
				}
			-- Double icon indicator
				self.gauge.icon.double = {
					icon1       = self.icon.system,  -- first icon
					icon2       = self.icon.system,  -- second icon
					is_vertical = true,              -- use vertical gradient (horizontal if false)
					igap        = 4,                 -- gap between icons
					step        = 0.02,              -- icon painting step
					color       = self.color         -- colors (main used)
				}
			-- Double value monitor (double progressbar with icon)
				self.gauge.monitor.double = {
					icon     = self.icon.system, -- default icon
					width    = 90,               -- widget width
					dmargin  = { 10, 0, 0, 0 },  -- margins around progressbar area
					color    = self.color,       -- colors (main used)
					line = {
						width = 4, -- progressbar height
						v_gap = 6, -- space between progressbar
						gap = 4,   -- gap between progressbar dashes
						num = 5    -- number of progressbar dashes
					},
				}
			-- Separator (decoration used on panel, menu and some other widgets)
				self.gauge.separator = {
					marginv = { 3, 0, 5, 10 }, -- margins for vertical separator
					marginh = { 0, 0, 0, 0 }, -- margins for horizontal separator
					color  = self.color       -- color (secondary used)
				}
			-- Step like dash bar (user for volume widgets)
				self.gauge.graph.dash = {
					bar = {
						width = 4, -- dash element width
						num   = 10 -- number of dash elements
					},
					color = self.color -- color (main used)
				}
			-- Volume indicator
				self.gauge.audio = {
					width   = 80,               -- widget width
					dmargin = { 0, 0, 4, 4 },  -- margins around dash area
					icon    = self.wicon.audio, -- volume icon
					-- colors
					color   = { icon = self.color.main, mute = self.color.icon },
					-- dash style
					dash = { bar = { num = 10, width = 3 } , plain = false , aperture = true },
				}
			-- Dotcount (used in minitray widget)
				self.gauge.graph.dots = {
					column_num   = { 3, 5 },  -- amount of dot columns (min/max)
					row_num      = 3,         -- amount of dot rows
					dot_size     = 5,         -- dots size
					dot_gap_h    = 2,         -- horizontal gap between dot (with columns number it'll define widget width)
					color        = self.color -- colors (main used)
				}
			-- Circle shaped monitor
				self.gauge.monitor.circle = {
					width        = 32,        -- widget width
					line_width   = 4,         -- width of circle
					iradius      = 5,         -- radius for center point
					radius       = 11,        -- circle radius
					step        = 0.05,       -- circle painting step
					color        = self.color -- colors (main used)
				}
			-- Tag (base element of taglist)
				self.gauge.tag = {
					icon       = nil,
					width      = 85,                  -- widget width
					show_min   = false,                -- indicate minimized apps by color
					text_shift = 20,                   -- shift from upper border of widget to lower border of text
					color      = self.color,           -- colors (main used)
					font       = self.cairo_fonts.tag, -- font
					-- apps indicator
					point = {
						width = 80, -- apps indicator total width
						height = 3, -- apps indicator total height
						gap = 24,   -- shift from upper border of widget to apps indicator
						dx = 5      -- gap between apps indicator parts
					},
				}
			-- Task (base element of tasklist)
				self.gauge.task = {
					width = 65,
					text_shift = 29,
					color      = self.color,
					font       = self.cairo_fonts.tag,
					point      = { size = 3, space = 5, gap = 4 },
					underline  = { height = 10, thickness = 3, gap = 34, dh = 0 },
				}
		-- Widgets
			-- Wrapper init
				self.widget = {}
				self.widget.wrapper = {
					layoutbox   = { 3, 0, 3, 6 },
					textclock   = { 3, 0, 0, 4 },
					volume      = { 0, 0, 0, 4 },
					microphone  = { 0, 0, 0, 4 },
					keyboard    = { 3, 0, 0, 4 },
					mail        = { 5, 0, 0, 4 },
					tray        = { 0, 0, 3, 7 },
					cpu         = { 3, 2, 3, 7 },
					ram         = { 2, 0, 3, 7 },
					battery     = { 3, 3, 3, 7 },
					network     = { 0, 0, 0, 4 },
					updates     = { 0, 0, 0, 4 },
					taglist     = { 2, 2, -4, 4 },
					tasklist    = { 10, 0, -9, -1 },
				}
			-- Text clock
				self.widget.textclock = {
					font    = self.fonts.clock,          -- font
					tooltip = {},                        -- redflat tooltip style (see theme.float.tooltip)
					color   = { text = self.color.icon } -- colors
				}
			-- Bin clock
				self.widget.binclock = {
					width   = 52,           -- widget width
					tooltip = {},           -- redflat tooltip style (see theme.float.tooltip)
					dot     = { size = 5 }, -- mark size
					color   = self.color,   -- colors (main used)
				}
			-- Battery
				self.widget.battery = {
					notify  = { icon = self.wicon.battery, color = self.color.main },   -- redflat notify style (see theme.float.notify)
					levels  = { 0.05, 0.1, 0.15, 0.2, 0.25, 0.30 }
				}
			-- Minitray
				self.widget.minitray = {
					dotcount     = {}, -- lib dotcount style (see self.gauge.graph.dots)
					border_width = 1,  -- floating widget border width
					geometry     = { height = 28 }, -- floating widget size
					screen_gap   = 1 * self.useless_gap, -- minimal space from screen edge on floating widget placement
					shape        = nil, -- wibox shape
					color        = { wibox = self.color.wibox, border = self.color.wibox },
					-- function to define floating widget position when shown
					set_position = function(wibox)
						local geometry = { x = mouse.screen.workarea.x + mouse.screen.workarea.width,
										y = mouse.screen.workarea.y + mouse.screen.workarea.height }
						wibox:geometry(geometry)
					end,
				}
			-- Pulse
				self.widget.pulse = {
					notify = {},  -- redflat notify style (see theme.float.notify)
					widget = nil, -- audio gauge (usually setted by rc file)
					audio  = {}   -- style for gauge
				}
			-- Keyboard
				self.widget.keyboard = {
					icon         = self.wicon.keyboard,  -- widget icon
					micon        = self.icon,         -- some common menu icons
					layout_color = { self.color.icon, self.color.main },
					menu = { width  = 180, color  = { right_icon = self.color.icon }, nohide = true }
				}
			-- Mail
				self.widget.mail = {
					icon        = self.path .. "/widget/mail.svg",  -- widget icon
					notify      = {},                -- redflat notify style (see theme.float.notify)
					need_notify = true,              -- show notification on new mail
					firstrun    = true,              -- check mail on wm start/restart
					color       = self.color,        -- colors (main used)
				}
			-- Updates
				self.widget.updates = {
					icon        = self.icon.system,  -- widget icon
					notify      = {},                -- lib notify style (see self.float.notify)
					need_notify = true,              -- show notification on updates
					firstrun    = true,              -- check updates on wm start/restart
					color       = self.color,        -- colors (main used)
					keytip      = { geometry = { width = 400 } },
					tooltip     = { base = {}, state = { timeout = 1 } },
					wibox = {
						geometry     = { width = 250, height = 160 }, -- widget size
						border_width = 1,                             -- widget border width
						title_font   = self.fonts.title,              -- widget title font
						tip_font     = self.fonts.tiny,               -- widget state tip font
						separator    = {},                            -- lib separator style (see self.gauge.separator)
						shape        = nil,                           -- wibox shape
						set_position = nil,                           -- set_position
						-- wibox icons
						icon         = {
							package = self.icon.system,                   -- main wibox image
							close   = self.path .. "/icons/titlebar/close.svg", -- close button
							normal  = self.icon.system,                   -- regular notification
							daily   = self.icon.system,                   -- defer notification for day
							weekly  = self.icon.system,                   -- defer notification for 7 day
							silent  = self.icon.system,                   -- disable notification
						},
						-- widget areas height
						height = {
							title = 28,  -- titlebar
							state = 34,  -- control icon area
						},
						-- widget element margins
						margin = {
							close = { 0, 0, 6, 6 },         -- close button
							title = { 16 + 2*6, 16, 4, 0 }, -- titlebar area
							state = { 4, 4, 4, 12 },        -- control icon area
							image = { 0, 0, 2, 4 },         -- main wibox image area
						},
					}
				}
			-- Layoutbox
				-- init
					self.widget.layoutbox = {
						micon = self.icon,  -- some common menu icons (used: 'blank', 'check')
						color = self.color  -- colors (main used)
					}
				-- layout icons
					self.widget.layoutbox.icon = {
						floating          = self.path .. "/icons/layouts/floating.svg",
						max               = self.path .. "/icons/layouts/max.svg",
						fullscreen        = self.path .. "/icons/layouts/fullscreen.svg",
						termfair          = self.path .. "/icons/layouts/termfair.svg",
						cascade           = self.path .. "/icons/layouts/cascade.svg",
						tilebottom        = self.path .. "/icons/layouts/tilebottom.svg",
						tileleft          = self.path .. "/icons/layouts/tileleft.svg",
						tile              = self.path .. "/icons/layouts/tile.svg",
						tiletop           = self.path .. "/icons/layouts/tiletop.svg",
						dwindle           = self.path .. "/icons/layouts/dwindle.svg",
						fairv             = self.path .. "/icons/layouts/fairv.svg",
						fairh             = self.path .. "/icons/layouts/fairh.svg",
						grid              = self.path .. "/icons/layouts/grid.svg",
						usermap           = self.path .. "/icons/layouts/map.svg",
						cascade           = self.path .. "/icons/layouts/cascade.svg",
						cascadetile       = self.path .. "/icons/layouts/cascadetile.svg",
						magnifier         = self.path .. "/icons/layouts/magnifier.svg",
						spiral            = self.path .. "/icons/layouts/spiral.svg",
						cornerne          = self.path .. "/icons/layouts/cornerne.svg",
						cornernw          = self.path .. "/icons/layouts/cornernw.svg",
						cornerse          = self.path .. "/icons/layouts/cornerse.svg",
						cornersw          = self.path .. "/icons/layouts/cornersw.svg",
						centerfair        = self.path .. "/icons/layouts/centerfair.svg",
						centerwork        = self.path .. "/icons/layouts/centerwork.svg",
						centerworkh       = self.path .. "/icons/layouts/centerworkh.svg",
						unknown           = self.icon.unknown,  -- this one used as fallback
					}
				-- lib menu style (see self.menu)
					self.widget.layoutbox.menu = {
						icon_margin  = { 8, 12, 8, 8 },
						width        = 260,
						auto_hotkey  = true,
						nohide       = false,
						color        = { right_icon = self.color.icon, left_icon = self.color.icon }
					}
				-- aliases for layout names (displayed in menu and tooltip)
					self.widget.layoutbox.name_alias = {
						floating          = "Floating",
						fullscreen        = "Fullscreen",
						max               = "Maximized",
						grid              = "Grid",
						usermap           = "User Map",
						tile              = "Tile Right",
						tileleft          = "Tile Left",
						tiletop           = "Tile Top",
						tilebottom        = "Tile Bottom",
						termfair          = "Fair Equal",
						fairh             = "Fair Horizontal",
						fairv             = "Fair Vertical",
						dwindle           = "Dwindle",
						centerwork        = "Center Vertical",
						centerworkh       = "Center Horizontal",
						centerfair        = "Center Tile",
						cascade           = "Cascade",
						cascadetile       = "Tile Cascade",
						magnifier         = "Magnifier",
						spiral            = "Spiral",
						cornerne          = "Corner NE",
						cornernw          = "Corner NW",
						cornerse          = "Corner SE",
						cornersw          = "Corner SW",
					}	
					self.gauge.tag.icon = self.widget.layoutbox.icon			
		-- Tasklist
			-- main settings
			self.widget.tasklist = {
				custom_icon = false, -- use custom applications icons (not every gauge task widget support icons)
				iconnames   = {},    -- icon name aliases for custom applications icons
				widget      = nil,   -- task gauge widget (usually setted by rc file)
				width       = 40,    -- width of task element in tasklist
				char_digit  = 4,     -- number of characters in task element text
				need_group  = true,  -- group application instances into one task element
				parser      = {},    -- redlat desktop file parser settings (see self.service.dfparser)
				task_margin = { 3, 3, 0, 0 },      -- margins around task element
				task        = self.gauge.task -- style for task gauge widget
			}
			-- menu settings
			self.widget.tasklist.winmenu = {
				micon          = self.icon, -- some common menu icons
				titleline      = {
					font = self.fonts.title, -- menu title height
					height = 25              -- menu title font
				},
				tagline              = { height = 30 },              -- tag line height
				tag_iconsize         = { width = 16, height = 16 },  -- tag line marks size
				enable_screen_switch = false,                        -- screen option in menu
				enable_tagline       = false,                        -- tag marks instead of menu options
				stateline            = { height = 30 },              -- height of menu item with state icons
				state_iconsize       = { width = 18, height = 18 },  -- size for state icons
				layout_icon          = self.widget.layoutbox.icon,   -- list of layout icons
				separator            = { marginh = { 3, 3, 5, 5 } }, -- lib separator style (see self.gauge.separator)
				color                = self.color,                   -- colors (main used)
				menu = { width = 200, color = { right_icon = self.color.icon }, ricon_margin = { 9, 9, 9, 9 } },
				tagmenu = { width = 160, color = { right_icon = self.color.icon, left_icon = self.color.icon }, icon_margin = { 9, 9, 9, 9 } },
				hide_action = { min = true, move = true, max = false, add = false, floating = false, sticky = false, ontop = false, below = false, maximized = false },
			}
			-- menu icons
			self.widget.tasklist.winmenu.icon = {
				floating  = self.path .. "/icons/titlebar/floating.svg",
				sticky    = self.path .. "/icons/titlebar/pin.svg",
				ontop     = self.path .. "/icons/titlebar/ontop.svg",
				below     = self.path .. "/icons/titlebar/below.svg",
				close     = self.path .. "/icons/titlebar/close.svg",
				minimize  = self.path .. "/icons/titlebar/minimize.svg",
				maximized = self.path .. "/icons/titlebar/maximized.svg",
				tag       = self.icon.mark,    -- tag line mark
				unknown   = self.icon.unknown, -- this one used as fallback
			}
			-- multiline task element tip
			self.widget.tasklist.tasktip = {
				border_width = 2,                -- tip border width
				margin       = { 10, 10, 5, 5 }, -- margins around text in tip lines
				timeout      = 0.5,              -- hide timeout
				shape        = nil,              -- wibox shape
				sl_highlight = false,            -- highlight application state when it's single line tip
				color = self.color,              -- colors (main used)
			}
			-- Mail
			self.widget.mail = {
				icon        = self.wicon.mail,  -- widget icon
				notify      = {},                -- redflat notify style (see theme.float.notify)
				need_notify = true,              -- show notification on new mail
				firstrun    = true,              -- check mail on wm start/restart
				color       = self.color,        -- colors (main used)
			}	
		-- Floating
			-- Init
				self.float = { decoration = {} }
			-- Brightness control
				self.float.brightness = {
					notify = {},  -- lib notify style (see self.float.notify)
				}
			-- Client menu
				self.float.clientmenu = {
					actionline      = { height = 28 },             -- height of menu item with action icons
					action_iconsize = { width = 18, height = 18 }, -- size for action icons
					stateline       = { height = 30 },             -- height of menu item with state icons
					tagline      = { height = 30 },             -- tag line height
					tag_iconsize = { width = 16, height = 16 }, -- tag line marks size
					-- lib separator style(see self.gauge.separator)
					separator       = { marginh = { 3, 3, 5, 5 }, marginv = { 3, 3, 3, 3 } },
					-- same elements as for task list menu
					icon                 = self.widget.tasklist.winmenu.icon,
					micon                = self.widget.tasklist.winmenu.micon,
					layout_icon          = self.widget.layoutbox.icon,
					menu                 = self.widget.tasklist.winmenu.menu,
					state_iconsize       = self.widget.tasklist.winmenu.state_iconsize,
					tagmenu              = self.widget.tasklist.winmenu.tagmenu,
					hide_action          = self.widget.tasklist.winmenu.hide_action,
					enable_screen_switch = false,
					enable_tagline       = false,
					color                = self.color,
				}
			-- Audio player
				self.float.player = {
					geometry        = { width = 490, height = 130 }, -- widget size
					screen_gap      = 2 * self.useless_gap,          -- minimal space from screen edge on floating widget placement
					border_margin   = { 15, 15, 15, 15 },            -- margins around widget content
					elements_margin = { 15, 0, 0, 0 },               -- margins around main player elements (exclude cover art)
					controls_margin = { 0, 0, 14, 6 },               -- margins around control player elements
					volume_margin   = { 0, 0, 0, 3 },                -- margins around volume element
					buttons_margin  = { 0, 0, 3, 3 },                -- margins around buttons area
					pause_margin    = { 12, 12, 0, 0 },              -- margins around pause button
					line_height     = 26,                            -- text lines height
					bar_width       = 6,                             -- progressbar width
					volume_width    = 50,                            -- volume element width
					titlefont       = self.fonts.player.main,        -- track font
					artistfont      = self.fonts.player.main,        -- artist/album font
					timefont        = self.fonts.player.time,        -- track progress time font
					border_width    = 1,                             -- widget border width
					timeout         = 1,                             -- widget update timeout
					set_position    = nil,                           -- set_position
					shape           = nil,                           -- wibox shape
					color           = self.color,                    -- color (main used)
					-- volume dash style (see self.gauge.graph.dash)
					dashcontrol  = { color = self.color, bar = { num = 7 } },
					-- progressbar style (see self.gauge.graph.bar)
					progressbar  = { color = self.color },
				}
				self.float.player.icon = {
					cover   = self.path .. "/icons/player/cover.svg",
					loop    = self.path .. "/icons/player/loop.svg",
					shuffle = self.path .. "/icons/player/shuffle.svg",
					next_tr = self.path .. "/icons/player/next.svg",
					prev_tr = self.path .. "/icons/player/previous.svg",
					play    = self.path .. "/icons/player/play.svg",
					pause   = self.path .. "/icons/player/pause.svg"
				}
			-- Top processes
				self.float.top = {
					geometry      = { width = 460, height = 400 }, -- widget size
					screen_gap    = 2 * self.useless_gap,          -- minimal space from screen edge on floating widget placement
					border_margin = { 20, 20, 10, 0 },             -- margins around widget content
					button_margin = { 140, 140, 18, 18 },          -- margins around kill button
					title_height  = 40,                            -- widget title height
					border_width  = self.border_width,                             -- widget border width
					bottom_height = 70,                            -- kill button area height
					list_side_gap = 8,                             -- left/rigth borger margin for processes list
					title_font    = self.fonts.title,              -- widget title font
					timeout       = 2,                             -- widget update timeout
					shape         = nil,                           -- wibox shape
					color         = self.color,                    -- color (main used)
			
					-- list columns width
					labels_width  = { num = 30, cpu = 70, mem = 120 },
			
					-- redflat key tip settings
					keytip        = { geometry = { width = 400 } },
			
					-- placement function
					set_position  = nil,
				}
				self.float.top.set_position  = function(wibox)
					local geometry = { x = mouse.screen.workarea.x + mouse.screen.workarea.width,
									y = 0 }
					wibox:geometry(geometry)
				end
			-- Application runner
				self.float.apprunner = {
					itemnum       = 6,                                 -- number of visible items
					geometry      = { width = 620, height = 480 },     -- widget size
					border_margin = { 24, 24, 24, 24 },                -- margin around widget content
					icon_margin   = { 8, 16, 0, 0 },                   -- margins around widget icon
					title_height  = 48,                                -- height of title (promt and icon) area
					prompt_height = 35,                                -- prompt line height
					title_icon    = self.icon.system,                  -- widget icon
					border_width  = 1,                                 -- widget border width
					parser        = {},                                -- desktop file parser settings (see self.service.dfparser)
					field         = nil,                               -- lib text field style(see self.float.decoration.field)
					shape         = nil,                               -- wibox shape
					color         = self.color,                        -- colors (main used)
					name_font     = self.fonts.title,     -- application title font
					comment_font  = self.fonts.main,      -- application comment font
					list_text_vgap   = 4,                 -- space between application title and comment
					list_icon_margin = { 6, 12, 6, 6 },   -- margins around applications icons
					dimage           = self.icon.unknown, -- fallback icon for applications
					keytip        = { geometry = { width = 400 } }, -- lib key tip settings
				}
			-- Application switcher
				self.float.appswitcher = {
					wibox_height    = 240, -- widget height
					label_height    = 28,  -- height of the area with application mark(key)
					title_height    = 40,  -- height of widget title line (application name and tag name)
					icon_size       = 96,  -- size of the application icon in preview area
					preview_gap     = 20,  -- gap between preview areas
					shape           = nil, -- wibox shape
					-- desktop file parser settings (see self.service.dfparser)
					parser = {
						desktop_file_dirs = awful.util.table.join(
							self.service.dfparser.desktop_file_dirs,
							{ '~/.local/share/applications-fake' }
						)
					},
					border_margin   = { 10, 10, 0, 10 },  -- margins around widget content
					preview_margin  = { 15, 15, 15, 15 }, -- margins around application preview
					preview_format  = 16 / 10,            -- preview acpect ratio
					title_font      = self.fonts.title,   -- font of widget title line
					border_width    = 1,                  -- widget border width
					update_timeout  = 1 / 12,             -- application preview update timeout
					min_icon_number = 4,                  -- this one will define the minimal widget width
														-- (widget will not shrink if number of apps items less then this)
					color           = self.color,         -- colors (main used)
					font            = self.cairo_fonts.appswitcher, -- font of application mark(key)
					-- lib key tip settings
					keytip         = { geometry = { width = 400 }, exit = true },
				}
				self.float.appswitcher.color.preview_bg = self.color.main .. "12"
				self.float.appswitcher.hotkeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12" }
			-- Quick launcher
				self.float.qlaunch = {
					geometry      = { width = 1400, height = 170 }, -- widget size
					border_width  = 1,                   -- widget border width
					border_margin = { 5, 5, 12, 15 },    -- margins around widget content
					notify        = {},                  -- lib notify style (see self.float.notify)
					shape         = nil,                 -- wibox shape
					recoloring    = false,               -- apply lib recoloring feature on application icons
					label_font    = self.fonts.qlaunch,  -- font of application mark(key)
					color         = self.color,          -- colors (main used)
					df_icon       = self.icon.system,    -- fallback application icon
					no_icon       = self.icon.unknown,   -- icon for unused application slot
					-- desktop file parser settings (see self.service.dfparser)
					parser = {
						desktop_file_dirs = awful.util.table.join(
							self.service.dfparser.desktop_file_dirs,
							{ '~/.local/share/applications-fake' }
						)
					},
					appline       = {
						iwidth = 140,           -- application item width
						im = { 5, 5, 0, 0 },    -- margins around application item area
						igap = { 0, 0, 5, 15 }, -- margins around application icon itself (will affect icon size)
						lheight = 26            -- height of application mark(key) area
					},
					state         = {
						gap = 5,    -- space between application state marks
						radius = 5, -- application state mark radius
						size = 10,  -- application state mark size
						height = 14 -- height of application state marks area
					},
					-- lib key tip settings
					keytip        = { geometry = { width = 600 } },
					-- file to store widget data
					-- this widget is rare one which need to keep settings between sessions
					configfile      = os.getenv("HOME") .. "/.cache/awesome/applist",
				}
			-- Hotkeys helper
				self.float.hotkeys = {
					geometry      = { width = mouse.screen.workarea.width * 0.95, height = mouse.screen.workarea.height * 0.95 }, -- widget size
					border_margin = { 20, 20, 8, 10 },              -- margins around widget content
					border_width  = 1,                              -- widget border width
					delim         = "   ",                          -- text separator between key and description
					tspace        = 2,                              -- space between lines in widget title
					is_align      = true,                           -- align keys description (monospace font required)
					separator     = { marginh = { 0, 0, 3, 6 } },   -- lib separator style (see self.gauge.separator)
					font          = self.fonts.hotkeys.main,        -- keys description font
					keyfont       = self.fonts.hotkeys.key,         -- keys font
					titlefont     = self.fonts.hotkeys.title,       -- widget title font
					shape         = nil,                            -- wibox shape
					color         = self.color,                     -- colors (main used)
					heights       = {
						key   = 20, -- hotkey tip line height
						title = 22  -- group title height
					},
				}
			-- Titlebar helper
				self.float.bartip = {
					geometry      = { width = 260, height = 40 }, -- widget size
					border_margin = { 10, 10, 10, 10 },           -- margins around widget content
					border_width  = 1,                            -- widget border widthj
					font          = self.fonts.title,             -- widget font
					set_position  = nil,                          -- placement function
					shape         = nil,                          -- wibox shape
					names         = { "Mini", "Plain", "Full" },  -- titlebar layout names
					color         = self.color,                   -- colors (main used)
					-- margin around widget elements
					margin        = { icon = { title = { 10, 10, 8, 8 }, state = { 10, 10, 8, 8 } } },
					-- widget icons
					icon          = {
						title    = self.path .. "/icons/titlebar/title.svg",
						active   = self.path .. "/icons/titlebar/active.svg",
						hidden   = self.path .. "/icons/titlebar/hidden.svg",
						disabled = self.path .. "/icons/titlebar/disabled.svg",
						absent   = self.path .. "/icons/titlebar/absent.svg",
						unknown  = self.icon.unknown,
					},
					-- lib key tip settings
					keytip        = { geometry = { width = 540 } },
				}
			-- Floating window control helper
				self.float.control = {
					geometry      = { width = 260, height = 48 }, -- widget size
					border_margin = { 10, 10, 10, 10 },           -- margins around widget content
					border_width  = 1,                            -- widget border widthj
					font          = self.fonts.title,             -- widget font
					steps         = { 1, 10, 25, 50, 200 },       -- move/resize step
					default_step  = 3,                            -- select default step by index
					onscreen      = true,                         -- no off screen for window placement
					set_position  = nil,                          -- widget placement function
					shape         = nil,                          -- wibox shape
					color         = self.color,                   -- colors (main used)
					-- margin around widget elements
					margin = { icon = { onscreen = { 10, 10, 8, 8 }, mode = { 10, 10, 8, 8 } } },
					-- widget icons
					icon = {
						onscreen = self.wicon.onscreen,
						resize = {
							self.wicon.resize.full,
							self.wicon.resize.horizontal,
							self.wicon.resize.vertical,
						},
					},
					keytip = { geometry = { width = 540 } },
				}
			-- Key sequence tip
				self.float.keychain = {
					geometry        = { width = 250, height = 56 }, -- default widget size
					font            = self.fonts.keychain,          -- widget font
					border_width    = 2,                            -- widget border width
					shape           = nil,                          -- wibox shape
					color           = self.color,                   -- colors (main used)
					keytip          = { geometry = { width = 600 }, column = 1 },
				}
			-- Tooltip
				self.float.tooltip = {
					timeout      = 0,                  -- show delay
					shape        = nil,                -- wibox shapea
					font         = self.fonts.tooltip, -- widget font
					border_width = 2,                  -- widget border width
					set_position = nil,                -- function to setup tooltip position when shown
					color        = self.color,         -- colors (main used)
					padding      = { vertical = 3, horizontal = 6 },
				}
			-- Floating prompt
				self.float.prompt = {
					geometry     = { width = 620, height = 120 }, -- widget size
					border_width = 1,                             -- widget border width
					margin       = { 20, 20, 40, 40 },            -- margins around widget content
					field        = nil,                           -- lib text field style (see self.float.decoration.field)
					shape        = nil,                           -- wibox shape
					naughty      = {},                            -- awesome notification style
					color        = self.color,                    -- colors (main used)
				}
			-- Calendar
				self.float.calendar = {
					geometry                  = { width = 320, height = 280 },
					margin                    = { 4, 8, 2, 2 },
					controls_margin           = { 0, 0, 5, 0 },
					calendar_item_margin      = { 10, 10, 2, 2 },
					spacing                   = { separator = 15, datetime = 5, controls = 5, calendar = 6 },
					controls_icon_size        = { width = 18, height = 18 },
					separator                 = { marginh = { 0, 0, 10, 10 } },
					border_width              = self.border_width,
					days                      = {
						weeknumber = { fg = self.color.gray, bg = "transparent" },
						weekday    = { fg = self.color.gray, bg = "transparent" },
						weekend    = { fg = self.color.highlight, bg = self.color.gray },
						today      = { fg = self.color.highlight, bg = self.color.main },
						day        = { fg = self.color.text, bg = "transparent" },
						default    = { fg = "white", bg = "transparent" }
					},
					fonts                     = self.fonts.calendar,
					icon                      = { next = self.icon.right, prev = self.icon.left },
					clock_format              = "%H:%M",
					date_format               = "%A, %d. %B",
					clock_refresh_seconds     = 60,
					weeks_start_sunday        = false,
					show_week_numbers         = false,
					show_weekday_header       = true,
					long_weekdays             = false,
					weekday_name_replacements = {},
					screen_gap                = 0,
					set_position              = nil,
					shape                     = nil,
					screen_gap                = 2 * self.useless_gap, -- screen edges gap on placement
					color = {
						border    = self.color.border,
						wibox     = self.color.wibox,
						icon      = self.color.icon,
						main      = "transparent",
						highlight = self.color.main,
						gray      = self.color.gray,
						text      = self.color.text,
					}
				}
			-- Notify (lib notification widget)
				self.float.notify = {
					geometry        = { width = 484, height = 106 }, -- widget size
					screen_gap      = 2 * self.useless_gap,          -- screen edges gap on placement
					border_margin   = { 20, 20, 20, 20 },            -- margins around widget content
					elements_margin = { 20, 0, 10, 10 },             -- margins around main elements (text and bar)
					font            = self.fonts.notify,             -- widget font
					icon            = self.icon.warning,             -- default widget icon
					border_width    = 0,                             -- widget border width
					timeout         = 5,                             -- hide timeout
					shape           = nil,                           -- wibox shape
					color           = self.color,                    -- colors (main used)
					-- progressbar is optional element used for some notifications
					bar_width       = 8,                             -- progressbar width
					progressbar     = {},                            -- lib progressbar style (see self.gauge.graph.bar)
					-- placement function
					set_position = function(wibox)
						wibox:geometry({ x = mouse.screen.workarea.x + mouse.screen.workarea.width, y = mouse.screen.workarea.y })
					end,
				}
			-- Decoration (various elements that used as component for other widgets) style
				self.float.decoration.button = {
					color = self.color  -- colors (secondary used)
				}
				self.float.decoration.field = {
					color = self.color  -- colors (secondary used)
				}
		-- Titlebar
			self.titlebar = {}
			self.titlebar.base = {
				position      = "top",               -- titlebar position
				font          = self.fonts.titlebar, -- titlebar font
				border_margin = { 0, 0, 0, 4 },      -- margins around titlebar active area
				color         = self.color,          -- colors (main used)
			}
			-- application state marks settings
			self.titlebar.mark = {
				color = self.color, -- colors (main used)
			}
			-- application control icon settings
			self.titlebar.icon = {
				color = self.color, -- colors (main used)
				-- icons list
				list = {
					focus     = self.path .. "/icons/titlebar/focus.svg",
					floating  = self.path .. "/icons/titlebar/floating.svg",
					ontop     = self.path .. "/icons/titlebar/ontop.svg",
					below     = self.path .. "/icons/titlebar/below.svg",
					sticky    = self.path .. "/icons/titlebar/pin.svg",
					maximized = self.path .. "/icons/titlebar/maximized.svg",
					minimized = self.path .. "/icons/titlebar/minimize.svg",
					close     = self.path .. "/icons/titlebar/close.svg",
					menu      = self.path .. "/icons/titlebar/menu.svg",
					unknown   = self.icon.unknown, -- this one used as fallback
				}
			}

	-- Desktop config
		-- init
			self.desktop = { common = { bar = {}, pack = {} }, speedmeter = {} }
			self.desktop.grid = {
				width  = { 440, 440 },
				height = { 100, 100, 100, 66, 50 },
				edge   = { width = { 750, 100 }, height = { 100, 100 } }
			}
			self.desktop.places = {
				netspeed = { 2, 1 },
				ssdspeed = { 2, 2 },
				hddspeed = { 2, 3 },
				cpumem   = { 1, 1 },
				transm   = { 1, 2 },
				disks    = { 1, 3 },
				thermal1 = { 1, 4 },
				thermal2 = { 2, 4 },
				fan      = { 2, 5 },
				vnstat   = { 1, 5 },
			}
			self.desktop.line_height = 5 -- text and progressbar height for desktop widgets
		-- desktop widget colors
			self.desktop.color = {
				main       = self.color.main,
				gray       = self.color.desktop_gray,
				icon       = self.color.desktop_icon,
				urgent     = self.color.urgent,
				wibox = self.color.bg .. "00"
			}
		-- Textbox
			self.desktop.common.textbox = {
				width  = nil,                     -- widget width
				height = nil,                     -- widget height
				draw   = "by_left",               -- align method ("by_left", "by_right", "by_edges", "by_width")
				color  = self.desktop.color.gray, -- text color
				font = self.cairo_fonts.desktop.textbox,
			}
		-- Dashed progressbar
			self.desktop.common.bar.plain = {
				width       = nil,   -- widget width
				height      = nil,   -- widget height
				autoscale   = false, -- normalize progressbar value
				maxm        = 1,     -- the maximum allowed value
				color = self.desktop.color,
				chunk = {
					width = 6,  -- bar width
					gap = 6     -- space between bars
				}
			}
		-- Time chart
			self.desktop.common.chart = {
				width       = nil,                     -- widget width
				height      = nil,                     -- widget height
				autoscale   = true,                    -- normalize chart values
				maxm        = 1,                       -- the maximum allowed value
				zero_height = 4,                       -- height for zero value point in chart
				color       = self.desktop.color.gray, -- chart bars color
				bar = {
					width = 5,  -- bar width
					gap = 5     -- space between bars
				}
			}
		-- Lines (group of progressbars with label in front and text value after it)
			self.desktop.common.pack.lines = {
				label        = { width = 80, draw = "by_width" },     -- label style (see theme.desktop.common.textbox)
				text         = { width = 92, draw = "by_edges" },     -- value style (see theme.desktop.common.textbox)
				progressbar  = { chunk = { gap = 6, width = 16 }},                                    -- progressbar style (see theme.desktop.common.bar.plain)
				line         = { height = self.desktop.line_height }, -- text/progressbar height
				tooltip      = {},                                    -- redflat tooltip style (see theme.float.tooltip)
				color        = self.desktop.color,                    -- color (desktop used)
				show         = { text = true, label = true, tooltip = false },
				gap          = { text = 22, label = 16 },
			}
			self.desktop.common.pack.lines.tooltip.set_position = function(wibox)
				awful.placement.under_mouse(wibox)
				wibox.y = wibox.y - 30
			end
		-- Custom shaped vertical progressbar
			self.desktop.common.bar.shaped = {
				width     = nil,                     -- widget width
				height    = nil,                     -- widget height
				autoscale = true,                    -- normalize chart values
				maxm      = 1,                       -- the maximum allowed value
				shape     = "corner",                -- progressbar chunk shape
				show      = { tooltip = true },      -- show tooltip
				color     = self.desktop.color,      -- color (desktop used)
				chunk = {
					num = 10,   -- number of elements
					line = 5,   -- element line width
					height = 10 -- element height
				},
				tooltip = { set_position = theme.desktop.common.pack.lines.tooltip.set_position },
			}
		-- Widgets
			--Custom aligned text block
				self.desktop.textset = {
					font  = "Sans 12",         -- font
					spacing = 0,               -- space between lines
					color = self.desktop.color -- color (desktop used)
				}
			-- Speed widget (double progressbar with time chart for each of it)
				self.desktop.speedmeter.normal = {
					barvalue_height  = 32,                  -- height of the area with progressbar and text
					digits           = 2,                   -- minimal number of digits for progressbar value
					fullchart_height = 80,                  -- height of the each area with progressbar, text and chart
					image_gap        = 16,                  -- space between direction icon and progressbar/chart
					color            = self.desktop.color,  -- color (desktop used)
					images = {
						self.icon.system, -- up
						self.icon.system  -- down
					},
					chart = { bar = { width = 6, gap = 3 }, height = 40, zero_height = 4 },
					label = { height = self.desktop.line_height },
					progressbar = { chunk = { width = 16, gap = 6 }, height = 6 },
				}
				self.desktop.speedmeter.compact = {
					margins      = { label = { 10, 10, 0, 0 }, chart = { 0, 0, 3, 3 } }, -- extra margins for some elements
					height       = { chart = 46 },             -- height of the each area with progressbar, text and chart
					digits       = 2,                          -- minimal number of digits for progressbar value
					color        = self.desktop.color,         -- color (desktop used)
					icon = {
						up = self.path .. "/desktop/up.svg",
						down = self.path .. "/desktop/down.svg",
						margin = { 0, 4, 0, 0}
					},
					chart       = { bar = { width = 6, gap = 3 }, height = nil, zero_height = 0 }, -- time chart style (see theme.desktop.common.chart)
					label       = { font = { font = "Play", size = 22, face = 1, slant = 0 }, width = 76 , height = 15 },-- progressbar value (see theme.desktop.common.textbox)
					progressbar = { chunk = { width = 6, gap = 3 }, height = 3 },                  -- double progressbar style (see theme.desktop.common.bar.plain)
				}
			-- Widget with multiple horizontal and vertical progress bars
				self.desktop.multimeter = {
					digits       = 3,                  -- minimal number of digits for horizontal progressbar values
					color        = self.desktop.color, -- color (desktop used)
					labels       = {},                 -- list of optional labels for horizontal bars
					height = {
						upright = 66,  -- vertical progressbars height
						lines = 20,    -- horizontal progressbar area height
					},
					icon = {
						image  = self.icon.system,   -- widget icon
						margin = { 0, 8, 0, 0 },    -- margins around icon
						full   = true               -- draw icon in full height of widget
					},
					upbar = { width = 32, chunk = { num = 8, line = 4 }, shape = "plain" },
					lines = { show = { label = false, tooltip = true, text = false }},
				}
			-- Widget with multiple progress bars
				self.desktop.multiline = {
					digits = 3,                  -- minimal number of digits for progressbar value
					margin = { 0, 0, 0, 0 },     -- margin around progressbar list
					color  = self.desktop.color, -- color (desktop used)
					icon = { image = nil, margin = self.desktop.multimeter.icon.margin },
					lines = { show = { label = false, tooltip = true, text = false }, progressbar = {}, tooltip = {} },
				}
			-- Widget with several text groups in single line
				self.desktop.singleline = {
					lbox      = { draw = "by_width", width = 50 }, -- label style (see theme.desktop.common.textbox)
					rbox      = { draw = "by_edges", width = 60 }, -- value style (see theme.desktop.common.textbox)
					digits    = 2,                                 -- minimal number of digits for value
					icon      = self.icon.system,                  -- group icon
					iwidth    = 142,                               -- width for every text group
					color     = self.desktop.color                 -- color (desktop used)
				}
			-- Calendar widget with lined up marks
				self.desktop.calendar = {
					show_pointer = true,               -- show date under mouse
					color        = self.desktop.color, -- color (desktop used)
					label = {
						gap  = 8,   -- space between label and pointer
						sep  = "-", -- day/month separator
						font = { font = "Play", size = 16, face = 1, slant = 0 }, -- font
					},
					mark = {
						height = 12, -- mark height
						width  = 25, -- mark width
						dx     = 6,  -- pointer arrow width
						line   = 2,  -- stroke line width for next month marks
					},
				}
	-- Over vars
		-- colors
			self.bg_normal     = self.color.wibox
			self.bg_focus      = self.color.main
			self.bg_urgent     = self.color.urgent
			self.bg_minimize   = self.color.gray
			self.fg_normal     = self.color.text
			self.fg_focus      = self.color.highlight
			self.fg_urgent     = self.color.highlight
			self.fg_minimize   = self.color.highlight
			self.border_normal = self.color.wibox
			self.border_focus  = self.color.wibox
			self.border_marked = self.color.main
		-- font
			self.font = self.fonts.main
		-- standart awesome notification widget
			self.naughty = {}
			self.naughty.base = {
				timeout      = 10,
				margin       = 12,
				icon_size    = 80,
				font         = self.fonts.main,
				bg           = self.color.wibox,
				fg           = self.color.text,
				border_width = 2,
				border_color = self.color.wibox
			}
			self.naughty.normal = {
				height = self.float.notify.geometry.height,
				width = self.float.notify.geometry.width,
			}
			self.naughty.low = {
				timeout = 5,
				height = self.float.notify.geometry.height,
				width = self.float.notify.geometry.width,
			}
			self.naughty.critical = {
				timeout = 0,
				border_color = self.color.main
			}

		-- Set hotkey helper size according current fonts and keys scheme
			self.service.navigator.keytip["fairv"] = { geometry = { width = 600 }, exit = true }
			self.service.navigator.keytip["fairh"] = self.service.navigator.keytip["fairv"]
			self.service.navigator.keytip["tile"]       = { geometry = { width = 600 }, exit = true }
			self.service.navigator.keytip["tileleft"]   = self.service.navigator.keytip["tile"]
			self.service.navigator.keytip["tiletop"]    = self.service.navigator.keytip["tile"]
			self.service.navigator.keytip["tilebottom"] = self.service.navigator.keytip["tile"]
			self.service.navigator.keytip["grid"]    = { geometry = { width = 1400 }, column = 2, exit = true }
			self.service.navigator.keytip["usermap"] = { geometry = { width = 1400 }, column = 2, exit = true }
		-- Menu config
			self.menu.icon_margin  = { 4, 7, 7, 8 }
			self.menu.keytip       = { geometry = { width = 400 } }
		-- Panel float
			-- Double icon indicator
				self.gauge.icon.double.icon1 = self.wicon.down
				self.gauge.icon.double.icon2 = self.wicon.up
				self.gauge.icon.double.igap  = -6
			-- System updates indicator
				self.widget.updates.notify = { icon = self.wicon.package }
				self.widget.updates.wibox.icon.package = self.wicon.package
				self.widget.updates.wibox.icon.normal = self.wicon.updates.normal
				self.widget.updates.wibox.icon.silent = self.wicon.updates.silent
				self.widget.updates.wibox.icon.weekly = self.wicon.updates.weekly
				self.widget.updates.wibox.icon.daily = self.wicon.updates.daily
			-- Layoutbox
				self.widget.layoutbox.menu.icon_margin  = { 8, 12, 9, 9 }
				self.widget.layoutbox.menu.width = 200
			-- Tasklist
				self.widget.tasklist.winmenu.hide_action = { min = false, move = false }
				self.widget.tasklist.tasktip.margin = { 8, 8, 4, 4 }
				self.widget.tasklist.winmenu.tagmenu.width = 150
				self.widget.tasklist.winmenu.enable_tagline = true
				self.widget.tasklist.winmenu.tagline = { height = 30 }
				self.widget.tasklist.winmenu.tag_iconsize = { width = 16, height = 16 }
			-- Floating widgets
				-- Client menu
					self.float.clientmenu.enable_tagline = true
					self.float.clientmenu.hide_action = { min = false, move = false }
				-- Application runner
					self.float.apprunner.title_icon = self.wicon.search
					self.float.apprunner.keytip = { geometry = { width = 400 } }
				-- Application switcher
					self.float.appswitcher.keytip = { geometry = { width = 400 }, exit = true }
				-- Quick launcher
					self.float.qlaunch.keytip = { geometry = { width = 600 } }
				-- Key sequence tip
					self.float.keychain.border_width = 1
					self.float.keychain.keytip = { geometry = { width = 1200 }, column = 2 }
				-- Brightness control
					self.float.brightness.notify = { icon = self.wicon.brightness }
				-- Default awesome theme vars
					self.enable_spawn_cursor = false
				-- System updates indicator
					self.widget.updates.icon = self.path .. "/icons/widget/updates.svg"
				-- Tasklist
					self.widget.tasklist.char_digit = 5
					self.widget.tasklist.task = self.gauge.task
					self.widget.tasklist.tasktip.max_width = 1200
				-- Titlebar helper
					self.float.bartip.names = { "Mini", "Compact", "Full" }
				-- client menu tag line
					self.widget.tasklist.winmenu.enable_tagline = false
					self.widget.tasklist.winmenu.icon.tag = self.path .. "/icons/widget/mark.svg"
					self.float.clientmenu.enable_tagline = false
					self.float.clientmenu.icon.tag = self.widget.tasklist.winmenu.icon.tag
				-- Set hotkey helper size according current fonts and keys scheme
					self.float.appswitcher.keytip = { geometry = { width = 400 }, exit = true }
					self.float.keychain.keytip    = { geometry = { width = 1020 }, column = 2 }
					self.float.apprunner.keytip   = { geometry = { width = 400 } }
					self.widget.updates.keytip    = { geometry = { width = 400 } }
					self.menu.keytip              = { geometry = { width = 400 } }
				-- Titlebar
					self.titlebar.icon_compact = {
						color        = { icon = self.color.gray, main = self.color.main, urgent = self.color.main },
						list         = {
							maximized = self.path .. "/icons/titlebar/maximized.svg",
							minimized = self.path .. "/icons/titlebar/minimize.svg",
							close     = self.path .. "/icons/titlebar/close.svg",
							focus     = self.path .. "/icons/titlebar/focus.svg",
							unknown   = self.icon.unknown,
						}
					}
end
theme:init()
-- Theme individual
	-- init
		theme.individual = { desktop = { speedmeter = {}, multimeter = {}, multiline = {} } }
	-- Microphone
		theme.individual.microphone = {
			width   = 26,
			--dmargin = { 4, 3, 1, 1 },
			--dash    = { line = { num = 3, height = 5 } },
			icon    = theme.path .. "/icons/widget/microphone.svg",
			color   = { icon = theme.color.main, mute = theme.color.icon }
		}
	-- Drive
		theme.individual.desktop.speedmeter.drive = {
			unit   = { { "B", -1 }, { "KB", 2 }, { "MB", 2048 } },
		}
	-- Cpu
		theme.individual.desktop.multimeter.cpumem = {
			labels = { "RAM", "SWAP" },
			icon  = { image = theme.path .. "/icons/desktop/cpu.svg" }
		}
	-- Transmission
		theme.individual.desktop.multimeter.transmission = {
			labels = { "SEED", "DNLD" },
			unit   = { { "KB", -1 }, { "MB", 1024^1 } },
			upbar  = { width = 20, chunk = { num = 8, line = 4 }, shape = "plain" },
			icon   = { image = theme.path .. "/icons/desktop/transmission.svg" }
		}
	-- Multilines storage (individual widget)
		theme.individual.desktop.multiline.storage = {
			unit      = { { "KB", 1 }, { "MB", 1024^1 }, { "GB", 1024^2 } },
			icon      = { image = theme.path .. "/icons/desktop/storage.svg" },
			lines     = {
				line        = { height = 10 },
				progressbar = { chunk = { gap = 6, width = 4 } },
			},
		}
	-- Multilines qemu drive images (individual widget)
		theme.individual.desktop.multiline.images = {
			unit = { { "KB", 1 }, { "MB", 1024^1 }, { "GB", 1024^2 } },
		}
	-- Multilines temperature (individual widget)
		theme.individual.desktop.multiline.thermal = {
			digits    = 1,
			icon      = { image = theme.path .. "/icons/desktop/thermometer.svg", margin = { 0, 8, 0, 0 } },
			lines     = {
				line        = { height = 13 },
				text        = { font = { font = "Play", size = 18, face = 1, slant = 0 }, width = 44 },
				label       = { font = { font = "Play", size = 18, face = 1, slant = 0 } },
				gap         = { text = 10 },
				progressbar = { chunk = { gap = 6, width = 4 } },
				show        = { text = true, label = false, tooltip = true },
			},
			unit      = { { "°C", -1 } },
		}
	-- Multilines fan (individual widget)
		theme.individual.desktop.multiline.fan = {
				digits    = 1,
				margin    = { 0, 0, 5, 5 },
				icon      = { image = theme.path .. "/icons/desktop/fan.svg", margin = { 8, 16, 0, 0 } },
				lines     = {
					line        = { height = 13 },
					progressbar = { chunk = { gap = 6, width = 4 } },
					show        = { text = false, label = false, tooltip = true },
				},
				unit      = { { "RPM", -1 }, { "R", 1 } },
		}
	-- Multilines traffic (individual widget)
		theme.individual.desktop.multiline.vnstat = {
				digits    = 3,
				margin    = { 0, 0, 5, 5 },
				icon      = { image = theme.path .. "/icons/desktop/traffic.svg", margin = { 8, 16, 0, 0 } },
				lines     = {
					line        = { height = 13 },
					progressbar = { chunk = { gap = 6, width = 4 } },
					show        = { text = false, label = false, tooltip = true },
				},
				unit = { { "B", 1 }, { "KiB", 1024 }, { "MiB", 1024^2 }, { "GiB", 1024^3 } },
		}
return theme
