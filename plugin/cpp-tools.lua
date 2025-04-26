-- plugin/cpp-tools.lua
-- This file is automatically sourced by Neovim.
-- It registers the autocmd to set up the plugin for C/C++ filetypes.

-- Create an Augroup specifically for cpp-tools autocmds
-- { clear = true } ensures the augroup is cleared each time this file is sourced,
-- preventing duplicate autocmds if the user reloads their config.
local cpp_tools_augroup = vim.api.nvim_create_augroup("CppToolsAugroup", { clear = true })

-- Register the FileType autocmd for 'c' and 'cpp'
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    group = cpp_tools_augroup, -- Assign to the augroup
    -- Define the callback function inline
    callback = function()
        -- Require the module *inside* the callback.
        -- This ensures the module is loaded and setup_filetype is available
        -- only when a C or C++ file is opened.
        local cpp_tools = require("cpp-tools")
        -- Call the setup_filetype function from the module
        cpp_tools.setup_filetype()
    end,
})

-- Note: User configuration should still be done by calling
-- require("cpp-tools").setup(opts) in the user's init.lua.
-- This call will populate the user_opts variable within lua/cpp-tools/init.lua,
-- which the setup_filetype function (called by this autocmd) will then use.
-- If the user doesn't call setup(), the plugin will use its default options
-- as defined in lua/cpp-tools/config.lua.

