--& Spruce Nvim api helpers

local main = {}
local str = require("src.warm.str")

---Returns whether the mode is visual mode or not
---@return boolean
function main.is_visual()
  -- local mode = vim.fn.mode()
  local mode = vim.api.nvim_get_mode().mode
  return (mode == "v" or mode == "V" or mode == "\\<C-V>")
end

---@diagnostic disable-next-line: undefined-field
function main.is_buf_modifiable() return vim.api.nvim_buf_get_option(0, "modifiable") end
---@diagnostic disable-next-line: undefined-field
function main.is_buf_modified() return vim.api.nvim_buf_get_option(0, "modified") end
---@diagnostic disable-next-line: param-type-mismatch
function main.is_buf_named() return vim.api.nvim_buf_get_name(vim.fn.bufnr("%")) ~= "" end

---Send ESC key press, ussually to go back to normal mode
---@param mode string?
function main.press_esc_key(mode)
  if mode == nil then mode = "n" end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), mode, true)
end

---Move cursor like VS Code does when Home key is pressed
function main.home_key()
  local line_nr, cursor_pos = table.unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]

  local content_pos = string.find(line, "%S") - 1 or 0
  -- Check if cursor is at the beginning of the line content
  if cursor_pos == content_pos then
    vim.api.nvim_win_set_cursor(0, { line_nr, 0 })
  else
    -- Move cursor to the start of the line content
    vim.api.nvim_win_set_cursor(0, { line_nr, content_pos })
  end
end

-- Return if buffer is modifiable and notify user if not
function main.is_buf_modifiable_notify()
  if not main.is_buf_modifiable() then
    vim.notify("Buffer is not modifiable", vim.log.levels.ERROR, { title = "Spruce API" })
    return false
  end
  return true
end

---Returns all complete lines of the visual selection
--
-- Usually used inside vim.schedule(function() <here> end) if v mode is active
---@return string[]
function main.get_visual_selection_lines()
  local line_start = vim.api.nvim_buf_get_mark(0, "<")[1]
  local line_end = vim.api.nvim_buf_get_mark(0, ">")[1]
  if line_start == line_end then line_start = line_start - 1 end

  return vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
end

---Returns the visual selection string (if one line) or list of strings (if multiple lines)
--
-- Usually used inside vim.schedule(function() <here> end) if v mode is active
---@return string[]|string
function main.get_visual_selection()
  local line_start = vim.fn.getpos("'<")[2]
  local col_start = vim.fn.getpos("'<")[3]
  local line_end = vim.fn.getpos("'>")[2]
  local col_end = vim.fn.getpos("'>")[3]

  local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)

  if line_start == line_end then -- One line
    return lines[1]:sub(col_start, col_end)
  end
  lines[1] = lines[1]:sub(col_start)
  lines[#lines] = lines[#lines]:sub(1, col_end)
  return lines
end

---Same as pressing 'y' or 'yy', copy the line or selection to the " register
function main.copy()
  if main.is_visual() then
    main.press_esc_key() -- Back to normal mode
    vim.schedule(function()
      local lines = main.get_visual_selection()
      vim.api.nvim_notify(
        "Copied from " .. #lines .. " line(s)",
        vim.log.levels.INFO,
        { title = "Spruce API" }
      )
      vim.fn.setreg('"', lines)
    end)
  else
    vim.api.nvim_notify("Copied from 1 line", vim.log.levels.INFO, { title = "Spruce API" })
    vim.fn.setreg('"', vim.fn.getline("."))
  end
end

---Paste the contents of " register to the cursor position in buffer
function main.paste()
  if not main.is_buf_modifiable_notify() then return end
  vim.api.nvim_notify(
    "Paste last copied/yanked text",
    vim.log.levels.INFO,
    { title = "Spruce API" }
  )
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.api.nvim_paste(vim.fn.getreg('"'), true, -1)
end

function main.save()
  if not main.is_buf_named() then
    vim.api.nvim_notify(
      "Buffer is not named, has no associated file. run :w <file_name>",
      vim.log.levels.ERROR,
      { title = "Spruce API" }
    )
    return
  end
  vim.api.nvim_command("w!") -- save
  vim.api.nvim_command("stopinsert") -- back to normal mode
  main.press_esc_key()
end

function main.quit()
  if not main.is_buf_modified() then
    -- File is not modified, quit directly
    vim.cmd("qa!")
  elseif main.is_buf_named() and main.is_buf_modified() then
    -- File has a name, prompt to save before quitting
    local choice = vim.fn.confirm("Save changes before quitting?", "&Yes\n&No\n&Cancel", 3)

    if choice == 1 then vim.cmd("wqa!") end
    if choice == 2 then vim.cmd("qa!") end
  else
    -- File is modified, but no name assigned, prompt to cancel or force quit
    local choice = vim.fn.confirm("Changes will be lost, quit anyways?", "&Yes\n&No", 2)
    if choice == 1 then vim.cmd("qa!") end
  end
end

function main.move_line_up()
  if not main.is_buf_modifiable_notify() then return end
  vim.api.nvim_command("move -2")
end
function main.move_line_down()
  if not main.is_buf_modifiable_notify() then return end
  vim.api.nvim_command("move +1")
end
function main.undo()
  if not main.is_buf_modifiable_notify() then return end
  vim.api.nvim_command("undo")
end
function main.redo()
  if not main.is_buf_modifiable_notify() then return end
  vim.api.nvim_command("redo")
end

function main.toggle_vterm() require("src.spruce.plugin.term.term").toggle("vertical") end
function main.toggle_hterm() require("src.spruce.plugin.term.term").toggle("horizontal") end
function main.toggle_fterm() require("src.spruce.plugin.term.term").toggle("floating") end

-- Placeholder for tabs in the main window

function main.tab_prev() end
function main.tab_next() end
function main.tab_close() end

-- Placeholder for find/replace

function main.find() end
function main.find_replace() end

-- Wincker

function main.win_jump() require("src.spruce.plugin.wincker").jump() end
function main.win_close()
  local res = require("src.spruce.plugin.wincker").select()
  if res == nil then return end
  if res.data == nil then
    vim.api.nvim_notify(
      "Window with mark: '" .. string.char(res.char) .. "' does not exist",
      vim.log.levels.ERROR,
      { title = "Wincker > Spruce API" }
    )
    return
  end
  -- main.quit closes all windows
  if vim.api.nvim_win_is_valid(res.data.winid) then
    if not main.is_buf_modified() then
      -- File is not modified, quit directly
      vim.cmd("q!")
    elseif main.is_buf_named() and main.is_buf_modified() then
      -- File has a name, prompt to save before quitting
      local choice = vim.fn.confirm("Save changes before quitting?", "&Yes\n&No\n&Cancel", 3)

      if choice == 1 then vim.cmd("wq!") end
      if choice == 2 then vim.cmd("q!") end
    else
      -- File is modified, but no name assigned, prompt to cancel or force quit
      local choice = vim.fn.confirm("Changes will be lost, quit anyways?", "&Yes\n&No", 2)
      if choice == 1 then vim.cmd("q!") end
    end
  end
end

-- Scroll emulation

-- Scroll the buffer view upcomment (cursor up)
---@param lines number?
function main.scroll_up(lines)
  if lines == nil then lines = 1 end
  local current_window = vim.api.nvim_get_current_win()
  local current_cursor = vim.api.nvim_win_get_cursor(current_window)
  local new_cursor = { current_cursor[1] - lines, current_cursor[2] }
  -- Prevent setting the cursor position outside the buffer
  if new_cursor[1] <= 0 then return end
  vim.api.nvim_win_set_cursor(current_window, new_cursor)
end

-- Scroll the buffer view down (cursor down)
---@param lines number?
function main.scroll_down(lines)
  if lines == nil then lines = 1 end
  local buf_size = vim.api.nvim_buf_line_count(0)
  local current_window = vim.api.nvim_get_current_win()
  local current_cursor = vim.api.nvim_win_get_cursor(current_window)
  local new_cursor = { current_cursor[1] + lines, current_cursor[2] }
  -- Prevent setting the cursor position outside the buffer
  if new_cursor[1] > buf_size then return end
  vim.api.nvim_win_set_cursor(current_window, new_cursor)
end

-- Function to get the appropriate indent string (spaces or tabs)
function main.get_indent_string()
  if vim.o.expandtab == true then
    return string.rep(" ", vim.o.tabstop)
  else
    return "\t"
  end
end

-- Function to add indentation
function main.add_indent()
  if not main.is_buf_modifiable_notify() then return end
  -- Check if Neovim is in visual mode
  if not main.is_visual() then
    -- If not in visual mode, operate on the current line
    local current_line = vim.api.nvim_get_current_line()
    local indent_str = main.get_indent_string()
    local new_line = indent_str .. current_line -- Add the appropriate indentation
    vim.api.nvim_set_current_line(new_line)
  else
    -- If in visual mode, operate on the selected range
    main.press_esc_key(vim.fn.mode()) -- Back to normal mode
    vim.schedule(function() -- Run later to read marks
      local line_start = vim.api.nvim_buf_get_mark(0, "<")[1]
      local line_end = vim.api.nvim_buf_get_mark(0, ">")[1]
      if line_start == line_end then line_start = line_start - 1 end

      -- Iterate over the lines and add indentation
      local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
      for i, line in pairs(lines) do
        local ln = line_start + (i - 1)
        local indent_str = main.get_indent_string()
        local new_line = indent_str .. line -- Add the appropriate indentation
        vim.api.nvim_buf_set_lines(0, ln - 1, ln, false, { new_line })
      end
    end)
  end
end

-- Function to remove indentation
function main.remove_indent()
  if not main.is_buf_modifiable_notify() then return end
  -- Check if Neovim is in visual mode
  if not main.is_visual() then
    -- If not in visual mode, operate on the current line
    local current_line = vim.api.nvim_get_current_line()
    local indent_str = main.get_indent_string()
    local new_line = current_line:gsub("^" .. indent_str, "") -- Remove leading whitespace or tabs
    vim.api.nvim_set_current_line(new_line)
  else
    -- If in visual mode, operate on the selected range
    main.press_esc_key(vim.fn.mode()) -- Back to normal mode
    vim.schedule(function() -- Run later to read marks
      local line_start = vim.api.nvim_buf_get_mark(0, "<")[1]
      local line_end = vim.api.nvim_buf_get_mark(0, ">")[1]
      if line_start == line_end then line_start = line_start - 1 end

      -- Iterate over the lines and remove indentation
      local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
      for i, line in pairs(lines) do
        local ln = line_start + (i - 1)
        local indent_str = main.get_indent_string()
        local new_line = line:gsub("^" .. indent_str, "") -- Remove leading whitespace or tabs
        vim.api.nvim_buf_set_lines(0, ln - 1, ln, false, { new_line })
      end
    end)
  end
end

-- Close the buffer but not the window
function main.close_buf()
  -- Replace current buffer with a empty buffer and close it
  local function do_close_buffer()
    local current_buffer = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(current_win, vim.api.nvim_create_buf(true, true))
    vim.api.nvim_buf_delete(current_buffer, { force = true })
  end
  if not main.is_buf_modified() then
    -- File is not modified, close directly
    do_close_buffer()
  elseif main.is_buf_named() and main.is_buf_modified() then
    -- File has a name, prompt to save before quitting
    local choice =
      vim.fn.confirm("Save changes before closing buffer?", "&Yes\n&No\n&Cancel", 3)

    if choice == 1 then vim.cmd("w!") end
    if choice == 2 then do_close_buffer() end
  else
    -- File is modified, but no name assigned, prompt to cancel or force quit
    local choice = vim.fn.confirm("Changes will be lost, close anyways?", "&Yes\n&No", 2)
    if choice == 1 then do_close_buffer() end
  end
end

function main.toggle_file_tree()
  -- Close the file tree only when buffer is the Tree (may be wrong)
  if str.starts_with((vim.fn.bufname() or "-"), "neo-tree") then
    vim.api.nvim_command("Neotree toggle")
  else
    vim.api.nvim_command("Neotree focus")
  end
end

function main.toggle_inlayhints()
  if vim.lsp.inlay_hint == nil then
    vim.api.nvim_notify(
      "Inlay hints are not available",
      vim.log.levels.ERROR,
      { title = "Spruce API" }
    )
    return
  end
  vim.lsp.inlay_hint(0, nil)
end

-- Duplicate current visual selection
function main.duplicate_selection()
  if not main.is_buf_modifiable_notify() then return end
  -- local curpos = vim.fn.getcurpos()
  main.press_esc_key(vim.fn.mode()) -- Back to normal mode
  vim.schedule(function()
    -- Get the visual selection range
    local line_start = vim.fn.getpos("'<")[2]
    local col_start = vim.fn.getpos("'<")[3]
    local line_end = vim.fn.getpos("'>")[2]
    local col_end = vim.fn.getpos("'>")[3]

    local lines = vim.fn.getline(line_start, line_end)

    -- If single line, duplicate string
    if #lines == 1 then
      vim.api.nvim_win_set_cursor(0, { line_start, col_end - 1 })
      vim.api.nvim_put({ lines[1]:sub(col_start, col_end) }, "", true, true)
      return
    end

    lines[1] = lines[1]:sub(col_start)
    lines[#lines] = lines[#lines]:sub(1, col_end)
    vim.api.nvim_win_set_cursor(0, { line_end, col_end - 1 })
    vim.api.nvim_put(lines, "", true, true)
  end)
end

-- Duplicate current line
function main.duplicate_line()
  if not main.is_buf_modifiable_notify() then return end
  local line_nr, _ = table.unpack(vim.api.nvim_win_get_cursor(0))
  local line_count = math.max(1, vim.v.count)
  local lines = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr + line_count - 1, false)
  local last_line = line_nr + line_count - 1
  vim.api.nvim_buf_set_lines(0, last_line, last_line, false, lines)
  -- Set Cursor to duplicated line
  local cursor_line, cursor_col = table.unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_win_set_cursor(0, { cursor_line + line_count, cursor_col })
end

-- Wrap the visual selection with the characters
---@param char table<string>
function main.wrap_selection(char)
  if char == nil then return end -- This never happens with keyboard shortcuts

  -- Get visual selection range
  main.press_esc_key(vim.fn.mode()) -- Back to normal mode
  vim.schedule(function()
    local line_start = vim.fn.getpos("'<")[2]
    local col_start = vim.fn.getpos("'<")[3]
    local line_end = vim.fn.getpos("'>")[2]
    local col_end = vim.fn.getpos("'>")[3]

    local lines = vim.fn.getline(line_start, line_end)

    local cur_buf = vim.api.nvim_get_current_buf()
    -- Wrap each line with the specified character at the given columns
    if line_start ~= line_end then -- Multiline
      local ln_strt = lines[1]:sub(1, col_start - 1) .. char[1] .. lines[1]:sub(col_start)
      vim.api.nvim_buf_set_lines(cur_buf, line_start - 1, line_start, false, { ln_strt })
      local ln_end = lines[#lines]:sub(1, col_end) .. char[2] .. lines[#lines]:sub(col_end + 1)
      vim.api.nvim_buf_set_lines(cur_buf, line_end - 1, line_end, false, { ln_end })
    else -- One line
      local ln = string.format(
        "%s%s%s%s%s",
        lines[1]:sub(1, col_start - 1),
        char[1],
        lines[1]:sub(col_start, col_end),
        char[2],
        lines[1]:sub(col_end + 1)
      )
      vim.api.nvim_buf_set_lines(cur_buf, line_start - 1, line_start, false, { ln })
    end
  end)
end

-- Give all functions a name for debugging purposes
for k, v in pairs(main) do
  main.k = setmetatable({ func = v }, {
    __call = function(self, ...) return self.func(...) end,
    __tostring = function(self) return k end,
  })
end

return main
