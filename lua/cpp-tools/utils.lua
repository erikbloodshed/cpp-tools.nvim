-- lua/cpp-tools/utils.lua
-- Utility functions for cpp-tools plugin

local M = {}

--- Scans a directory for files.
-- @param dir string: The directory path to scan.
-- @return table: A list of file paths found in the directory.
M.scan_dir = function(dir)
    -- Using 'find' command to get a list of files recursively
    local handle = io.popen('find "' .. dir .. '" -type f 2>/dev/null')
    if not handle then
        vim.notify("Failed to scan directory: " .. dir, vim.log.levels.ERROR)
        return {}
    end
    local result = {}
    -- Read each line (file path) from the command output
    for file in handle:lines() do
        table.insert(result, file)
    end
    -- Close the file handle and check for errors
    local ok, err = handle:close()
    if not ok then
        vim.notify("Error closing file handle: " .. err, vim.log.levels.ERROR)
    end
    -- Sort the results alphabetically (case-insensitive)
    table.sort(result, function(a, b) return string.lower(a) < string.lower(b) end)
    return result
end

--- Gets the SHA256 hash of the current buffer's content.
-- @return string: The SHA256 hash.
M.get_buffer_hash = function()
    -- Get all lines from the current buffer
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    -- Concatenate lines into a single string
    local content = table.concat(lines, "\n")
    -- Calculate and return the SHA256 hash
    return vim.fn.sha256(content)
end

--- Jumps the cursor to the first error diagnostic in a list.
-- @param diagnostics table: A list of diagnostic items.
M.goto_first_diagnostic = function(diagnostics)
    -- Return if the diagnostics list is empty
    if vim.tbl_isempty(diagnostics) then
        return
    end
    -- Get the first diagnostic item
    local diag = diagnostics[1]
    local col = diag.col
    local lnum = diag.lnum
    -- Get the total number of lines in the buffer
    local buf_lines = vim.api.nvim_buf_line_count(0)
    -- Ensure line number is within buffer bounds
    lnum = math.min(lnum, buf_lines - 1)
    -- Get the content of the line with the diagnostic
    local line = vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, false)[1] or ""
    -- Ensure column number is within line bounds
    col = math.min(col, #line)
    -- Set the cursor position (Neovim uses 1-based indexing for lines and columns)
    vim.api.nvim_win_set_cursor(0, { lnum + 1, col + 1 })
end

--- Finds a compile flags file (.compile_flags) upward from the current file's directory.
-- @param filename string: The name of the flags file to search for (e.g., ".compile_flags").
-- @param fallback any: The value to return if the file is not found.
-- @return string | any: The path to the flags file (prefixed with '@') or the fallback value.
M.get_compile_flags = function(filename, fallback)
    -- Search for the file upward from the current buffer's directory
    local path = vim.fs.find(filename, {
        upward = true,
        type = "file",
        path = vim.fn.expand("%:p:h"), -- Directory of the current file
        stop = vim.fn.expand("~"),    -- Stop searching at the home directory
    })[1] -- Get the first result

    -- If the file is found, return its path prefixed with '@'
    if path ~= nil then
        return "@" .. path
    end

    -- If the file is not found, return the fallback value
    return fallback
end

--- Opens a file in a new floating window.
-- @param file string: The path to the file to open.
M.open = function(file)
    -- Read the content of the file
    local asm_content = vim.fn.readfile(file)
    -- Create a new buffer (not listed, scratch buffer)
    local buf = vim.api.nvim_create_buf(false, true)
    -- Set buffer options for a temporary, non-file buffer
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe" -- Close when hidden
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "asm" -- Set filetype for syntax highlighting
    -- Set the content of the buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, asm_content)
    -- Open a new floating window for the buffer
    vim.api.nvim_open_win(buf, true, {
        relative = "editor", -- Relative to the editor area
        width = math.floor(vim.o.columns * 0.8), -- 80% of editor width
        height = math.floor(vim.o.lines * 0.8),  -- 80% of editor height
        row = math.floor(vim.o.lines * 0.1),     -- 10% from top
        col = math.floor(vim.o.columns * 0.1),   -- 10% from left
        style = "minimal", -- Minimal styling
        border = "rounded", -- Rounded border
        title = file, -- Window title is the filename
        title_pos = "center", -- Center the title
    })
    -- Make the buffer read-only
    vim.bo[buf].modifiable = false
    -- Set a keymap to close the window with 'q'
    vim.keymap.set("n", "q", vim.cmd.close, { buffer = true, noremap = true, nowait = true, silent = true, })
end

-- Return the module table with all utility functions
return M

