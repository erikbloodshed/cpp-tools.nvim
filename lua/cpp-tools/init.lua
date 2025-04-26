-- lua/cpp-tools/init.lua
-- Lua module for cpp-tools plugin.
-- Primarily handles storing user configuration options.

local M = {}

-- Store user options passed during setup. Initialize with an empty table.
-- This variable is accessed by the autocmd callback in plugin/cpp-tools.lua.
M.user_opts = {}

--- Sets user options for the cpp-tools plugin.
-- This function should be called by the user in their Neovim configuration
-- if they want to provide custom settings.
-- @param opts table | nil: User-provided options for configuration.
function M.setup(opts)
    -- Store the options provided by the user
    M.user_opts = opts or {}
    -- The actual setup logic (setting options, keymaps) is triggered
    -- by the FileType autocmd defined in plugin/cpp-tools.lua,
    -- which reads from M.user_opts.
end

-- Expose the user_opts table so plugin/cpp-tools.lua can access it
-- and also the setup_filetype function which is called by the autocmd.
-- Note: setup_filetype is defined in plugin/cpp-tools.lua in the latest approach
-- to avoid timing issues with lazy loading. The setup function here just stores opts.
-- We need to ensure the autocmd callback in plugin/cpp-tools.lua correctly
-- requires this module and accesses M.user_opts.

-- The module table is returned implicitly by Lua if M is the last statement.
-- Explicitly returning M for clarity.
return M

