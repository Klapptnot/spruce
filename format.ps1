# Function to display usage information
function Show-Usage {
  Write-Host "Usage: $(Get-Command $MyInvocation.ScriptName) [-e <path>] ..."
  Write-Host "  -e <path>    Exclude specific files from formatting or all items in folder`n"
  Write-Host "Installed stylua version: $($StyluaVersion -replace 'Stylua ', '')"
  exit 1
}

# Check if stylua is installed
if (-not (Get-Command 'stylua' -ErrorAction SilentlyContinue)) {
  Write-Host "! [>] Error: stylua is not installed. Please install stylua and try again."
  exit 1
} else {
  $StyluaVersion = stylua --version
}

# The path to this script
$MeLoc = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Stylua configuration file
$StyluaConfigFile = Join-Path $MeLoc ".stylua.toml"

# Check for config file or exit
if (-not (Test-Path $StyluaConfigFile -PathType Leaf)) {
  Write-Host "! [>] Config file for stylua: '$StyluaConfigFile' not found"
  exit 3
}

# Arrays to store excluded files and folders
$ExcludeItems = @()

# Process command line options
$argv = $args -split ' '
for ($i = 0; $i -lt $argv.Count; $i++) {
  switch ($argv[$i]) {
    "-e" {
      if ($Item = $(Get-Item -Path $argv[$i+1] -ErrorAction SilentlyContinue).FullName) {
        $ExcludeItems += $Item
      }
      $i++
      break
    }
    default {
      $LuaItem = Get-Item -Path $argv[$i] -ErrorAction SilentlyContinue
      if (Test-Path -Path $LuaItem.FullName) {
        Write-Host "[>] Formatting $($LuaItem.FullName) ... "
        stylua --config-path $StyluaConfigFile $LuaItem.FullName || Write-Host '! [>] Failed. Check syntax'
        exit
      }
      Show-Usage
      break
    }
  }
}

# Print stylua version
Write-Host "[>] stylua version: $($StyluaVersion -replace 'Stylua ', '')"

# Find all lua files and format them with stylua
# ignore lua files starting with '_' and those in excluded folders or files
Get-ChildItem -Recurse -Filter *.lua | ForEach-Object {
  if ($_.Name -notlike '_*' -and $ExcludeItems -notcontains $_.FullName) {
    Write-Host "[>] Formatting $($_.FullName) ... "
    stylua --config-path $StyluaConfigFile $_.FullName || Write-Host '! [>] Failed. Check syntax'
  }
}

