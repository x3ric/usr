local io = io
local table = table
local ipairs = ipairs
local string = string
local awful = require("awful")
local beautiful = require("beautiful")
local redutil = require("lib.utils")
local gears = require("gears")
local dfparser = {}
local cache = {}
dfparser.terminal = 'uxterm'
local all_icon_folders = { "apps", "actions", "devices", "places", "categories", "status" }
local all_icon_sizes   = { '128x128' , '96x96', '72x72', '64x64', '48x48', '36x36',    '32x32', '24x24', '22x22', '16x16', 'scalable' }
local function default_style()
	local style = {
		icons             = { custom_only = false, scalable_only = false, df_icon = nil, theme = nil },
		desktop_file_dirs = { "/usr/share/applications/" },
		wm_name           = nil,
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "service.dfparser") or {})
end
local function check_cached(req)
	for k, v in pairs(cache) do
		local eq = #req == #k
		for ck, cv in pairs(k) do eq = eq and cv == req[ck] end
		if eq then return v end
	end
	return nil
end
local function is_format(icon_file, icon_formats)
	for _, f in ipairs(icon_formats) do
		if icon_file:match('%.' .. f) then return true end
	end
	return false
end
local function all_icon_path(style)
	local icon_theme_paths = {}
	if style.theme then
		table.insert(icon_theme_paths, style.theme .. '/')
		-- TODO also look in parent icon themes, as in freedesktop.org specification
	end
	if not style.custom_only then table.insert(icon_theme_paths, '/usr/share/icons/hicolor/') end
	local current_icon_sizes = style.scalable_only and { 'scalable' } or all_icon_sizes
	local icon_path = {}
	for _, icon_theme_directory in ipairs(icon_theme_paths) do
		for _, size in ipairs(current_icon_sizes) do
			for _, folder in ipairs(all_icon_folders) do
				table.insert(icon_path, icon_theme_directory .. size .. "/" .. folder .. '/')
			end
		end
	end
	if not style.custom_only then
		table.insert(icon_path, '/usr/share/pixmaps/')
		table.insert(icon_path, '/usr/share/icons/')
	end
	return icon_path
end
function dfparser.lookup_icon(icon_file, style)
	style = redutil.table.merge(default_style().icons, style or {})
	local df_icon
	if style.df_icon and gears.filesystem.file_readable(style.df_icon) then
		df_icon = style.df_icon
	end
	-- No icon name
	if not icon_file or icon_file == "" then return df_icon end
	-- Handle full path icons
	local icon_formats = style.scalable_only and { "svg" } or { "svg", "png", "gif" }

	if icon_file:sub(1, 1) == '/' then
		if is_format(icon_file, icon_formats) then
			return gears.filesystem.file_readable(icon_file) and icon_file or df_icon
		else
			icon_file = string.match(icon_file, "([%a%d%-]+)%.")
			if not icon_file then return df_icon end
		end
	end
	-- Find all possible locations to search
	local icon_path = all_icon_path(style)
	-- Icon searching
	for _, directory in ipairs(icon_path) do
		-- check if icon format specified and supported
		if is_format(icon_file, icon_formats) and awful.util.file_readable(directory .. icon_file) then
			return directory .. icon_file
		else
			-- check if icon format specified but not supported
			if string.match(icon_file, "%.")
			   and not string.match(icon_file, "%w+%.%w+%.") -- ignore gnome naming style
			   and not is_format(icon_file, icon_formats) then
				icon_file = string.match(icon_file, "[%a%d%-]+")
			end
			-- icon is probably specified without path and format,
			-- like 'firefox'. Try to add supported extensions to
			-- it and see if such file exists.
			for _, format in ipairs(icon_formats) do
				local possible_file = directory .. icon_file .. "." .. format
				if awful.util.file_readable(possible_file) then
					return possible_file
				end
			end
		end
	end
	return df_icon
end
local function parse(file, style)
	local program = { show = true, file = file }
	local desktop_entry = false
	for line in io.lines(file) do
		if not desktop_entry and line == "[Desktop Entry]" then
			desktop_entry = true
		else
			if line:sub(1, 1) == "[" and line:sub(-1) == "]" then
				break
			end
			for key, value in line:gmatch("(%w+)%s*=%s*(.+)") do
				program[key] = value
			end
		end
	end
	if not desktop_entry then return nil end
	if program.NoDisplay and string.lower(program.NoDisplay) == "true" then
		program.show = false
	end
	if program.OnlyShowIn ~= nil and style.wm_name and not program.OnlyShowIn:match(style.wm_name) then
		program.show = false
	end
	if program.Icon then
		program.icon_path = dfparser.lookup_icon(program.Icon, style.icons)
	end
	if program.Categories then
		program.categories = {}

		for category in program.Categories:gmatch('[^;]+') do
			table.insert(program.categories, category)
		end
	end
	if program.Exec then
		if program.Name == nil then
			program.Name = '['.. file:match("([^/]+)%.desktop$") ..']'
		end
		local cmdline = program.Exec:gsub('%%c', program.Name)
		cmdline = cmdline:gsub('%%[fuFU]', '')
		cmdline = cmdline:gsub('%%k', program.file)
		if program.icon_path then
			cmdline = cmdline:gsub('%%i', '--icon ' .. program.icon_path)
		else
			cmdline = cmdline:gsub('%%i', '')
		end
		if program.Terminal == "true" then
			cmdline = dfparser.terminal .. ' -e ' .. cmdline
		end
		program.cmdline = cmdline
	end
	return program
end
local function parse_dir(dir, style)
	local req = awful.util.table.join({ path = dir }, style.icons)
	local programs = {}
	local cached = check_cached(req)

	if not cached then
		local files = redutil.read.output('find '.. dir ..' -maxdepth 1 -xtype f -name "*.desktop" 2>/dev/null')

		for file in string.gmatch(files, "[^\n]+") do
			local program = parse(file, style)
			if program then table.insert(programs, program) end
		end

		cache[req] = programs
	else
		programs = cached
	end

	return programs
end
function dfparser.menu(style)
	style = redutil.table.merge(default_style(), style or {})
	local categories = {
		{ app_type = "AudioVideo",  name = "Multimedia",   icon_name = "applications-multimedia" },
		{ app_type = "Development", name = "Development",  icon_name = "applications-development" },
		{ app_type = "Education",   name = "Education",    icon_name = "applications-science" },
		{ app_type = "Game",        name = "Games",        icon_name = "applications-games" },
		{ app_type = "Graphics",    name = "Graphics",     icon_name = "applications-graphics" },
		{ app_type = "Office",      name = "Office",       icon_name = "applications-office" },
		{ app_type = "Network",     name = "Internet",     icon_name = "applications-internet" },
		{ app_type = "Settings",    name = "Settings",     icon_name = "applications-utilities" },
		{ app_type = "System",      name = "System Tools", icon_name = "applications-system" },
		{ app_type = "Utility",     name = "Accessories",  icon_name = "applications-accessories" }
	}
	for _, v in ipairs(categories) do
		v.icon = dfparser.lookup_icon(v.icon_name, style)
	end
	local prog_list = {}
	for _, path in ipairs(style.desktop_file_dirs) do
		local programs = parse_dir(path, style)

		for _, prog in ipairs(programs) do
			if prog.show and prog.Name and prog.cmdline then
				table.insert(prog_list, prog)
			end
		end
	end
	local appmenu = {}
	for _, menu_category in ipairs(categories) do
		local catmenu = {}

		for i = #prog_list, 1, -1 do
			if prog_list[i].categories then
				for _, item_category in ipairs(prog_list[i].categories) do
					if item_category == menu_category.app_type then
						table.insert(catmenu, { prog_list[i].Name, prog_list[i].cmdline, prog_list[i].icon_path })
						table.remove(prog_list, i)
					end
				end
			end
		end
		if #catmenu > 0 then table.insert(appmenu, { menu_category.name, catmenu, menu_category.icon }) end
	end
	if #prog_list > 0 then
		local catmenu = {}
		for _, prog in ipairs(prog_list) do
			table.insert(catmenu, { prog.Name, prog.cmdline, prog.icon_path })
		end
		table.insert(appmenu, { "Other", catmenu, dfparser.lookup_icon("applications-other") })
	end

	return appmenu
end
function dfparser.icon_list(style)

	style = redutil.table.merge(default_style(), style or {})
	local list = {}

	for _, path in ipairs(style.desktop_file_dirs) do
		local programs = parse_dir(path, style)

		for _, prog in ipairs(programs) do
			if prog.Icon and prog.Exec then
				local key = string.match(prog.Exec, "[%a%d%.%-_/]+")
				if key then
					if string.find(key, "/") then key = string.match(key, "[%a%d%.%-_]+$") end
					list[key] = prog.icon_path
				end
			end
		end
	end

	return list
end
function dfparser.program_list(style)

	style = redutil.table.merge(default_style(), style or {})
	local prog_list = {}

	for _, path in ipairs(style.desktop_file_dirs) do
		local programs = parse_dir(path, style)

		for _, prog in ipairs(programs) do
			if prog.show and prog.Name and prog.cmdline then
				table.insert(prog_list, prog)
			end
		end
	end

	return prog_list
end
return dfparser
