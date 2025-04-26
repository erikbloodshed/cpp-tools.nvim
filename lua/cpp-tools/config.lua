-- lua/cpp-tools/config.lua
-- Non-object-oriented configuration module with filetype-specific options

local M = {}

-- Default configurations per filetype and common defaults
local defaults = {
    c = {
        compiler = "gcc",
        default_flags = "-std=c18 -O2",
        compile_command = nil, -- Allow overriding the entire compile command
        assemble_command = nil, -- Allow overriding the entire assemble command
    },
    cpp = {
        compiler = "g++",
        default_flags = "-std=c++23 -O2",
        compile_command = nil, -- Allow overriding the entire compile command
        assemble_command = nil, -- Allow overriding the entire assemble command
    },
    -- Common options that apply to both unless overridden
    common = {
        output_directory = "/tmp/",
        data_subdirectory = "dat",
    }
}

-- Internal table to store the user-provided options
-- This will be populated by the M.setup function.
-- User options should be structured like { common = {}, c = {}, cpp = {} }.
local user_options = {}

--- Sets up the configuration by storing user-provided options.
-- User options can be structured like { common = {}, c = {}, cpp = {} }.
-- These options will be merged with defaults when M.get is called.
-- @param options table | nil: User-provided options to override defaults.
function M.setup(options)
    user_options = options or {}
end

--- Gets a configuration value by key for the current buffer's filetype.
-- Merges defaults, common user options, and filetype-specific user options.
-- @param key string: The key for the configuration value.
-- @return any: The configuration value for the current filetype, or nil if the key does not exist.
function M.get(key)
    local filetype = vim.bo.filetype
    if filetype ~= 'c' and filetype ~= 'cpp' then
        -- Return nil if called outside c/cpp buffer (shouldn't happen with autocmd setup)
        return nil
    end

    -- Start with defaults for the specific filetype
    local current_config = vim.tbl_deep_extend('force', {}, defaults[filetype] or {})

    -- Merge common user options if they exist
    if user_options.common then
        current_config = vim.tbl_deep_extend('force', current_config, user_options.common)
    end

    -- Merge filetype-specific user options if they exist
    if user_options[filetype] then
        current_config = vim.tbl_deep_extend('force', current_config, user_options[filetype])
    end

    -- Return the value for the requested key from the merged configuration
    return current_config[key]
end

--- Sets a configuration value by key for the current buffer's filetype in the user options.
-- This allows runtime modification of the configuration, but only affects the user_options table.
-- The change will persist for subsequent calls to M.get in the same filetype.
-- @param key string: The key for the configuration value.
-- @param value any: The value to set.
function M.set(key, value)
    local filetype = vim.bo.filetype
     if filetype ~= 'c' and filetype ~= 'cpp' then
        return
    end

    -- Initialize the filetype specific user options table if it doesn't exist
    user_options[filetype] = user_options[filetype] or {}
    -- Set the value in the user options for the current filetype
    user_options[filetype][key] = value
end

-- Return the module table with setup, get, and set functions
return M

