-- String manipulation utils

local main = {}
local spruce = require("src.warm.spruce")

---Remove trailing and leading spaces
---@param s string
---@return string
function main.strip(s) return (string.gsub(s, "^[\n|%s]*(.-)[\n|%s]*$", "%1")) end
---Return the first space separated string (first word)
---@param s string
---@return string
function main.pre_string(s) return string.match(s, "[^%s]+") end
---Return the last space separated string (last word)
---@param s string
---@return string
function main.sub_string(s) return string.match(s, "[^%s]+$") end
---@param s string
---@param substr string
---@return boolean
function main.starts_with(s, substr)
  spruce.validate({ "string", "string" }, { s, substr })
  return s:sub(1, #substr) == substr
end
---@param s string
---@param ending string
---@return boolean
function main.ends_with(s, ending)
  spruce.validate({ "string", "string" }, { s, ending })
  return ending == "" or s:sub(-#ending) == ending
end
---Return str if is not nil or zero length, otherwise returns fallback
---@param s string
---@param fallback string
---@return string
function main.fallback(s, fallback)
  local cond = (s ~= nil and #s > 0 and type(s) == "string")
  if cond then return s end
  return fallback
end
---Return the first non-zero length item or returns fallback
---@param fallback string
---@param ... string
---@return string
function main.first_not_empty(fallback, ...)
  local all = { ... }
  for _, str in ipairs(all) do
    local cond = (str ~= nil and #str > 0 and type(str) == "string")
    if cond then return str end
  end
  return fallback
end
---String as false/string (String is always true)
---Returns false if string is empty
---Returns string if string is not empty
---@param s string
---@return boolean|string
function main.boolean(s)
  spruce.validate({ "string" }, { s })
  if s ~= nil and #s > 0 then return s end
  return false
end

---Split a string into a list of strings
---By default, split by spaces
---Use vim.split(str, sep, true) to split
---@param s string
---@param sep string?
---@return string[]
function main.split(s, sep)
  local items = {}
  for item in string.gmatch(s .. sep, "(.-)" .. sep) do
    table.insert(items, item)
  end
  return items
end
---Split to characters
---Use vim.split(str, '', true)
---@param s string
---@return table
function main.chars(s)
  local chars = {}
  for i = 1, #s do
    table.insert(chars, string.sub(s, i, i))
  end
  return chars
end

-- Check if string has certain string or character
--
-- warm.str.is_has("abcdef", "def") -- true
--
-- warm.str.is_has("a,b,c,d,e,f", "def") -- false
---@param s string
---@param str string
---@return boolean
function main.has(s, str) return string.find(s, str) ~= nil end

---Add padding to s to be n length, default pad right
---@param s string
---@param n integer
---@param fill string|number
---@param algn "<"|"^"|">"
---@return string
function main.pad(s, n, fill, algn)
  s = main.fallback(s, "")
  n = tonumber(n) - 0
  if #s >= n then return s end
  algn = main.fallback(algn, "<")
  fill = main.fallback(tostring(fill), " ")
  fill = fill:rep(n):sub(1, n - #s)

  if algn == "<" then
    s = s .. fill
  elseif algn == ">" then
    s = fill .. s
  elseif algn == "^" then
    local lfill = string.sub(fill, 1, math.ceil(#fill / 2))
    local rfill = string.sub(fill, 1, math.floor(#fill / 2))
    s = lfill .. s .. rfill
  end
  return s
end

---String format using brackets instead of C style placeholders
--
-- ```lua
-- str.format("{} version {}.", "soil", 1.0) -- "soil version 1.0"
-- str.format("From: {:<8}| At: {8:>}|", "source", "path") -- "From: source  | At:     path|"
-- str.format("Var: {:_^20}.", "APP_VERSION") -- "Var: _____APP_VERSION____."
-- str.format("Grab: {:10}.", "none") -- "Grab:       none."
-- str.format("[3: {3}, 1: {}, 4: {4}, 2: {}]", "one", "two", "three", "four") -- [3: three, 1: one, 4: four, 2: two]
-- ```
---@param s string
---@param ... any
---@return string
function main.format(s, ...)
  local args = { ... }
  local i = 1

  local function replacement(m)
    if m == "" then
      i = i + 1
      return args[i - 1] or ""
    end
    local w = tonumber(m:match("(%d+)$")) or 0
    local d = m:match("([<^>]?)%d+$") or ">"
    local c = m:match(":(.)[<^>]%d+$") or " "
    local n = tonumber(m:match("^(%d*)"))
    if n == nil then
      n = i
      i = i + 1
    end
    m = main.pad(tostring(args[n]), w, c, d)
    return m
  end

  s = s:gsub("{{(.*)}}", "\\{%1\\}")
    :gsub("{(%d*:.?[<^>]?%d*)}", replacement)
    :gsub("{(%d*)}", replacement)
    :gsub("\\{(.*)\\}", "{%1}")
  return s
end

main.lower = string.lower
main.upper = string.upper

return main
