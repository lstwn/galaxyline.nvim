local M = {}

function M.buffer_number() return vim.fn.bufnr() end

function M.file_name() return vim.fn.expand('%:t') end

function M.relative_path_and_file_name() return vim.fn.expand('%:~:.') end

function M.absolute_path_and_file_name() return vim.fn.expand('%:~') end

function M.current_working_dir_name()
    return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

function M.current_working_dir_path()
    return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
end

function M.is_modified(modified, unmodified)
    modified = modified or "+"
    unmodified = unmodified or ""
    return vim.bo.modified and modified or unmodified
end

function M.is_readonly(readonly, nonreadonly)
    readonly = readonly or "r"
    nonreadonly = nonreadonly or ""
    return vim.bo.readonly and readonly or nonreadonly
end

function M.file_encoding() return vim.bo.fenc ~= '' and vim.bo.fenc or vim.o.enc end

function M.file_format() return vim.bo.fileformat end

function M.file_type() return vim.bo.filetype end

function M.file_size()
    local file = vim.fn.expand('%:p')
    if string.len(file) == 0 then return '' end
    local size = vim.fn.getfsize(file)
    if size == 0 or size == -1 or size == -2 then return '' end
    if size < 1024 then
        size = size .. 'b'
    elseif size < 1024 * 1024 then
        size = string.format('%.1f', size / 1024) .. 'k'
    elseif size < 1024 * 1024 * 1024 then
        size = string.format('%.1f', size / 1024 / 1024) .. 'm'
    else
        size = string.format('%.1f', size / 1024 / 1024 / 1024) .. 'g'
    end
    return size
end

function M.current_line() return vim.api.nvim_win_get_cursor(0)[1] end

function M.current_column() return vim.api.nvim_win_get_cursor(0)[2] end

function M.total_lines() return vim.api.nvim_buf_line_count(0) end

function M.line_column_position(icon, line_divider, column_divider)
    icon = icon or "☰ "
    line_divider = line_divider or "/"
    column_divider = column_divider or ":"

    local cursor = vim.api.nvim_win_get_cursor(0)
    local lines = vim.api.nvim_buf_line_count(0)
    return string.format("%s%d%s%d%s%d", icon, cursor[1], line_divider, lines,
                         column_divider, cursor[2])
end

function M.current_line_percent(top, bottom)
    top = top or 'Top'
    bottom = bottom or 'Bot'

    local current_line = vim.fn.line('.')
    local total_line = vim.fn.line('$')
    if current_line == 1 then
        return top
    elseif current_line == total_line then
        return bottom
    end
    -- use four percent signs to:
    -- 1. escape string.format() percent intepretation
    -- 2. escape vim's statusline percent intepretation
    return string.format("%d%%%%", math.modf((current_line / total_line) * 100))
end

return M
