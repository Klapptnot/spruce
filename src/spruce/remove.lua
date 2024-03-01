--& Spruce uninstall function
--& It would be sad to run this :(

local function uninstall_spruce()
  local Result = require("src.warm.spruce").Result
  local nvim_config_path = vim.fn.stdpath("config")
  local nvim_data_path = vim.fn.stdpath("data")

  local folders = {
    nvim_config_path,
    nvim_data_path,
  }

  for _, folder in ipairs(folders) do
    local remove = Result(vim.fn.delete, folder, "rf")
    if not remove() then
      print("Error removing folder:", folder)
      print("Error message:", remove.unwrap_err())
    end
  end
end

vim.api.nvim_create_user_command("SpruceRemove", function()
  vim.ui.select({ "Yes", "No" }, {
    prompt = "Are you sure you want to uninstall Spruce?",
  }, function(choice)
    if choice == "Yes" then
      uninstall_spruce()
    else
      vim.api.nvim_echo({ { "I was scared, puff!", "Bold" } }, false, {})
    end
  end)
end, {})
