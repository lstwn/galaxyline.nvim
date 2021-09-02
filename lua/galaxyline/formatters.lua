local M = {}

function M.join_sequence(sequence, separator)
    separator = separator or " "
    local formatted = ""
    local is_first = true
    -- no ipairs here due to possible nulls in array
    for _, item in pairs(sequence) do
        if item ~= nil and item ~= "" then
            if is_first then
                formatted = item
                is_first = false
            else
                formatted = formatted .. separator .. item
            end
        end
    end
    return formatted
end

function M.wrap(string, left, right)
    if string == nil or string == "" then return "" end
    left = left or " "
    right = right or " "
    return left .. string .. right
end

function M.trim(string)
    if string == nil then return "" end
    return (string.gsub(string, "^%s*(.-)%s*$", "%1"))
end

function M.abbreviate(string, max_len, where, symbol)
    if string == nil then return "" end
    where = where or "right"
    symbol = symbol or "..."
    local string_len = string.len(string)
    if string_len > max_len then
        if where == "left" then
            local abbreviated = string.sub(string, string_len - max_len,
                string_len)
            return symbol .. abbreviated
        end
        if where == "right" then
            local abbreviated = string.sub(string, 1, max_len)
            return abbreviated .. symbol
        end
    end
    return string
end

return M
