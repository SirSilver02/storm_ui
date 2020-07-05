local function class(...) 
    local super_classes = {...}

    local class = setmetatable({}, {
        __index = function(t, k)
            for i = 1, #super_classes do
                local value = super_classes[i][k]
                
                if value then
                    return value
                end
            end
        end
    })

    class.__index = class

    function class.new(...)
        local object = setmetatable({}, class)

        if class.init then
            class.init(object, ...)
        end
    
        return object
    end

    return class
end

return class