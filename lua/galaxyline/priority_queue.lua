local floor = math.floor
local mt = {__tostring = function(self) return "TODO" end}

return function()
    local heap = {}
    local current_size = 0

    local interface = {}

    function interface.empty() return current_size == 0 end

    function interface.size() return current_size end

    function interface.peek() return heap[1][2] end

    local function sift_up()
        local i = current_size

        while floor(i / 2) > 0 do
            local half = floor(i / 2)
            if heap[i][1] < heap[half][1] then
                heap[i], heap[half] = heap[half], heap[i]
            end
            i = half
        end
    end

    function interface.enqueue(prio, value)
        heap[current_size + 1] = {prio, value}
        current_size = current_size + 1
        sift_up()
    end

    local function minimum_child(i)
        if (i * 2) + 1 > current_size then
            return i * 2
        else
            if heap[i * 2][1] < heap[i * 2 + 1][1] then
                return i * 2
            else
                return i * 2 + 1
            end
        end
    end

    local function sift_down()
        local i = 1

        while (i * 2) <= current_size do
            local min = minimum_child(i)
            if heap[i][1] > heap[min][1] then
                heap[i], heap[min] = heap[min], heap[i]
            end
            i = min
        end
    end

    function interface.dequeue()
        local popped = heap[1][2]
        heap[1] = heap[current_size]
        heap[current_size] = nil
        current_size = current_size - 1
        sift_down()
        return popped
    end

    return setmetatable(interface, mt)
end
