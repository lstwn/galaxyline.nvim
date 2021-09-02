local mt = {
    __le = function(a, b)
        for element, _ in pairs(a) do
            if not b[element] then return false end
        end
        return true
    end,
    __lt = function(a, b) return a <= b and not (b <= a) end,
    __eq = function(a, b) return a <= b and b <= a end,
    __tostring = function(self)
        local string = "{"
        local separator = ""
        for element, _ in pairs(self.set) do
            string = string .. separator .. element
            separator = ", "
        end
        return string .. "}"
    end,
}

return function(init)
    local set = {}

    for _, element in ipairs(init) do set[element] = true end

    local interface = {}

    function interface.insert(element)
        if not set[element] then set[element] = true end
    end

    function interface.remove(element)
        if set[element] then set[element] = nil end
    end

    function interface.contains(element) return set[element] ~= nil end

    return setmetatable(interface, mt)
end
