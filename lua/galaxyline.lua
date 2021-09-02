local priority_queue = require("galaxyline.priority_queue")

local M = {}

-- TODO:
-- 2. proper setup function
-- 3. documentation and publish
-- 4. tabline
-- 5. .lua-format file

M.section = {}
M.section.left = {}
M.section.right = {}
M.section.mid = {}
M.divider = {
    provider = "%=",
    highlight = "StatusLine",
    priority = 9999,
    length = 0,
}
M.context = nil
M.events = {
    "ColorScheme", "FileType", "BufWinEnter", "BufReadPost", "BufWritePost",
    "BufEnter", "WinEnter", "FileChangedShellPost", "VimResized", "TermOpen",
    "WinLeave",
}

local function log_incompatibility(component_property, invalid_type)
    return string.format("Type '%s' not supported for property '%s'",
        invalid_type, component_property)
end

local function process_provider(provider, context)
    local provider_type = type(provider)
    if provider_type == "function" then return provider(context.user_context) end
    if provider_type == "string" then return provider end
    error(log_incompatibility("provider", provider_type))
end

local function process_highlight(highlight, context)
    local function wrap_highlight_group_marker(highlight_group)
        return "%#" .. highlight_group .. "#"
    end
    local highlight_type = type(highlight)

    if highlight_type == "nil" then return "" end
    if highlight_type == "function" then
        return wrap_highlight_group_marker(highlight(context.user_context))
    end
    if highlight_type == "string" then
        return wrap_highlight_group_marker(highlight)
    end

    error(log_incompatibility("highlight", highlight_type))
end

local function process_formatter(formatter, resolved_provider, context)
    local formatter_type = type(formatter)

    if formatter_type == "nil" then return resolved_provider end
    if formatter_type == "function" then
        return formatter(resolved_provider, context.user_context)
    end

    error(log_incompatibility("formatter", formatter_type))
end

local function process_condition(condition, context)
    local condition_type = type(condition)

    if condition_type == "nil" then return true end
    if condition_type == "function" then
        return condition(context.user_context)
    end

    error(log_incompatibility("condition", condition_type))
end

local function process_length(length, resolved, context)
    local length_type = type(length)

    if length_type == "nil" then return string.len(resolved) end
    if length_type == "function" then
        return length(string.len(resolved), context.user_context)
    end
    if length_type == "number" then return length end

    error(log_incompatibility("length", length_type))
end

local function process_component(component, context)
    local name = component.name
    local priority = component.priority or 0
    local condition = component.condition
    local provider = component.provider
    local length = component.length
    local abbreviate = component.abbreviate
    local formatter = component.formatter
    local highlight = component.highlight

    local resolved_component = {
        name = name,
        chopped = false,
        raw = "",
        formatted = "",
        len = 0,
        formatter = formatter,
        abbreviate = abbreviate,
        length = length,
        highlighting = process_highlight(highlight, context),
    }

    if not process_condition(condition, context) then
        return resolved_component
    end

    local raw = process_provider(provider, context)

    if raw == nil then return resolved_component end

    local formatted = process_formatter(formatter, raw, context)

    local len = process_length(length, formatted, context)

    resolved_component.raw = raw
    resolved_component.formatted = formatted
    resolved_component.len = len

    -- only assess components that have a positive length for abbreviation/chopping
    -- i.e., particularly no dividers!
    if len ~= 0 then
        context.priority_queue.enqueue(priority, resolved_component)
    end
    return resolved_component
end

local function process_section(section, context)
    if section == nil then return end
    for _, component in ipairs(section) do
        local ok, resolved_component = pcall(function()
            return process_component(component, context)
        end)
        if not ok then
            print(string.format("Error while processing component '%s': %s",
                component.name, resolved_component))
        else
            table.insert(context.component_order, resolved_component)
            context.total_len = context.total_len + resolved_component.len
        end
    end
    return
end

local function prune_components(context, space_balance, columns)
    while context.priority_queue.size() > 0 and space_balance < 0 do
        local component = context.priority_queue.dequeue()
        local ok, err = pcall(function()
            local old_len
            local new_len
            if not component.abbreviate then
                component.chopped = true
                old_len = component.len
                new_len = 0
            else
                local leftover_space = nil
                if context.priority_queue.empty() then
                    leftover_space = columns
                end
                component.formatted = process_formatter(component.formatter,
                    component.abbreviate(component.raw, leftover_space), context)
                old_len = component.len
                new_len = process_length(component.length, component.formatted,
                    context)
            end
            space_balance = space_balance + (old_len - new_len)
        end)
        if not ok then
            print(string.format("Error while pruning component '%s': %s",
                component.name, err))
        end
    end
end

-- do not add dividers multiple times (improvment with proper setup fn)
local first_time_execution = true

function M.process_statusline()
    local context = {
        user_context = type(M.context) == "function" and M.context() or nil,
        priority_queue = priority_queue(),
        component_order = {},
        total_len = 0,
    }

    local has_mid = next(M.section.mid) ~= nil

    if first_time_execution then
        table.insert(M.section.left, M.divider)
        if has_mid then table.insert(M.section.mid, M.divider) end
        first_time_execution = false
    end
    process_section(M.section.left, context)
    if has_mid then process_section(M.section.mid, context) end
    process_section(M.section.right, context)

    local columns = vim.fn.winwidth(0)
    local space_balance = columns - context.total_len
    if space_balance < 0 then
        prune_components(context, space_balance, columns)
    end

    local statusline = ""
    for _, resolved_component in ipairs(context.component_order) do
        if not resolved_component.chopped then
            statusline = statusline .. resolved_component.highlighting ..
                             resolved_component.formatted
        end
    end
    return statusline
end

function M.load_galaxyline()
    vim.wo.statusline =
        [[%{%luaeval('require("galaxyline").process_statusline')()%}]]
end

function M.disable_galaxyline()
    vim.wo.statusline = ""
    vim.api.nvim_command("augroup galaxyline")
    vim.api.nvim_command("autocmd!")
    vim.api.nvim_command("augroup END!")
end

function M.galaxyline_augroup()
    vim.api.nvim_command("augroup galaxyline")
    vim.api.nvim_command("autocmd!")
    for _, def in ipairs(M.events) do
        local command = string.format(
            "autocmd %s * lua require(\"galaxyline\").load_galaxyline()", def)
        vim.api.nvim_command(command)
    end
    vim.api.nvim_command("augroup END")
end

return M
