-- lua/cpp-tools/build.lua
-- Module for handling build and execution commands

local utils = require("cpp-tools.utils")
local ExecutionHandler = require("cpp-tools.execution_handler")

local Build = {}
Build.__index = Build

--- Creates a new Build instance.
-- @param config table: The non-object-oriented configuration module table.
-- @return Build: A new Build instance.
function Build.new(config)
    local self = setmetatable({}, Build)

    -- Store the config module directly
    self.config = config
    -- Pass the config module to the ExecutionHandler constructor
    self.execution_handler = ExecutionHandler.new(config)

    -- Access config values using the get function
    self.compiler = self.config.get("compiler")
    -- Get compile flags from .compile_flags or use default from config
    self.flags = utils.get_compile_flags(".compile_flags", self.config.get("default_flags"))
    -- Construct output file paths
    self.exe_file = self.config.get("output_directory") .. vim.fn.expand("%:t:r")
    self.asm_file = self.exe_file .. ".s"
    self.infile = vim.api.nvim_buf_get_name(0)

    -- Construct compile and assemble commands, allowing overrides from config
    self.compile_cmd = self.config.get("compile_command") or
        string.format("%s %s -o %s %s", self.compiler, self.flags, self.exe_file, self.infile)
    self.assemble_cmd = self.config.get("assemble_command") or
        string.format("%s %s -S -o %s %s", self.compiler, self.flags, self.asm_file, self.infile)

    -- Store hashes to track buffer changes
    self.hash = { compile = nil, assemble = nil }

    return self
end

--- Processes a build step (compile or assemble) if the buffer has changed.
-- Checks for diagnostics before proceeding.
-- @param key string: The key for the hash ('compile' or 'assemble').
-- @param callback function: The function to execute if the buffer has changed and there are no errors.
-- @return boolean: true if the process was executed or skipped due to no changes, false if compilation failed.
function Build:process(key, callback)
    local buffer_hash = utils.get_buffer_hash()
    if self.hash[key] ~= buffer_hash then
        -- Get error diagnostics for the current buffer
        local diagnostics = vim.diagnostic.get(0, { severity = { vim.diagnostic.severity.ERROR } })

        -- If no errors, execute the callback and update the hash
        if vim.tbl_isempty(diagnostics) then
            callback()
            self.hash[key] = buffer_hash
            return true
        end

        -- If there are errors, go to the first one and notify the user
        utils.goto_first_diagnostic(diagnostics)
        vim.notify("Source code compilation failed.", vim.log.levels.ERROR)

        return false
    else
        -- Notify if the source code hasn't changed since the last build
        vim.notify("Source code is already compiled.", vim.log.levels.WARN)
    end

    -- Return true if skipped due to no changes
    return true
end

--- Compiles the current source file.
function Build:compile()
    -- Process the compile step, executing the compile command on success
    self:process("compile", function() vim.cmd("!" .. self.compile_cmd) end)
end

--- Runs the compiled executable.
-- Compiles first if necessary.
function Build:run()
    -- Attempt to compile first. If it fails or is skipped due to errors, do not run.
    if not self:process("compile", function() vim.cmd("!" .. self.compile_cmd) end) then
        vim.notify("Compilation failed or skipped, cannot run.", vim.log.levels.WARN)
        return
    end
    -- Run the compiled executable using the execution handler
    self.execution_handler:run(self.exe_file)
end

--- Shows the assembly output of the current source file.
-- Assembles first if necessary.
function Build:show_assembly()
    -- Process the assemble step, executing the assemble command on success
    if not self:process("assemble", function()
            vim.cmd("silent! write") -- Save the buffer before assembling
            vim.fn.system(self.assemble_cmd) -- Execute the assemble command
        end) then
        vim.notify("Compilation failed or skipped, cannot run.", vim.log.levels.WARN)
        return
    end
    -- Open the assembly file in a new buffer/window
    utils.open(self.asm_file)
end

--- Prompts the user to select a data file for execution.
function Build:add_data_file()
    -- Call the select_data_file method on the execution handler instance
    self.execution_handler:select_data_file()
end

--- Removes the currently selected data file.
function Build:remove_data_file()
    -- Call the remove_data_file method on the execution handler instance
    self.execution_handler:remove_data_file()
end

-- Return a table with the constructor function
return {
    new = Build.new,
}

