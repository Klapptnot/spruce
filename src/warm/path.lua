local main = {}

-- '/' as path separator is valid for windows

-- Function to get the base name of a file path
function main.basename(filepath) return filepath:match("^.+/(.+)$") or filepath end

-- Function to get the parent directory of a file path
function main.parent(filepath) return filepath:match("^(.*)/") end

-- Function to split a path into a table of components
function main.split(path)
  local components = {}
  for component in path:gmatch("[^/]+") do
    table.insert(components, component)
  end
  return components
end

return main
