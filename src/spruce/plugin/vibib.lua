--& Spruce Nvim statusline 'vibib'

local main = {}

main.path = require("src.warm.path")
main.str = require("src.warm.str")

main.functions = {
  change_cwd = function()
    local win = require("plenary.popup").create("", {
      title = "New CWD",
      style = "minimal",
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      borderhighlight = "pathBr",
      titlehighlight = "pathToGo",
      focusable = true,
      width = 50,
      height = 1,
    })

    vim.cmd("normal A")
    vim.cmd("startinsert")

    vim.keymap.set({ "i", "n" }, "<Esc>", "<cmd>q<CR>", { buffer = 0 })

    vim.keymap.set({ "i", "n" }, "<CR>", function()
      local new = vim.trim(vim.fn.getline("."))
      vim.api.nvim_win_close(win, true)
      vim.cmd.stopinsert()
      vim.fn.chdir(new)
    end, { buffer = 0 })
  end,
}
for name, _ in pairs(main.functions) do
  vim.api.nvim_command(
    "function! __PRIVATE_"
      .. name
      .. "(_, __, ___, ____)\n"
      .. "lua require('src.spruce.plugin.vibib').functions."
      .. name
      .. "()\n"
      .. "endfunction\n"
  )
end

-- At any run, function id will be added here
-- so we can't run any function twice
-- main.__call_stack = {}

-- ---Avoid running function twice in the same line
-- ---@param self table
-- ---@param identifier string
-- ---@return boolean
-- function main:__can_run_mod(identifier)
--   if self.__call_stack[identifier] ~= nil then return false end
--   self.__call_stack[identifier] = true
--   return true
-- end

---Is current window the statusline/active window
---@return boolean
function main:__is_stl_win() return vim.api.nvim_get_current_win() == vim.g.statusline_winid end
---The ID of the statusline window buffer
---@return integer
function main:__stl_buf() return vim.api.nvim_win_get_buf(vim.g.statusline_winid) end
---Returns the current vim mode
---@return string
function main:__getmode() return self.str.fallback(vim.api.nvim_get_mode().mode, "sp") end
---Check if there is available git(signs) support
---@param self table
---@return boolean
function main:__is_git_avlb()
  return vim.b[self:__stl_buf()].gitsigns_head or vim.b[self:__stl_buf()].gitsigns_git_status
end

-- This table was initialy copied from
-- nvchad statusline
-- to get the posible modes
main.vim_modes = {
  ["n"] = { "NORMAL", "SCupcake03Mod" },
  ["no"] = { "NORMAL (no)", "SCupcake03Mod" },
  ["nov"] = { "NORMAL (nov)", "SCupcake03Mod" },
  ["noV"] = { "NORMAL (noV)", "SCupcake03Mod" },
  ["noCTRL-V"] = { "NORMAL", "SCupcake03Mod" },
  ["niI"] = { "NORMAL i", "SCupcake03Mod" },
  ["niR"] = { "NORMAL r", "SCupcake03Mod" },
  ["niV"] = { "NORMAL v", "SCupcake03Mod" },
  ["nt"] = { "NTERMINAL", "SCupcake11Mod" },
  ["ntT"] = { "NTERMINAL (ntT)", "SCupcake11Mod" },

  ["v"] = { "VISUAL", "SCupcake05Mod" },
  ["vs"] = { "V-CHAR (Ctrl O)", "SCupcake05Mod" },
  ["V"] = { "V-LINE", "SCupcake05Mod" },
  ["Vs"] = { "V-LINE", "SCupcake05Mod" },
  [""] = { "V-BLOCK", "SCupcake05Mod" },

  ["i"] = { "INSERT", "SCupcake06Mod" },
  ["ic"] = { "INSERT (completion)", "SCupcake06Mod" },
  ["ix"] = { "INSERT completion", "SCupcake06Mod" },

  ["t"] = { "TERMINAL", "SCupcake12Mod" },

  ["R"] = { "REPLACE", "SCupcake08Mod" },
  ["Rc"] = { "REPLACE (Rc)", "SCupcake08Mod" },
  ["Rx"] = { "REPLACEa (Rx)", "SCupcake08Mod" },
  ["Rv"] = { "V-REPLACE", "SCupcake08Mod" },
  ["Rvc"] = { "V-REPLACE (Rvc)", "SCupcake08Mod" },
  ["Rvx"] = { "V-REPLACE (Rvx)", "SCupcake08Mod" },

  ["s"] = { "SELECT", "SCupcake07Mod" },
  ["S"] = { "S-LINE", "SCupcake07Mod" },
  [""] = { "S-BLOCK", "SCupcake07Mod" },
  ["c"] = { "COMMAND", "SCupcake02Mod" },
  ["cv"] = { "COMMAND", "SCupcake02Mod" },
  ["ce"] = { "COMMAND", "SCupcake02Mod" },
  ["r"] = { "PROMPT", "SCupcake15Mod" },
  ["rm"] = { "MORE", "SCupcake15Mod" },
  ["r?"] = { "CONFIRM", "SCupcake15Mod" },
  ["x"] = { "CONFIRM", "SCupcake15Mod" },
  ["!"] = { "SHELL", "SCupcake12Mod" },
  ["sp"] = { "SPRUCE", "SSpruceMod" },
}

local unicode_icons = {
  [1] = "▬", -- Horizontal bar
  [2] = "●", -- Filled circle
  [3] = "▲", -- Triangle
  [4] = "◆", -- Diamond
  [5] = "◐", -- Circle with a dot in the center
  [6] = "◓", -- Circle with a small circle inside
  [7] = "◌", -- Empty circle
  [8] = "□", -- Square
  [9] = "◠", -- Semicircle (upper)
  [10] = "◡", -- Semicircle (lower)
  [11] = "⌒", -- Wide tilde
  [12] = "≈", -- Approximately equal to
  [13] = "∆", -- Delta symbol
  [14] = "◇", -- Diamond shape
  [15] = "█", -- Full block
  [16] = "▌", -- Left half block
  [17] = "▐", -- Right half block
  [18] = "▉", -- Upper one-eighth block
  [19] = "▊", -- Lower one-eighth block
  [20] = "◤", -- Upper left corner block
  [21] = "◥", -- Upper right corner block
  [22] = "◣", -- Lower right corner block
  [23] = "◢", -- Lower left corner block
  [24] = "▭", -- Rectangle with horizontal line in the middle
  [25] = "", -- Left half rhombus
  [26] = "", -- Right half rhombus
  [27] = "", -- Left-down diagonal half block
  [28] = "", -- Right-up diagonal half block
  [29] = "", -- Left-up diagonal half block
  [30] = "", -- Right-down diagonal half block
  [31] = "", -- Left half circle
  [32] = "", -- Right half circle
}

function main:mode()
  -- if not self:__can_run_mod("3ZLpgc-QJFo-RYad") then return "" end
  local mode, color = table.unpack(self.vim_modes[self:__getmode()])
  return string.format("%%#%s#  %s ", color, mode)
end

function main:file()
  -- if not self:__can_run_mod("XETHmf-qiPN-lCpo") then return "" end
  local icon = "󰈚 " -- Default icon
  local filepath = vim.api.nvim_buf_get_name(self:__stl_buf())
  local file = (self.str.boolean(filepath) and self.path.basename(filepath)) or "Empty"

  -- Get the right icon for the file
  if file ~= "Empty" then
    -- Safe load, require exits if SOMEONE removed dependencies
    local loaded, devicons = pcall(require, "nvim-web-devicons")
    if loaded then icon = devicons.get_icon(file) or icon end
  end

  return string.format("%%#BCupcake05Mod# %s %s %%#UnsetAllFlags#", icon, file)
end

function main:file_type()
  -- if not self:__can_run_mod("Fr4qAx-q8La-j1Pp") then return "" end
  local type = self.str.fallback(vim.bo[self:__stl_buf()].filetype, "unknown")
  return "%#FSpruceBol# " .. type .. " %#UnsetAllFlags#"
end

function main:file_eol()
  -- if not self:__can_run_mod("ayctb4-ycuo-GvDa") then return "" end
  -- local eol = self.str.fallback(vim.bo[self:__stl_buf()].eol, "")
  local eol = ""
  return "%#FSpruceBol# " .. eol .. " %#UnsetAllFlags#"
end

function main:file_encoding()
  -- if not self:__can_run_mod("A1rvg0-VUZS-fByJ") then return "" end
  local enc = self.str.fallback(vim.bo[self:__stl_buf()].fileencoding, "")
  return "%#FSpruceBol# " .. enc .. " %#UnsetAllFlags#"
end

function main:cursor_position()
  -- if not self:__can_run_mod("3VT9yt-yc98-6Rit") then return "" end
  return "%#FCupcake16Def# Ln %l, Col %c %#UnsetAllFlags#"
end

function main:git_info()
  -- if not self:__can_run_mod("oUXYrH-JD3K-hs93") then return "" end
  -- If not info from git, return empty string
  if not self:__is_git_avlb() then return "" end
  -- Return info about git branch
  return string.format(
    " %s %%#UnsetAllFlags#",
    vim.b[self:__stl_buf()].gitsigns_status_dict.head
  )
end

function main:git_file_changes()
  -- if not self:__can_run_mod("5lXCJq-WY4o-LM1U") then return "" end
  if not self:__is_git_avlb() then return "" end
  local gst = vim.b[self:__stl_buf()].gitsigns_git_status
  gst = {
    gst.removed,
    gst.added,
    gst.changed,
  }
  local mod = { "", "", "" }
  if gst[1] and gst[1] > 0 then mod[3] = "%#FCupcake10Def#  " .. mod[1] end
  if gst[2] and gst[2] > 0 then mod[1] = "%#FCupcake11Def#  " .. mod[2] end
  if gst[3] and gst[3] > 0 then mod[2] = "%#FCupcake12Def#  " .. mod[3] end
  return table.concat(mod, "") .. "%#UnsetAllFlags#"
end

function main:lsp_loaded()
  -- if not self:__can_run_mod("HbgSLf-hHZN-SKjg") then return "" end
  if not rawget(vim, "lsp") then return "" end
  local buf = self:__stl_buf()
  for _, lsp in ipairs(vim.lsp.get_active_clients()) do
    if lsp.name == "null-ls" then goto continue end -- Lua pls, add continue
    if lsp.attached_buffers[buf] then
      return "%#FCupcake16Def#   " .. lsp.name .. " %#UnsetAllFlags#"
    end
    ::continue::
  end
  return ""
end

function main:lsp_diagnotstic()
  -- if not self:__can_run_mod("kDN5a2-Kgh9-Vbsq") then return "" end
  if not rawget(vim, "lsp") then return "" end
  local buf = self:__stl_buf()
  local stat = {
    #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.INFO }),
    #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.HINT }),
    #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.WARN }),
    #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR }),
  }
  local stats = { "", "", "", "" } --        
  if stat[1] and stat[1] > 0 then stats[1] = "%#FCupcake11Def#  " .. stat[1] end
  if stat[2] and stat[2] > 0 then stats[2] = "%#FCupcake13Def#  " .. stat[2] end
  if stat[3] and stat[3] > 0 then stats[3] = "%#FCupcake04Def#  " .. stat[3] end
  if stat[4] and stat[4] > 0 then stats[4] = "%#FCupcake02Def#  " .. stat[4] end
  return table.concat(stats, "") .. " %#UnsetAllFlags#"
end

function main:cwd()
  -- if not self:__can_run_mod("VylQyY-5hfy-SfIX") then return "" end
  return "%#BSpruceDef#%@__PRIVATE_change_cwd@ 󰉖 "
    .. self.str.fallback(self.path.basename(vim.fn.getcwd()), "")
    .. " %T%#UnsetAllFlags#"
end

function main:load()
  -- Make it available everywhere
  vim.opt.statusline = '%!v:lua.require("src.spruce.plugin.vibib").run()'
  self.__enabled = true
  -- Add some vim commands
  vim.api.nvim_create_user_command(
    "VibibDebug",
    function()
      print(
        string.format(
          "{ buf_id = %s, mode = '%s', is_stl = %s, git_aval = %s, stl_win = %s, cur_win = %s }",
          self:__stl_buf(),
          self:__getmode(),
          self:__is_stl_win(),
          self:__is_git_avlb(),
          self.__stl_win__,
          vim.api.nvim_get_current_win()
        )
      )
    end,
    {}
  )
  vim.api.nvim_create_user_command("VibibToggle", function()
    if self.__enabled then
      vim.opt.statusline = ""
      self.__enabled = false
    else
      vim.opt.statusline = "%!v:lua.Vibib.run()"
      self.__enabled = true
    end
  end, {})
end

function main.run()
  local self = main -- Emulate method behavior, normally doesn't work
  -- local shorten = vim.o.columns < 120
  local buf_ft = self.str.fallback(vim.bo[self:__stl_buf()].filetype, "unknown")
  if not self:__is_stl_win() then
    return "%#CupcakeDark#  INACTIVE>%#UnsetAllFlags#%=" .. self:file_type()
  end
  if self.str.has("neo-tree,Outline", buf_ft) then
    return self:mode() .. " in " .. buf_ft .. "%#UnsetAllFlags#"
  end
  local bar_contents = {
    self:mode(),
    self:file(),
    self:git_info(),
    self:lsp_loaded(),
    self:lsp_diagnotstic(),
    "%=", -- Shift everything else next to the right
    self:git_file_changes(),
    self:cursor_position(),
    self:file_type(),
    self:file_encoding(),
    self:file_eol(),
    self:cwd(),
  }
  -- Reset the call stack after one statusline generation
  -- self.__call_stack = {}
  return tostring(table.concat(bar_contents)) .. " "
end

return main
