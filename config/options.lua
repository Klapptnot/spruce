--& Default Spruce Nvim options
--& add your own options in
--& ~/.config/nvim/overrides/options/init.lua

local __options__ = require("config.data.options")

local main = {}

---Return a new instance of options table
---@param tbl table?
---@return table
function main:new(tbl)
  local self = tbl or __options__
  setmetatable(self, { __index = main })
  return self
end

---Merge an options table into self
---@param tbl any
function main:merge(tbl) return self:new(vim.tbl_deep_extend("force", self, tbl)) end

---Add a new option into self
---@param id string
---@param props any
function main:add(id, props)
  if self[id] == nil then self[id] = props end
  return self
end

---Apply the options to nvim
---@param self any
function main:apply()
  for k, v in pairs(self) do
    vim.opt[k] = v
  end
end

return main
