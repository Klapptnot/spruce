-- !! Neovim options (vim.opt[key])
-- !? To get more information about the options
-- !? Use :help <option_name>
--- @class __option__: vim.opt
local __options__ = {
  -- !! Show (some) current mode below the statusline (input line)
  -- !? Options: true, false
  showmode = false, --~ default: true

  -- !! Enable 24-bit RGB colour support
  -- !? Options: true, false
  termguicolors = true, --~ default: false

  -- !! Interval of time to write to swap file
  -- !? Options: any integer
  updatetime = 500, --~ default: 4000

  -- !! Enable a timout for mappings to complete
  -- !? Options: any integer
  timeout = true, --~ default: true

  -- !! Time to wait for a mapping to complete
  -- !? Options: any integer
  timeoutlen = 300, --~ default: 1000

  -- !! Copy indent from current line when starting a new line
  -- !? Options: true, false
  autoindent = true, --~ default: true

  -- !! Split window will be set at the right of the current window
  -- !? Options: true, false
  splitright = true, --~ default: false

  -- !! Split window will be set below the current window
  -- !? Options: true, false
  splitbelow = true, --~ default: false

  -- !! Set the tab space count in files
  -- !? Options: any integer
  tabstop = 2, --~ default: 8

  -- !! Set the tab space count while editing
  -- ?? Options: any integer
  softtabstop = 2, --~ default: 0

  -- !! Use spaces instead of tabs
  -- !? Options: true, false
  expandtab = true, --~ default: false

  -- !! Set the spaces used for (auto)indentation
  -- !? Range: Any integer value
  shiftwidth = 2, --~ default: 8

  -- !! Do smart indenting
  -- !? Options: true, false
  smartindent = true, --~ default: false

  -- !! Which clipboard should be used
  -- !? Options: 'unnamed', 'unnamedplus', 'autoselect', 'unnamed,unnamedplus', etc.
  clipboard = "unnamedplus", --~ default: ""

  -- !! Better completion menu options
  -- !? Options: 'menu', 'menuone', 'noselect', 'menuone,noselect', 'popup', etc.
  completeopt = "menuone,noselect,preview", --~ default: "menu,preview"

  -- !! Enable mouse support
  -- !? Options: 'a' (all), 'n' (none), 'v' (visual), etc.
  mouse = "a", --~ default: "nvi"

  -- !! When a bracket is inserted, briefly jump to the matched bracket
  -- !? Options: true, false
  showmatch = false, --~ default: false

  -- !! Enable spell checking
  -- !? Options: true, false
  spell = true, --~ default: false

  -- !! Show line and column of cursor position
  -- !? Options: true, false
  ruler = false, --~ default: true

  -- !! Show line numbers
  -- !? Options: true, false
  number = true, --~ default: false

  -- !! Show relative line number to cursor position
  -- !? Options: true, false
  relativenumber = true, --~ default: false

  -- !! Line number width
  -- !? Options: any integer
  numberwidth = 3, --~ default: 4

  -- !! Margin at the right of window in wrapped lines
  -- !? Options: any integer
  wrapmargin = 8, --~ default: 0

  -- !! Enable soft wrapping
  -- !? Options: true, false
  wrap = true, --~ default: false

  -- !! Highlight the text line of the cursor line
  -- !? Options: true, false
  cursorline = true, --~ default: false

  -- !! Ignore case search patterns
  -- !? Options: true, false
  ignorecase = true, --~ default: false

  -- !! Do not ignore case in search patterns with uppercase characters
  -- !? Options: true, false
  smartcase = true, --~ default: false

  -- !! Save undo history from files when saving them
  -- !? Options: true, false
  undofile = true, --~ default: false

  -- !! When to display tab line
  -- !? Options: 0, 1, 2
  showtabline = 2, --~ default: 1

  -- !! Number of lines to use for command line
  -- !? Options: integer
  cmdheight = 0,
}
return __options__
