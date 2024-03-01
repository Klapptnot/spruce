--& Default Spruce Nvim mappings
--& add your own custom mappings in
--& ~/.config/nvim/overrides/mapping/init.lua

local __map__ = require("config.data.mapping")

local main = {}

---Return a new instance of mapping table
---@param tbl table?
---@return table
function main:new(tbl)
  local self = tbl or __map__
  setmetatable(self, { __index = main })
  return self
end

---Merge mappings table into self
---@param tbl table
---@return table
function main:merge(tbl) return self:new(vim.tbl_deep_extend("force", self, tbl)) end

---Disable the mapp in the most common modes
---@param mapp string
function main:disable_mapp(mapp)
  if mapp == nil then return end
  local modes = { "n", "v", "i", "t", "x", "s", "o", "c", "!", "l" }
  local opts = { noremap = false, silent = true }
  for _, mode in ipairs(modes) do
    vim.keymap.set(mode, mapp, "<NOP>", opts)
  end
  return self
end

---Disable the mouse mappings
function main:disable_mouse()
  local mouse_events = {
    "<LeftMouse>",
    "<LeftDrag>",
    "<LeftRelease>",
    "<RightMouse>",
    "<RightDrag>",
    "<RightRelease>",
    "<MiddleMouse>",
    "<MiddleDrag>",
    "<MiddleRelease>",
    "<ScrollWheelUp>",
    "<ScrollWheelDown>",
    "<ScrollWheelLeft>",
    "<ScrollWheelRight>",
  }
  for _, v in ipairs(mouse_events) do
    self:disable_mapp(v)
  end
  return self
end

---Add one keybinding to the table
---@param id string
---@param props table
function main:add(id, props)
  if self[id] == nil then self[id] = props end
  return self
end

local Result = require("src.warm.spruce").Result
local fmt = require("src.warm.str").format

---Apply all mappings to nvim
function main:apply()
  for _, props in pairs(self) do
    if type(props.exec) == "function" then
      props.opts.callback = props.exec
      props.exec = ""
    end
    props.opts.desc = props.desc -- Just to not nest items
    for _, mode in ipairs(props.mode) do
      local r = Result(vim.api.nvim_set_keymap, mode, props.mapp, props.exec, props.opts)
      if not r() then
        fmt("Mapping error for '{}': {}", tostring(props.desc), r.unwrap_err()):print()
      end
    end
  end
  return self
end

return main
