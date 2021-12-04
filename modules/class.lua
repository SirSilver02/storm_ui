local __classes = {}

local function make_class(name, ...)
    assert(not __classes[name], "Class " .. name .. " already exists!")

    local super_classes = {...}
    local class = {}
    setmetatable(class, class)
    
    class.__index = function(t, k)
        if k == "new" then
            return nil    
        end
        
        local value = rawget(class, k)
        
        if value then
            t[k] = value
            return value
        end
        
        for i = 1, #super_classes do
            local super_class = type(super_classes[i]) == "table" and super_classes[i] or __classes[super_classes[i]]
            local value = super_class[k]
            
            if value then
                t[k] = value
                return value    
            end
        end
    end

    class.is_a = function(s, c)
        if type(s) == "string" then
            s = __classes[s]
        end

        if type(c) == "string" then
            c = __classes[c]
        end

        if s == c then
            return true
        end

        local supers = s.__super_classes

        if supers then
            for i = 1, #supers do
                if class.is_a(supers[i], c) then
                    return true
                end
            end
        end

        return false
    end

    class.__call = function(s, ...)
        return s.new(...)
    end
    
    function class.new(...)
        local object = setmetatable({}, class)
        
        if class.init then
            class.init(object, ...)    
        end
        
        return object
    end

    class.__class = name
    class.__super_classes = super_classes

    __classes[name] = class

    return class
end

local class = setmetatable({
    get = function(name) 
        return setmetatable({}, {
            __index = function(s, i) 
                return __classes[name][i]
            end,
            __call = function(s, ...) 
                return __classes[name](...) 
            end
        })
    end,

    exists = function(name)
        return __classes[name] ~= nil
    end
}, {
    __call = function(s, name, ...)
        return make_class(name, ...)
    end
})

return class