--&& Spruce Nvim initialization

--!! Neovim has Lua 5.1, so make it appear Lua 5.4
--!! moving unpack to table.unpack
---@diagnostic disable-next-line: deprecated
table.unpack = unpack
---Simple check if string contains other string inside
---@param s string
---@param str string
---@return boolean
string.has = function(s, str) return s:find(str) ~= nil end
---Print string to `stdout`
---@param s string
string.print = function(s) print(s) end
---Terminates the last protected function called and returns string as the error object.
---
---Usually, `error` adds some information about the error position at the beginning of the message, if the message is a string.
---@param s any
---@param level?  integer
string.error = function(s, level) error(s, level) end

--#region First of all, prepare package.path
do
  local vcfg = vim.fn.stdpath("config")
  ---@cast vcfg string
  if string.find(package.path, vcfg, 1, true) then return end
  package.path = package.path .. ";" .. vcfg .. "/?/init.lua;" .. vcfg .. "/?.lua"
end
--#endregion

-- Initialize things that needs to be downloaded, like lazy
require("src.bootstrap")

-- Run tweaks on nvim behavior
require("src.spruce.tweaks")

local config = require("config")
local custom = require("custom.init")

config.mapping:disable_mapp("<C-z>") -- disable background when <C-z>
--#region Merge and load configuration
config.globals:merge(custom.globals):apply()
config.mapping:merge(custom.mapping):apply()
config.options:merge(custom.options):apply()
config.plugins:merge(custom.plugins):apply()
--#endregion

-- Load spruce files
require("src.spruce")
