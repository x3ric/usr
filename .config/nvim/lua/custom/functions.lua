-- Save read only files
function savefile()
	if vim.bo.readonly then
		vim.cmd(':silent w !pkexec tee % >/dev/null')
		vim.cmd(':edit!')
	else
		vim.cmd(':w')
	end
end
function compacttelescope(telescope_func, options)
    options = options or {}
    options.layout_strategy = "bottom_pane"
    options.layout_config = {
        height = 10,
        prompt_position = "bottom",
        width = 1.0
    }
    options.previewer = false
    telescope_func(options)
end
function compacttelescopepreview(telescope_func, options)
    options = options or {}
    options.layout_strategy = "vertical"
    options.layout_config = {
        height = 0.55,
        prompt_position = "bottom",
        width = 0.25
    }
    options.previewer = true
    telescope_func(options)
end
function findfiles()
	local options = {}
	options.layout_strategy = "vertical"
	options.layout_config = {
		width = 0.25,
	}
	options.hidden = true
	require('telescope.builtin').find_files(options)
end
-- Toggle truncated lines
vim.api.nvim_exec([[
function! ToggleWrap()
    if &wrap
        setlocal nowrap
    else
        setlocal wrap
    endif
endfunction
]], false)
-- Toggle line numbers
vim.api.nvim_exec([[
let g:linenumber_state = 'number'
function! ToggleLineNumbers()
    if g:linenumber_state == 'number'
        set relativenumber
        let g:linenumber_state = 'relativenumber'
    elseif g:linenumber_state == 'relativenumber'
        set nonumber
        set norelativenumber
        let g:linenumber_state = 'none'
    else
        set number
        let g:linenumber_state = 'number'
    endif
endfunction
]], false)
-- Compile command
local function find_and_run_build_file(dir)
  local build_files = {"build", "start", "start.sh", "build.sh"} -- List of potential build file names

  while dir and dir ~= '/' do
    for _, build_file in ipairs(build_files) do
      local build_file_path = dir .. '/' .. build_file

      if vim.fn.filereadable(build_file_path) ~= 0 then
        -- Build file found, execute it
        local cmd = (build_file:match("%.sh$") and "sh " or "") .. build_file_path -- Add "sh" for .sh files
        local Terminal = require('toggleterm.terminal').Terminal
        local build = Terminal:new({
          cmd = cmd,
          dir = dir,
          close_on_exit = false,
          on_open = function(term)
            vim.cmd("startinsert!")
          end,
          on_close = function(term)
            vim.cmd("Closing terminal")
          end,
        })
        build:toggle()
        return true -- Indicate that a build file was found and executed
      end
    end

    -- Move up to the parent directory and search again
    dir = vim.fn.fnamemodify(dir, ':h')
  end

  return false -- Indicate that no build file was found
end

local function run_file()
  local file_path = vim.fn.expand('%:p') -- Get the full path of the current file
  local dir = vim.fn.expand('%:p:h') -- Get the directory of the current file
  local extension = vim.fn.expand('%:e') -- Get the file extension

  local commands = {
    js = "node",
    py = "python",
    rs = "cargo run",
    go = "go run",
    sh = "sh",
    lua = "lua",
  }

  local cmd = commands[extension]

  if cmd then
    cmd = cmd .. " " .. file_path
  elseif extension == "" then -- No extension, possibly a build file or shebang
    local f = io.open(file_path, "r")
    if f then
      local first_line = f:read()
      f:close()
      if first_line and first_line:sub(1, 2) == '#!' then
        -- Execute the file directly if a shebang is found
        cmd = first_line:sub(3) .. " " .. file_path
      end
    end
  end

  if cmd then
    -- Execute the command in a new terminal
    local Terminal = require('toggleterm.terminal').Terminal
    local file_exec = Terminal:new({
      cmd = cmd,
      close_on_exit = false,
      on_open = function(term)
        vim.cmd("startinsert!")
      end,
      on_close = function(term)
        vim.cmd("Closing terminal")
      end,
    })
    file_exec:toggle()
  else
    -- No specific command found, try finding a build file in the current or parent directories
    if not find_and_run_build_file(dir) then
      print("No suitable command or build file found.")
    end
  end
end

local function find_dir_with_build_file()
  local current_dir = vim.fn.expand('%:p:h')

  while current_dir ~= '/' do
    -- Check for Makefile
    if vim.fn.filereadable(current_dir .. '/Makefile') ~= 0 then
      return current_dir, 'Makefile'
    end

    -- Check for .ino files
    local ino_pattern = current_dir .. '/*.ino'
    local ino_files = vim.fn.glob(ino_pattern)
    if ino_files ~= '' then
      local first_ino_file = vim.fn.split(ino_files, "\n")[1]
      return current_dir, first_ino_file -- returns the first .ino file found
    end

    current_dir = vim.fn.fnamemodify(current_dir, ':h')
  end
end
local function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end
local function run_build_command()
  local build_dir, build_file = find_dir_with_build_file()
  if build_dir then
    local cmd = ''
    if build_file == 'Makefile' then
      cmd = "make run"
    elseif ends_with(build_file, ".ino") then
      cmd = "zsh -ci 'arduino-flash \"" ..  build_file .. "\"'"
    end
    local Terminal = require('toggleterm.terminal').Terminal
    local build = Terminal:new({
      cmd = cmd,
      dir = build_dir,
      close_on_exit = false,
      on_open = function(term)
        vim.cmd("startinsert!")
      end,
      on_close = function(term)
        vim.cmd("Closing terminal")
      end,
    })
    build:toggle()
  else
    run_file()
  end
end

vim.api.nvim_create_user_command("Compile", run_build_command, {})
