--& Spruce configurator

local warm = require("src.warm")

local main = {}

main.old_buf = nil
main.cgf_open = nil
---@param file_path string
---@return integer
---@return integer
---@return integer
function main.replace_buffer(file_path)
  local cur_buf = vim.api.nvim_get_current_buf()
  local cur_win = vim.api.nvim_get_current_win()
  -- local buf = vim.api.nvim_create_buf(true, true) -- New buffer
  local buf = vim.fn.bufadd(file_path) or 0 -- New buffer

  ---@diagnostic disable-next-line: missing-return-value
  if buf == 0 then return end

  ---@diagnostic disable-next-line: undefined-field
  vim.api.nvim_buf_set_option(buf, "buflisted", false) -- Set as unlisted/hidden
  vim.api.nvim_win_set_buf(cur_win, buf) -- Atach the buffer to window
  return cur_win, buf, cur_buf
end

vim.api.nvim_create_user_command("SpruceConfig", function(opts)
  local file = opts.fargs[1]
  local function cfg_file_exist(item)
    return warm.table.contains({
      "mapping",
      "options",
      "globals",
      "plugins",
    }, item)
  end
  if main.cur_into ~= nil and file ~= "--exit" then
    vim.api.nvim_notify(
      "A config file (" .. main.cur_into[1] .. ") is already open",
      vim.log.levels.INFO,
      { title = "Spruce Config" }
    )
    return
  end
  if file == "--help" then
    vim.api.nvim_command("help SpruceConfig")
  elseif file == "--exit" then
    if main.cur_into == nil then
      vim.api.nvim_notify(
        "No config to close",
        vim.log.levels.INFO,
        { title = "Spruce Config" }
      )
      return
    end
    local bufto = main.cur_into[3]
    if main.cur_into[4] == 0 then
      vim.api.nvim_notify(
        "Config file closed successfully",
        vim.log.levels.INFO,
        { title = "Spruce Config" }
      )
      vim.api.nvim_buf_delete(bufto, { force = true })
      main.cur_into = nil
      return
    end
    vim.api.nvim_notify(
      "Config file closed successfully, returning to the previous buffer",
      vim.log.levels.INFO,
      { title = "Spruce Config" }
    )
    local winto = main.cur_into[2]
    vim.api.nvim_win_set_buf(winto, main.cur_into[4])
    -- Also delete the config buffer
    vim.api.nvim_buf_delete(bufto, { force = true })
    main.cur_into = nil
    return
  elseif file == "--init" then
    local cfg_file = vim.fn.stdpath("config") .. "/init.lua"
    local w, b, p = main.replace_buffer(cfg_file)
    main.cur_into = { "init.lua", w, b, p }
    return
  elseif file == "--config" then
    local cfg_file = vim.fn.stdpath("config") .. "/config/init.lua"
    local w, b, p = main.replace_buffer(cfg_file)
    main.cur_into = { "config/init.lua", w, b, p }
    return
  elseif file == "--custom" then
    local ov_file = "/custom/init.lua"
    if warm.str.boolean(opts.fargs[2]) then
      if not cfg_file_exist(opts.fargs[2]) then
        vim.api.nvim_notify(
          "The requested config file does not exist",
          vim.log.levels.WARN,
          { title = "Spruce Config" }
        )
        return
      end
      ov_file = "/custom/" .. opts.fargs[2] .. ".lua"
    end
    local cfg_file = vim.fn.stdpath("config") .. ov_file
    local w, b, p = main.replace_buffer(cfg_file)
    main.cur_into = { "custom/init.lua", w, b, p }
    return
  end
  if main.cur_into ~= nil then
    vim.api.nvim_notify(
      "Config file '" .. main.cur_into[1] .. "' already open",
      vim.log.levels.WARN,
      { title = "Spruce Config" }
    )
    return
  end
  if not cfg_file_exist(file) then
    vim.api.nvim_notify(
      "The requested config file does not exist",
      vim.log.levels.WARN,
      { title = "Spruce Config" }
    )
    return
  end
  local cfg_type = "/config/data/"
  if opts.fargs[2] == "--custom" then cfg_type = "/custom/" end
  local cfg_file = vim.fn.stdpath("config") .. cfg_type .. file .. ".lua"
  local w, b, p = main.replace_buffer(cfg_file)
  main.cur_into = { cfg_type .. file .. ".lua", w, b, p }
end, {
  desc = "Open configuration files",
  nargs = "+",
  complete = function(arglead, cmdline, curpos)
    local cmp = {
      "mapping",
      "options",
      "globals",
      "plugins",
      "--exit",
      "--init",
      "--help",
      "--config",
      "--custom",
    }
    if arglead == "" or warm.str.starts_with(arglead, " ") then return cmp end
    cmp = warm.table.filter(
      cmp,
      function(_, v) return warm.str.starts_with(v, arglead) end,
      false
    )
    if #warm.table.get_keys(cmp) == 0 then return { "--init" } end
    return cmp
  end,
})
