-- lua/cpp-tools/init.lua
-- Lua module containing core setup logic and user options storage

local M = {}

-- Store user options passed during setup. Initialize with an empty table.
M.user_opts = {}

--- Internal function to perform the filetype-specific setup.
-- This is called by the autocmd when a C or C++ file is opened.
-- It uses the options stored in M.user_opts.
function M.setup_filetype()
    -- Configure Neovim options for C/C++ files
    vim.opt_local.cinkeys:remove(":")
    vim.opt_local.cindent = true

    -- Require and setup the non-object-oriented config module
    local config = require("cpp-tools.config")
    -- Pass the stored user options to the config setup
    config.setup(M.user_opts)

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
end

--- Sets user options for the cpp-tools plugin.
-- This function should be called by the user in their Neovim configuration
-- if they want to provide custom settings.
-- @param opts table | nil: User-provided options for configuration.
function M.setup(opts)
    -- Store the options provided by the user
    M.user_opts = opts or {}
    -- Note: The autocmd registration is now in plugin/cpp-tools.lua
    -- Calling M.setup() only sets the options that the autocmd will use
    -- when it triggers setup_filetype().
end

-- Return the main module table
return M

