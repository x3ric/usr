--sudo pacman -Sy texlive-bin texlive-latex texlive-latexextra
--sudo tlmgr install standalone amsmath
local vim = vim
function counttable(t) --returns number of elements in table
  count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end
local random = math.random
math.randomseed(os.time())
local function uuid()
  local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  return string.gsub(template, "[xy]", function(c)
    local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
    return string.format("%x", v)
  end)
end
function find_equations()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local positions = {}
  for lno, line in ipairs(lines) do
    st = 1
    while true do
      local x, y = string.find(line, "$$", st, true)
      if x == nil then
        break
      end
      table.insert(positions, { lno, x })
      st = y + 1
    end
    while true do
      local x, y = string.find(line, "$", st, true)
      if x == nil then
        break
      end
      table.insert(positions, { lno, x })
      st = y + 1
    end
  end
  if #positions % 2 ~= 0 then
    print "Unmatched $"
  end
  return positions
end
function iszeropos(pos)
  return (pos[1] == 0 and pos[2] == 0)
end
function latex_topng(fnames, size)
  --renders the latex as png's  in /tmp
  latexjobids = {}
  dvijobids = {}
  for k, fname in pairs(fnames) do
    jobid =
      vim.fn.jobstart("latex  --interaction=nonstopmode --output-dir=/tmp --output-format=dvi LATEXFILE" .. fname, {
        cwd = "/tmp",
        on_stdout = function(j, d, e)
          print()
        end,
        on_stderr = function(j, d, e)
          print()
        end,
      })
    table.insert(latexjobids, jobid)
  end
  vim.fn.jobwait(latexjobids)
  for k, fname in pairs(fnames) do
    jobid = vim.fn.jobstart(
      "dvipng -D "
        .. tonumber(size)
        .. " -T tight  -bg Transparent -fg 'cmyk 0.2 0.2 0.2 0.2'  -o /tmp/LATEXFILE"
        .. fname
        .. ".png"
        .. " "
        .. "/tmp/LATEXFILE"
        .. fname
        .. ".dvi",
      {
        cwd = "/tmp",
        on_stdout = function(j, d, e)
          print()
        end,
      }
    )
    table.insert(dvijobids, jobid)
  end
  vim.fn.jobwait(dvijobids)
end
function get_lstrings(positions) --gets list os strings between positions positions is a list of pairs of lno,cno  (lineno , columno)
  lstrings = {}
  for i = 1, counttable(positions), 2 do
    lstring = ""
    start = positions[i]
    stop = positions[i + 1]
    for k, v in pairs(vim.api.nvim_buf_get_text(0, start[1] - 1, start[2], stop[1] - 1, stop[2] - 1, { nil })) do
      lstring = lstring .. v
    end
    table.insert(lstrings, lstring)
  end
  return lstrings
end
-- LaTeX template for generating tex files
local pre =
  "\\documentclass[12pt]{standalone}\n \\usepackage{amsmath}\n \\usepackage{amssymb}\n \\begin{document}\n \\begin{align}"
local post = "\\end{align} \n \\end{document}"
function write_texfiles(lstrings)
  fnames = {}
  for k, v in pairs(lstrings) do
    fname = uuid()
    filehandle = io.open("/tmp/LATEXFILE" .. fname, "w")
    filehandle:write(pre .. v .. "\n" .. post)
    filehandle:close()
    table.insert(fnames, fname)
  end
  return fnames
end
local imgs = {}
function insertpngs(eqpos, fnames, size)
  findex = 1
  for i = 1, counttable(eqpos), 2 do
    source = "/tmp/LATEXFILE" .. fnames[findex] .. ".png"
    buf = vim.api.nvim_get_current_buf()
    table.insert(imgs, require("hologram.image"):new(source, {}))
    imgs[findex]:display(eqpos[i][1], 0, buf, {})
    findex = findex + 1
  end
end
function RemoveLatex()
  for k, img in pairs(imgs) do
    img:delete(0, { free = true })
  end
  for k, v in pairs(imgs) do
    imgs[k] = nil
  end
end
function RenderLatex(opts)
  RemoveLatex()
  eqpos = find_equations()
  lstrings = get_lstrings(eqpos)
  fnames = write_texfiles(lstrings)
  latex_topng(fnames, opts.fargs[1])
  insertpngs(eqpos, fnames)
end
function inbetween(curpos, pos1, pos2)
  -- Checks if curpos is between pos1 and pos2
  -- Assumes pos2 is after pos1
  if pos1[1] == pos2[1] then
    -- If pos1 and pos2 are on the same line, check column
    if curpos[1] == pos1[1] and pos1[2] < curpos[2] and curpos[2] < pos2[2] then
      return true
    end
  elseif pos1[1] == curpos[1] and pos1[2] < curpos[2] then
    -- Now that we established pos1 and pos2 are on different lines,
    -- if cur is on the line of pos1, check if cursor column is after pos1 column
    return true
  elseif curpos[1] == pos2[1] and curpos[2] < pos2[2] then
    -- If cur is on the line of pos2, check if pos2 is after the cursor
    return true
  elseif pos1[1] < curpos[1] and curpos[1] < pos2[1] then
    -- If curpos, pos1, and pos2 are on different lines, just check for lines
    return true
  else
    return false
  end
  return false
end
function findenclosing_eq(curpos, positions)
  for i = 1, counttable(positions), 2 do
    if inbetween(curpos, positions[i], positions[i + 1]) then
      return { positions[i], positions[i + 1] }
    else
      RemoveLatex()
    end
  end
  return nil
end
function RenderLatexAtCursor(opts)
  RemoveLatex()
  eqpos = find_equations()
  curpos = vim.fn.getpos "."
  curpos = { curpos[2], curpos[3] }
  cureqpos = findenclosing_eq(curpos, eqpos)
  if cureqpos ~= nil then
    lstrings = get_lstrings(cureqpos)
    fnames = write_texfiles(lstrings)
    latex_topng(fnames, opts.fargs[1])
    insertpngs(cureqpos, fnames)
  else
    --print("cursor not in equation")
  end
end
function RenderLatexAtCursorAuto()
  vim.api.nvim_command "autocmd! CursorMoved,TextChanged,WinEnter *.md LatexRenderAtCursor 200"
end
function RenderLatexAuto()
  vim.api.nvim_command "autocmd! TextChanged,TextChangedI,BufEnter,FocusGained *.md LatexRender 200"
end
vim.api.nvim_create_user_command("LatexRender", RenderLatex, {
  nargs = 1,
  complete = function(ArgLead, CmdLine, CursorPos)
    return { "200", "300" }
  end,
})
vim.api.nvim_create_user_command("LatexRenderAuto", RenderLatexAuto, { nargs = 0 })
vim.api.nvim_create_user_command("LatexRenderAtCursor", RenderLatexAtCursor, {
  nargs = 1,
  complete = function(ArgLead, CmdLine, CursorPos)
    return { "200", "300" }
  end,
})
vim.api.nvim_create_user_command("LatexRemove", RemoveLatex, { nargs = 0 })
vim.api.nvim_create_user_command("LatexRenderAtCursorAuto", RenderLatexAtCursorAuto, { nargs = 0 })
-- Load lates on md open
--vim.api.nvim_command("autocmd! TextChanged,TextChangedI,BufEnter,FocusGained *.md LatexRender 200)
