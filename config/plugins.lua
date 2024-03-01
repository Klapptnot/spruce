--& Default Spruce Nvim plugins
--& add your own plugins in
--& ~/.config/nvim/overrides/plugins/init.lua

local __plugins__ = require("config.data.plugins")

local main = {}

---Return a new instance of plugins table
---@param tbl table?
---@return table
function main:new(tbl)
  local self = tbl or __plugins__
  setmetatable(self, { __index = main })
  return self
end

---Merge a table of plugins definitions into self
---@param tbl any
function main:merge(tbl) return self:new(vim.tbl_deep_extend("force", self, tbl)) end

---Add a plugin definition into self
---@param id string
---@param props table
function main:add(id, props)
  if self[id] == nil then self[id] = props end
  return self
end

---Return the table of plugins as lazy.nvim requires.
---@param self table
function main:getlazy() --, parse)
  -- local parse = (parse ~= nil or parse == true) or false
  -- if not parse then
  --   return self.__all__
  -- end
  local parsed = {}
  for k, v in pairs(self) do
    v[1] = k
    table.insert(parsed, v)
  end
  return parsed
end

---Install all plugins using lazy.nvim
---@param lazy_cfg table
function main:apply(lazy_cfg)
  local lazy_cfg = (lazy_cfg ~= nil and type(lazy_cfg) == "table") and lazy_cfg or {}
  require("lazy").setup(self:getlazy(), lazy_cfg)
end

return main
