local M = {}

M.filetypes = {}
-- LuaFormatter off
M.filetypes.help =           {long_name = "Normal",    short_name = "N"}
M.filetypes.normal_pending = {long_name = "N-Pending", short_name = "N-P"}
M.filetypes.visual =         {long_name = "Visual",    short_name = "V"}
M.filetypes.visual_line =    {long_name = "V-Line",    short_name = "V-L"}
M.filetypes.visual_replace = {long_name = "V-Replace", short_name = "V-R"}
M.filetypes.visual_block =   {long_name = "V-Block",   short_name = "V-B"}
M.filetypes.select =         {long_name = "Select",    short_name = "S"}
M.filetypes.select_line =    {long_name = "S-Line",    short_name = "S-L"}
M.filetypes.select_block =   {long_name = "S-Block",   short_name = "S-B"}
M.filetypes.insert =         {long_name = "Insert",    short_name = "I"}
M.filetypes.replace =        {long_name = "Replace",   short_name = "R"}
M.filetypes.command =        {long_name = "Command",   short_name = "C"}
M.filetypes.vim_ex =         {long_name = "Vim-Ex",    short_name = "V-E"}
M.filetypes.ex =             {long_name = "Ex",        short_name = "E"}
M.filetypes.prompt =         {long_name = "Prompt",    short_name = "P"}
M.filetypes.more =           {long_name = "More",      short_name = "M"}
M.filetypes.confirm =        {long_name = "Confirm",   short_name = "C"}
M.filetypes.shell =          {long_name = "Shell",     short_name = "SH"}
M.filetypes.terminal =       {long_name = "Terminal",  short_name = "T"}
-- LuaFormatter on

local modes = nil
local function resolve_modes()
    if modes == nil then
        modes = setmetatable({
            -- LuaFormatter off
            ["n"]  = M.modes.normal,
            ["no"] = M.modes.normal_pending,
            ["v"]  = M.modes.visual,
            ["V"]  = M.modes.visual_line,
            [""] = M.modes.visual_block,
            ["s"]  = M.modes.select,
            ["S"]  = M.modes.select_line,
            [""] = M.modes.select_block,
            ["i"]  = M.modes.insert,
            ["ic"] = M.modes.insert,
            ["R"]  = M.modes.replace,
            ["Rv"] = M.modes.visual_replace,
            ["c"]  = M.modes.command,
            ["cv"] = M.modes.vim_ex,
            ["ce"] = M.modes.ex,
            ["r"]  = M.modes.prompt,
            ["rm"] = M.modes.more,
            ["r?"] = M.modes.confirm,
            ["!"]  = M.modes.shell,
            ["t"]  = M.modes.terminal
            -- LuaFormatter on
        }, {
            __index = function(_, key)
                print("Unknown mode '" .. key .. "'")
                return {id = "U", long_name = "Unknown", short_name = "U"}
            end,
        })
    end
    return modes
end

M.current_mode = function() return resolve_modes()[vim.fn.mode()] end

return M
