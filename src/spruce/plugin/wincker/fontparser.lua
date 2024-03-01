-- Wincker ASCII art font parser and loader
-- Supports .flf fonts, commonly figlet fonts

local str = require("src.warm.str")

local main = {}

function main.load(filepath)
  ---@type string[]
  local file = {}
  for ln in io.lines(filepath) do
    file[#file + 1] = ln
  end
  -- Get header and data information
  local header_head = str.split(file[1], " ")
  -- header_head[6] is header line count, so ...
  local font = {}
  ---@type string[]
  font.data = table.move(file, tonumber(header_head[6]) + 1, #file - 1, 1, {})
  ---@type string[]
  font.header = table.move(file, 1, tonumber(header_head[6]) + 0, 1, {})
  ---@type number
  font.height = tonumber(header_head[2]) + 0
  ---@type string
  font.hardblank = header_head[1]:sub(-1)
  ---@type table<string, table>>
  font.chars = {}

  ---@param char string
  ---@return {[1]:string, [2]:string[]}
  function font:get_char(char)
    -- Assume #char == 1 and type(char) == "string"
    if self.chars[char] ~= nil then return self.chars[char] end
    local char_pos = char:byte() * self.height
    local char_item = {
      "",
      {},
    }
    for i = 1, self.height do
      local clean_char = self.data[char_pos + i]
        :gsub("@", "")
        :gsub(self.hardblank, "")
        :gsub(" ", " ")
        :sub(1, -2)
      char_item[1] = char_item[1] .. clean_char .. "\n" -- Save string
      char_item[2][i] = clean_char -- Save lines
    end
    self.chars[char] = char_item
    return char_item
  end
  return font
end

return main
