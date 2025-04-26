-- plugin/cpp-tools.lua
-- This file is automatically sourced by Neovim.
-- It registers the autocmd to set up the plugin for C/C++ filetypes.

-- Require the main Lua module for the plugin
-- This assumes your main module is located at lua/cpp-tools/init.lua
local cpp_tools = require("cpp-tools")

-- Create an Augroup specifically for cpp-tools autocmds
-- { clear = true } ensures the augroup is cleared each time this file is sourced,
-- preventing duplicate autocmds if the user reloads their config.
local cpp_tools_augroup = vim.api.nvim_create_augroup("CppToolsAugroup", { clear = true })

-- Register the FileType autocmd for 'c' and 'cpp'
-- This autocmd will call the setup_filetype function from the main Lua module
-- when the filetype is detected.
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    group = cpp_tools_augroup, -- Assign to the augroup
    callback = cpp_tools.setup_filetype, -- Call the setup_filetype function from the module
})

-- Note: User configuration should still be done by calling
-- require("cpp-tools").setup(opts) in the user's init.lua.
-- This call will populate cpp_tools.user_opts (defined in lua/cpp-tools/init.lua),
-- which setup_filetype will use when it's triggered.
-- If the user doesn't call setup(), the plugin will use its default options.

