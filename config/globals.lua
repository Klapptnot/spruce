--& Default Spruce Nvim globals
--& add your own globals in
--& ~/.config/nvim/overrides/globals/init.lua

local __globals__ = require("config.data.globals")

local main = {}

---Return a instance of globals table
---@param tbl table?
---@return table
function main:new(tbl)
  local self = tbl or __globals__
  setmetatable(self, { __index = main })
  return self
end

---Add a new global into self
---@param id string
---@param props any
function main:add(id, props)
  if self[id] == nil then self[id] = props end
  return self
end

---Merge the given table into self
---@param tbl table
function main:merge(tbl) return self:new(vim.tbl_deep_extend("force", self, tbl)) end

---Apply globals to nvim
function main:apply()
  for k, v in pairs(self) do
    vim.g[k] = v
  end
end

return main
