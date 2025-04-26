-- lua/cpp-tools/execution_handler.lua
-- Module for handling task execution and data file selection.

local utils = require("cpp-tools.utils") -- Make sure utils is required

local ExecutionHandler = {}
ExecutionHandler.__index = ExecutionHandler

--- Constructor for the ExecutionHandler.
-- @param config table: The non-object-oriented configuration module table.
-- @return ExecutionHandler: A new ExecutionHandler instance.
function ExecutionHandler.new(config)
    local self = setmetatable({}, ExecutionHandler)
    -- Store the config module directly
    self.config = config
    self.data_file = nil -- Initialize data_file state within this handler
    return self
end

--- Method to run the compiled executable, potentially with a data file.
-- @param outfile string: The path to the executable file.
function ExecutionHandler:run(outfile)
    -- Open a terminal window
    vim.cmd.terminal()
    -- Defer sending the command to give the terminal time to initialize
    vim.defer_fn(function()
        local command = outfile
        -- Append input redirection if a data file is set
        if self.data_file ~= nil then
            command = outfile .. " < " .. self.data_file
        end
        -- Send the command to the terminal if the job ID exists
        if vim.b.terminal_job_id then
            vim.api.nvim_chan_send(vim.b.terminal_job_id, command .. "\n")
        else
            vim.notify("Could not get terminal job ID to send command.", vim.log.levels.WARN)
        end
    end, 100) -- Increased delay slightly, adjust if needed
end

--- Method to select and add a data file.
function ExecutionHandler:select_data_file()
    -- Construct the path to the data directory using the config module
    local data_subdir = self.config.get("data_subdirectory")
    -- Ensure data_subdir is a string before concatenating
    if type(data_subdir) ~= 'string' then
         vim.notify("Configuration error: 'data_subdirectory' is not a string.", vim.log.levels.ERROR)
         return
    end
    local base = vim.fn.getcwd() .. "/" .. data_subdir
    -- Scan the directory for files
    local files = utils.scan_dir(base)
    -- Notify and return if no files are found
    if vim.tbl_isempty(files) then
        vim.notify("No files found in data directory: " .. base, vim.log.levels.WARN)
        return
    end

    -- Use vim.ui.select for user interaction
    local prompt = 'Current: ' .. (self.data_file or 'None') .. '):'
    vim.ui.select(files, {
        prompt = prompt,
        format_item = function(item)
            return vim.fn.fnamemodify(item, ':t') -- Show only filename
        end,
    }, function(choice)
        -- If a choice is made, update the internal data_file state
        if choice then
            self.data_file = choice
            vim.notify("Data file set to: " .. vim.fn.fnamemodify(choice, ':t'), vim.log.levels.INFO)
        end
    end)
end

--- Method to remove the currently selected data file.
function ExecutionHandler:remove_data_file()
    -- Check if a data file is actually set
    if self.data_file == nil then
        vim.notify("No data file is currently set.", vim.log.levels.WARN)
        return
    end

    -- Confirm removal with the user
    vim.ui.select({ "Yes", "No" }, {
        prompt = "Remove data file (" .. vim.fn.fnamemodify(self.data_file, ':t') .. ")?",
    }, function(choice)
        -- If confirmed, reset the internal data_file state
        if choice == "Yes" then
            self.data_file = nil
            vim.notify("Data file removed.", vim.log.levels.INFO)
        end
    end)
end

--- Getter for the data file (optional, might not be needed externally anymore)
-- @return string | nil: The path to the currently selected data file, or nil.
function ExecutionHandler:get_data_file()
    return self.data_file
end

-- Return a table with the constructor function
return {
    new = ExecutionHandler.new,
}

