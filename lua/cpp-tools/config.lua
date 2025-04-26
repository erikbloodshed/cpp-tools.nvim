-- lua/cpp-tools/config.lua
-- Non-object-oriented configuration module

local M = {}

-- Default configuration options
local defaults = {
    output_directory = "/tmp/",
    data_subdirectory = "dat",
    compiler = "g++",
    default_flags = "-std=c++23 -O2",
    compile_command = nil, -- Allow overriding the entire compile command
    assemble_command = nil, -- Allow overriding the entire assemble command
}

-- Internal table to hold the current configuration
local config = {}

--- Sets up the configuration by merging default options with user-provided options.
-- @param options table | nil: User-provided options to override defaults.
function M.setup(options)
    options = options or {}
    -- Deep extend defaults with user options
    config = vim.tbl_deep_extend('force', defaults, options)
end

--- Gets a configuration value by key.
-- @param key string: The key for the configuration value.
-- @return any: The configuration value, or nil if the key does not exist.
function M.get(key)
    return config[key]
end

--- Sets a configuration value by key.
-- @param key string: The key for the configuration value.
-- @param value any: The value to set.
function M.set(key, value)
    config[key] = value
end

-- Return the module table with setup, get, and set functions
return M

