--& Config loader for Spruce

local main = {
  globals = require("config.globals"):new(),
  mapping = require("config.mapping"):new(),
  options = require("config.options"):new(),
  plugins = require("config.plugins"):new(),
} -- Return all configs

return main
