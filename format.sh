#!/bin/bash

# Function to display usage information
function show_usage {
  printf 'Usage: %s [-e <file>] [-E <folder>]...\n' "${0}"
  printf '  -e <file>    Exclude specific file from formatting\n'
  printf '  -E <folder>  Exclude specific folder (recursively) from formatting\n\n'
  printf 'Instaled stylua version: %s\n' "${STYLUA_VERSION_inf:-Not installed}"
  exit 1
}

# Check if stylua is installed
if ! STYLUA_VERSION_inf="$(stylua --version 2>/dev/null)"; then
  printf '%s\n' "! [>] Error: stylua is not installed. Please install stylua and try again."
  exit 1
fi

# The parent folder of this script
MELOC="$(dirname "$(realpath "${0}")")"

# stylua configuration file
STYLUA_CONFIG_FILE_inf="${MELOC}/.stylua.toml"

# Check for config file or exit
if [ ! -f "${STYLUA_CONFIG_FILE_inf}" ]; then
  printf '%s\n' "! [>] Config file for stylua: '${STYLUA_CONFIG_FILE_inf}' not found"
  exit 3
fi

# Arrays to store excluded files and folders
EXCLUDE_FILES=()
EXCLUDE_FOLDERS=()

# Process command line options
while getopts ":e:E:" opt; do
  case $opt in
    e)
      EXCLUDE_FILES+=("! -name '${OPTARG}'")
      ;;
    E)
      EXCLUDE_FOLDERS+=("! -path '${OPTARG}'")
      ;;
    \?)
      file="$(realpath "${OPTARG}")"
      if [ -f "${file}" ]; then
        printf '[>] Formatting %50s ... \n' "${file}"
        stylua --config-path "${STYLUA_CONFIG_FILE_inf}" "${file}" || printf '! [>] Failed. Check syntax\n'
        exit
      fi
      show_usage
      ;;
  esac
done

# Print stylua version
printf '[>] stylua version: %s\n' "${STYLUA_VERSION_inf#*\ }"

# Shift the processed options out of the argument list
shift $((OPTIND-1))

# Find all lua files and format them with stylua
# ignore lua files starting with '_' and those in excluded folders or files
eval "find . -name '*.lua' ! -name '_*' ${EXCLUDE_FILES[*]} ${EXCLUDE_FOLDERS[*]}" | while read -r file; do
  printf '[>] Formatting %50s ... \n' "${file}"
  stylua --config-path "${STYLUA_CONFIG_FILE_inf}" "${file}" || printf '! [>] Failed. Check syntax\n'
done

