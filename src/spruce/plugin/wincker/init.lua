local fl = require("src.spruce.plugin.wincker.fontparser")
local utf8 = require("src.warm.utf8")

local drawer = {
  font = vim.fn.stdpath("config") .. "/ar",
  win = {
    h = 7,
    w = 10,
  },
  windows = {},
  ma_hi = {},
}

---@param window number
function drawer:get_float_win_pos(window)
  local width = vim.api.nvim_win_get_width(window)
  local height = vim.api.nvim_win_get_height(window)

  local pos = {
    x = ((width - self.win.w) / 2),
    y = ((height - self.win.h) / 2),
  }

  return pos
end

---@param window number
function drawer:spawn_floating_hint(window, color, char)
  local pos = self:get_float_win_pos(window)
  local lines = {}

  local line = string.rep(" ", self.win.w)
  for l = 1, self.win.h do
    lines[l] = line
  end
  local font = fl.load(self.font)
  font:get_char(char) -- Load char in table
  -- local fmt = require("src.warm.str").format
  for i = 2, 7 do
    local bigchar = font.chars[char][2][i - 1]
    if utf8.len(bigchar) >= self.win.w then
      lines[i] = bigchar
    else
      local nw = self.win.w - utf8.len(bigchar)
      local fill_left = string.rep(" ", math.floor(nw / 2))
      local fill_right = string.rep(" ", math.ceil(nw / 2))
      lines[i] = fill_left .. bigchar .. fill_right
    end
  end
  lines = { table.concat(lines, "") .. " " }

  local buffer_id = vim.api.nvim_create_buf(false, true)
  local window_id = vim.api.nvim_open_win(buffer_id, false, {
    relative = "win",
    win = window,
    focusable = true,
    row = pos.y,
    col = pos.x,
    width = self.win.w,
    height = self.win.h,
    style = "minimal",
    -- border = {
    --   { "╭", "FloatBorder" },
    --   { "─", "FloatBorder" },
    --   { "╮", "FloatBorder" },
    --   { "│", "FloatBorder" },
    --   { "╯", "FloatBorder" },
    --   { "─", "FloatBorder" },
    --   { "╰", "FloatBorder" },
    --   { "│", "FloatBorder" },
    -- },
  })

  local hi_grp = "MatchingAllContent" .. color:sub(2)
  local match_id = 0
  local match_id_fg
  vim.api.nvim_buf_set_lines(buffer_id, 0, 0, true, lines)
  -- Add color to each window
  vim.api.nvim_win_call(window_id, function()
    match_id_fg = vim.fn.matchadd("AWinckerHighlightForTrickyForegroundColor", [[.*]])
    vim.cmd("hi AWinckerHighlightForTrickyForegroundColor guifg=#101010 guibg=#101010")
    ---@diagnostic disable-next-line: cast-local-type
    match_id = vim.fn.matchadd(hi_grp, [[\s]])
    vim.cmd("hi " .. hi_grp .. " guifg=" .. color .. " guibg=" .. color)
  end)
  return window_id, { match_id, hi_grp, match_id_fg }
end

---@param windows table<table<string, any>>
function drawer:draw(windows)
  for _, win in ipairs(windows) do
    local window_id, m = self:spawn_floating_hint(win.winid, win.color, win.char)
    table.insert(self.windows, window_id)
    table.insert(self.ma_hi, m)
  end
end

function drawer:clear()
  for i, win in ipairs(self.windows) do
    if vim.api.nvim_win_is_valid(win) then
      vim.cmd("hi clear AWinckerHighlightForTrickyForegroundColor")
      vim.cmd("hi clear " .. self.ma_hi[i][2])
      vim.fn.matchdelete(self.ma_hi[i][1], win) -- BG
      vim.fn.matchdelete(self.ma_hi[i][3], win) -- FG
      local buffer = vim.api.nvim_win_get_buf(win)
      vim.api.nvim_win_close(win, true)
      vim.api.nvim_buf_delete(buffer, { force = true })
    end
  end
  -- Remove foreground color match group
  self.windows = {}
  self.ma_hi = {}
end

local main = {}

---Pick a window and return information about its selection
---@return {char:integer, data:{winid:integer, color:string, char:string}}?
function main.select()
  -- List of all open windows
  local win_list = {}
  -- Looping to enforce the window number to be the index
  for _, v in ipairs(vim.api.nvim_list_wins()) do
    local i = vim.fn.win_id2win(v)
    ---@diagnostic disable-next-line: need-check-nil
    win_list[i] = v
  end

  -- stylua: ignore
  local color = {
    { "Red",        "#ff6e6e" },
    { "Orange",     "#ffb86c" },
    { "Yellow",     "#ffe86c" },
    { "Green",      "#6ff660" },
    { "Mint green", "#6cffb8" },
    { "Cyan",       "#6ce8ff" },
    { "Blue",       "#6c8cff" },
    { "Indigo",     "#4b0082" },
    { "Violet",     "#8c6cff" },
    { "Purple",     "#a020f0" },
    { "Magenta",    "#ff00ff" },
    { "Pink",       "#e188a4" },
    { "Peach",      "#ffa98c" },
    { "Beige",      "#ffe8b8" },
    { "Light gray", "#e8e8e8" },
    { "Dark gray",  "#444444" },
    { "Brown",      "#b8966c" },
    { "Dark brown", "#8c5a2d" }
  } -- &e TODO: &b Add more colours, or random generate by winid

  -- Iterate over the list of windows and gather window information
  for nr, win in ipairs(win_list) do
    win_list[nr] = { winid = win, color = color[nr][2], char = string.char(nr + 64) }
  end

  drawer:draw(win_list)
  vim.cmd("redraw")

  local ok, ch = pcall(vim.fn.getchar) -- Will block exec until we got something
  drawer:clear()
  vim.cmd("redraw")
  if type(ch) ~= "number" then return end -- Any <key>
  -- if char (     Uppercase     ) or (      lowercase     )
  if ok and ((ch > 64 and ch < 91) or (ch > 96 and ch < 123)) then
    -- Allow lowercase by converting them to uppercase
    ---@diagnostic disable-next-line: param-type-mismatch
    return { char = ch, data = win_list[(string.byte(string.char(ch):upper()) - 64)] }
  end
end

---Pick a window and jump into it
function main.jump()
  local res = main.select()
  if res == nil then return end
  if res.data == nil then
    vim.api.nvim_notify(
      "Window with mark: '" .. string.char(res.char) .. "' does not exist",
      vim.log.levels.ERROR,
      { title = "Winker" }
    )
    return
  end
  if vim.api.nvim_win_is_valid(res.data.winid) then
    vim.api.nvim_set_current_win(res.data.winid)
  else
    vim.api.nvim_notify(
      "Window with mark: '" .. string.char(res.char) .. "' is not a valid window",
      vim.log.levels.ERROR,
      { title = "Winker" }
    )
  end
end

return main
