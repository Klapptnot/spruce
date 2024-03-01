--& Here is where your customization loads
-- add your own ...
-- globals, mapping, options, plugins
-- folders and put there an init.lua file
-- with the same structure as the default ones
-- do not add any method
-- example:
--
-- local main = {
--   n = {
--     {
--       mapp = "e",
--       exec = function() end,
--       desc = "So domething", -- So domething
--       opts = { expr = false },
--     },
--   },
-- }
-- return main

local function safe_require(module, fallback)
  local success, mod = pcall(require, module)
  if success then return mod end
  return fallback
end

return {
  globals = safe_require("override.globals", {}),
  mapping = safe_require("override.mapping", {}),
  options = safe_require("override.options", {}),
  plugins = safe_require("override.plugins", {}),
}
