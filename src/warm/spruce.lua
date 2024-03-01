local main = {}

---Transforms the Spruce plugins table to lazy format
---@param table table
---@return table
function main.splug_to_lazy(table)
  local parsed = {}
  for _, v in pairs(table) do
    table.insert(parsed, v)
  end
  return parsed
end

---Safely require/load a file/module and set a fallback (default: nil)
---@generic T
---@param module string
---@param fallback? T
---@return T|unknown
function main.safe_require(module, fallback)
  local success, mod = pcall(require, module)
  if success then return mod end
  return fallback
end

---Lazy require a module item (require when item is used)
---@param require_path string
---@return table
function main.lazy_require(require_path)
  return setmetatable({}, {
    __call = function(_, ...) return require(require_path)(...) end,
    __index = function(_, key) return require(require_path)[key] end,
    __newindex = function(_, key, value) require(require_path)[key] = value end,
  })
end

---Iniitialize a iterator with args and collect all items into a list
---@param iter fun(...)
---@param ... any
---@return table
function main.collect(iter, ...)
  local tbl = {}
  for _, v in iter(...) do
    tbl[#tbl + 1] = v
  end
  return tbl
end

---Match it with keys of rules
--
-- Returns a function that checks for a match in keys of its
--
-- arg, and returns the value or return value if it's a function
---@generic V
---@param it string|integer
---@param def any|fun():any
---@return fun(rules:table<string|integer, V>):V
function main.match(it, def)
  return function(rules)
    if rules == nil or rules[it] == nil then
      if type(def) == "function" then
        return def()
      else
        return def
      end
    end
    ---@diagnostic disable-next-line: need-check-nil
    local item = rules[it]
    if type(item) == "function" then
      return item()
    else
      return item
    end
  end
end

---Returns the passed arguments in reversed order
---@generic items
---@param ... items
---@return items
function main.invert(...)
  local args = { ... }
  local reversed = {}
  for i = #args, 1, -1 do
    table.insert(reversed, args[i])
  end
  return table.unpack(reversed)
end

---Return a callable table, trying to emulate Rust's Result<>
---@param fn fun(...):unknown
---@param ... any
---@return table
---@nodiscard
function main.Result(fn, ...)
  local self = {
    args = { ... },
    fn = fn,
  }
  setmetatable(self, {
    __call = function()
      if self.args[1] == nil then
        self.succeded, self.val_or_err = pcall(fn)
      else
        self.succeded, self.val_or_err = pcall(fn, table.unpack(self.args))
      end
      -- Return the result value of the function
      ---@return any
      function self.unwrap()
        if self.succeded then return self.val_or_err end
        return nil
      end
      -- Return the error message/object
      ---@return any
      function self.unwrap_err()
        if not self.succeded then return self.val_or_err end
        return nil
      end
      -- Return the result value of the function, or a fallback value
      --
      -- If fallback is a function, its return value
      ---@generic F
      ---@param f nil|F|fun(err_obj:any):F
      ---@return F?
      function self.unwrap_or(f)
        if self.succeded then
          return self.val_or_err
        elseif type(f) == "function" then
          return f(self.val_or_err)
        else
          return f
        end
      end
      return self.succeded
    end,
  })
  return self
end

---Validate the arguments passed to it based on the given rules
---@param t ListScheme
---@param args any[]
function main.validate(t, args)
  ---@param s string
  ---@param f string
  ---@return string
  local function str_fallback(s, f)
    local cond = (s ~= nil and #s > 0 and type(s) == "string")
    if cond then return s end
    return f
  end
  local function s_has(s, str) return s:find(str) ~= nil end
  local concat_sep = str_fallback(t.sep, ", ")

  local default_ate = str_fallback(
    t.ate,
    "Unexpected argument type at position {:pos:}: Expected {:qw1:} {:qw2:} [{:types:}], got '{:type:}'"
  )
  local default_ave = str_fallback(
    t.ave,
    "Invalid value for argument at position {:pos:}: Expected values are [{:pv:}], got '{:arg:}'"
  )
  for i, arg_rule in ipairs(t) do
    local expected_types
    if type(arg_rule) == "table" then
      expected_types = arg_rule
    else
      expected_types = { arg_rule }
    end
    local expected_values = arg_rule.aev
    local arg_type_error_message = str_fallback(arg_rule.ate, default_ate)
    local arg_value_error_message = str_fallback(arg_rule.ave, default_ave)
    local arg = args[i]
    -- Check if the argument matches any of the expected types
    local unexpected_type = true
    local arg_type = type(arg)
    for _, expected_type in ipairs(expected_types) do
      if
        not s_has(
          "some,nil,boolean,number,string,table,function,thread,userdata",
          expected_type
        )
      then
        error("Invalid data type '" .. expected_type .. "'")
      end
      -- "some" is "Any value but nil"
      if expected_type == "some" and arg_type == "nil" then break end
      if arg_type == expected_type or expected_type == "some" then
        unexpected_type = false
        break
      end
    end
    if unexpected_type then
      local qw = { "type", "is" }
      if #expected_types > 1 then -- Match words with the item count
        qw = { "types", "are" }
      end
      error(
        arg_type_error_message
          :gsub("{:qw1:}", qw[1])
          :gsub("{:qw2:}", qw[2])
          :gsub("{:pos:}", tostring(i))
          :gsub("{:type:}", arg_type)
          :gsub("{:types:}", table.concat(expected_types, concat_sep))
          :gsub("{:arg:}", tostring(arg))
      )
    end
    -- Check if the argument is within the expected values
    if expected_values then
      local is_valid_value = false
      for _, value in ipairs(expected_values) do
        if arg == value then
          is_valid_value = true
          break
        end
      end
      if not is_valid_value then
        error(
          arg_value_error_message
            :gsub("{:arg:}", tostring(arg))
            :gsub("{:pos:}", tostring(i))
            :gsub("{:pv:}", table.concat(expected_values, concat_sep))
        )
      end
    end
  end
end

---Validate and parse a string
---@generic T
---@param t ArgParseScheme
---@param args T
---@return T
---@nodiscard
function main.parse_args(t, args)
  main.validate(t, args)
  local parsed_args = {}
  for i, arg_rule in ipairs(t) do
    local arg = args[i]
    if arg == nil then
      parsed_args[i] = arg_rule.def
    else
      parsed_args[i] = arg
    end
  end
  return parsed_args
end

return main
