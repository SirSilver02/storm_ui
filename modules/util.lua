local util = {
    table = {},
    math = {},
    string = {}
}

--table

function util.table.print(tab, indents, printed)
    local spaces = ""
    indents = indents or 0
    printed = printed or {}
    
    for i = 1, indents do
        spaces = spaces .. "        "
    end
    
    printed[tab] = true
    
    for k, v in pairs(tab) do
        if type(v) == "table" and not printed[v] then
            print(spaces .. k .. ":")
            util.table.print(v, indents + 1, printed)
        else
            print(spaces .. k .. ":", v)   
        end
    end
end

function util.table.copy(t)
    local copy = {}

    for k, v in pairs(t) do
        copy[k] = v
    end

    return copy
end

function util.table.reverse(t)
    for i = 1, #t / 2 do
        local swap_index = #t - (i - 1)
        t[i], t[swap_index] = t[swap_index], t[i] 
    end
end

function util.table.get_set(t, k)
    t["get_" .. k] = function(t)
        return t[k]
    end

    t["set_" .. k] = function(t, v)
        t[k] = v
    end
end

function util.table.shuffle(t)
    local count = #t --should always be 60.

    for i = 1, count do
        local random = math.random(count)
        t[i], t[random] = t[random], t[i]
    end
end

--math

function util.math.get_screen_scale(w, h, scr_w, scr_h)
    local scr_w, scr_h = scr_w or love.graphics.getWidth(), scr_h or love.graphics.getHeight()
    local scale_x = scr_w / w
    local scale_y = scr_h / h
    local smaller_scale = scale_x < scale_y and scale_x or scale_y

    return smaller_scale
end

function util.math.scale_to_screen(w, h, scr_w, scr_h)
    local scale = util.math.get_screen_scale(w, h, scr_w, scr_h)

    return w * scale, h * scale
end

function util.math.lerp(a, b, t)
    return a * (1 - t) + b * t
end

function util.math.smooth_lerp(a, b, t)
    t = t * t * (3 - 2 * t)
    return util.math.lerp(a, b, t)
end

function util.math.clamp(n, low, high) 
    return math.min(math.max(low, n), high) 
end

function util.math.round(n)
    return math.floor(n + 0.5)
end

function util.math.divide_by_255(number, ...)
    local is_table = type(number) == "table"
    local numbers = is_table and number or {number, ...}

    for i = 1, #numbers do
        numbers[i] = numbers[i] / 255
    end

    return is_table and numbers or unpack(numbers)
end

--string

function util.string.capitalize(s)
    return s:sub(1, 1):upper() .. s:sub(2)
end

return util