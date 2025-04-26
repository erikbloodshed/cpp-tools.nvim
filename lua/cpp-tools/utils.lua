local M = {}

M.scan_dir = function(dir)
    local handle = io.popen('find "' .. dir .. '" -type f 2>/dev/null')
    if not handle then
        vim.notify("Failed to scan directory: " .. dir, vim.log.levels.ERROR)
        return {}
    end
    local result = {}
    for file in handle:lines() do
        table.insert(result, file)
    end
    local ok, err = handle:close() -- Capture return values from handle:close()
    if not ok then
        vim.notify("Error closing file handle: " .. err, vim.log.levels.ERROR)
    end
    table.sort(result, function(a, b) return string.lower(a) < string.lower(b) end)
    return result
end

M.get_buffer_hash = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    local content = table.concat(lines, "\n")
    return vim.fn.sha256(content)
end

M.goto_first_diagnostic = function(diagnostics)
    if vim.tbl_isempty(diagnostics) then
        return
    end
    local diag = diagnostics[1]
    local col = diag.col
    local lnum = diag.lnum
    local buf_lines = vim.api.nvim_buf_line_count(0)
    lnum = math.min(lnum, buf_lines - 1)
    local line = vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, false)[1] or ""
    col = math.min(col, #line)
    vim.api.nvim_win_set_cursor(0, { lnum + 1, col + 1 })
end

M.get_compile_flags = function(filename, fallback)
    local path = vim.fs.find(filename, {
        upward = true,
        type = "file",
        path = vim.fn.expand("%:p:h"),
        stop = vim.fn.expand("~"),
    })[1]

    if path ~= nil then
        return "@" .. path
    end

    return fallback
end

M.open = function(file)
    local asm_content = vim.fn.readfile(file)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "asm"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, asm_content)
    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
        row = math.floor(vim.o.lines * 0.1),
        col = math.floor(vim.o.columns * 0.1),
        style = "minimal",
        border = "rounded",
        title = file,
        title_pos = "center",
    })
    vim.bo[buf].modifiable = false
    vim.keymap.set("n", "q", vim.cmd.close, { buffer = true, noremap = true, nowait = true, silent = true, })
end

return M
