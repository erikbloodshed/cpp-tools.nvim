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
        -- This callback runs when a C or C++ file is opened.
        -- We perform the setup logic directly here, requiring necessary modules.

        -- Configure Neovim options for C/C++ files
        vim.opt_local.cinkeys:remove(":")
        vim.opt_local.cindent = true

        -- Require the main module to get user options (if setup() was called)
        -- This loads lua/cpp-tools/init.lua
        local cpp_tools_module = require("cpp-tools")
        -- Access the stored user options. Defaults to an empty table if setup() wasn't called.
        local user_opts = cpp_tools_module.user_opts or {}

        -- Require and setup the non-object-oriented config module
        local config = require("cpp-tools.config")
        -- Pass the stored user options to the config setup.
        -- The config module handles filetype-specific merging internally.
        config.setup(user_opts)

        -- Require the build module, passing the config module directly
        local build = require("cpp-tools.build").new(config)

        -- Define keymaps using the build instance methods
        -- Use <buffer=true> to make keymaps local to the current buffer
        local arg = { buffer = true, noremap = true }
        vim.keymap.set("n", "<leader>rc", function() build:compile() end, arg)
        vim.keymap.set("n", "<leader>rr", function() build:run() end, arg)
        vim.keymap.set("n", "<leader>ra", function() build:show_assembly() end, arg)
        vim.keymap.set("n", "<leader>fa", function() build:add_data_file() end, arg)
        vim.keymap.set("n", "<leader>fr", function() build:remove_data_file() end, arg)

        -- Note: The logic that was previously in lua/cpp-tools/init.lua's
        -- setup_filetype function is now directly in this callback.
        -- We no longer call cpp_tools.setup_filetype().
    end,
})

-- The M.setup function in lua/cpp-tools/init.lua is still needed
-- for users to pass configuration options. It just stores the options
-- in the cpp_tools_module.user_opts table, which this autocmd callback reads.
-- If the user doesn't call setup(), default options will be used
-- as defined in lua/cpp-tools/config.lua.

