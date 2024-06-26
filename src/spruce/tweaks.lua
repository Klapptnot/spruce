---@diagnostic disable: deprecated

SPRUCE_TWEAKS = {
  detect_indent = false,
  reset_cursor = false,
  lua_functions = false,
}

local tweaks_fns = {
  detect_indent = function()
    -- Set indentation based on guesses, works better btw
    vim.api.nvim_create_augroup("SetIndentation", { clear = true })
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      group = "SetIndentation",
      callback = function()
        local indent = require("src.furnace.gindent")
        local width = indent.guess()
        if width == nil then return end
        vim.bo.shiftwidth = width
        vim.bo.tabstop = width
        vim.bo.softtabstop = width
      end,
    })
    SPRUCE_TWEAKS.detect_indent = true
  end,
  reset_cursor = function()
    -- Reset cursor style on exit
    vim.api.nvim_create_autocmd({ "VimLeave" }, {
      pattern = { "*" },
      command = 'set guicursor= | call chansend(v:stderr, "\\x1b[ q")',
    })

    SPRUCE_TWEAKS.reset_cursor = true
  end,

  lua_functions = function()
    -- !! Neovim has Lua 5.1, so make it appear Lua 5.4
    -- !! moving unpack to table.unpack
    -- !! making forward compatibility easy (When available, remove this)
    table.unpack = unpack

    ---Simple check if string contains other string inside
    --
    ---Patterns are escaped and matched as single string
    -- ```lua
    -- local valid_types = "string,number"
    -- assert(valid_types:has(type(v)), 'argument #1 must be either string or number')
    -- ```
    ---@param s string
    ---@param str string
    ---@return boolean
    string.has = function(s, str)
      return s:find(str:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")) ~= nil
    end

    ---Print string to `stdout`.
    ---Same as print(string), but avoiding weird editing
    -- ```lua
    -- local fmt = '%d.%d.%d'
    -- fmt:format(major, minor, patch):print()
    -- ```
    ---@param s string
    string.print = function(s) print(s) end

    ---Write string to default output file (mainly `stdout`).
    ---Used to `print()` without trailing `\n`
    -- ```lua
    -- local fmt = '%d.%d.%d'
    -- fmt:format(major, minor, patch):put()
    -- ```
    ---@param s string
    string.put = function(s) io.write(s) end
    SPRUCE_TWEAKS.lua_functions = true
  end,
}

local main = {}

---Apply tweaks to the runtime environment and functionality

function main.apply(tweaks)
  local failed = {}
  for i, v in ipairs(tweaks) do
    if tweaks_fns[v] ~= nil then
      tweaks_fns[v]()
    else
      failed[#failed + 1] = i
    end
  end
  return failed
end

return main
