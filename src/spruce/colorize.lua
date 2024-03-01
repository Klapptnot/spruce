local main = {}

function main.rgb_to_hex(r, g, b) return string.format("%02x%02x%02x", r, g, b) end
---Convert hex color to RGB components
function main.hex_to_rgb(hex)
  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)
  return r, g, b
end
---Default: 0.5 luminance intensity
---@param hex string
---@param brightness? number
---@return boolean
function main.brightness(hex, brightness)
  local r, g, b = main.hex_to_rgb(hex)
  -- Calculate luminance (brightness)
  local luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  -- Define a threshold for brightness
  local threshold = brightness or 0.5
  return luminance > threshold
end

function main.colorize_pos()
  local pattern = "#([a-fA-f0-9][a-fA-f0-9][a-fA-f0-9][a-fA-f0-9][a-fA-f0-9][a-fA-f0-9])"
  for ln = 1, vim.fn.line("$") do
    local line = vim.api.nvim_buf_get_lines(0, ln - 1, ln + 1 - 1, false)[1]
    local s, e, match = line:find(pattern, 1)
    while match do
      local h = "HexColr" .. match
      local f = "d0d0d0"
      if main.brightness(match) then f = "202020" end
      local m = vim.fn.matchaddpos(h, { { ln, s, 7 } })
      if m ~= -1 then vim.cmd("hi " .. h .. " guibg=#" .. match .. " guifg=#" .. f) end
      s, e, match = line:find(pattern, e + 1)
    end
  end
end
function main.colorize()
  local pattern = "#([a-fA-f0-9][a-fA-f0-9][a-fA-f0-9][a-fA-f0-9][a-fA-f0-9][a-fA-f0-9])"
  for ln = 1, vim.fn.line("$") do
    local line = vim.api.nvim_buf_get_lines(0, ln - 1, ln + 1 - 1, false)[1]
    for match in line:gmatch(pattern) do
      local h = "HexColr" .. match
      local f = "d0d0d0"
      if main.brightness(match) then f = "202020" end
      local m = vim.fn.matchadd(h, "#" .. match)
      if m ~= -1 then vim.cmd("hi " .. h .. " guibg=#" .. match .. " guifg=#" .. f) end
    end
  end
end

return main
