function math.divide_by_255(number, ...)
    local is_table = type(number) == "table"
    local numbers = is_table and number or {number, ...}

    for i = 1, #numbers do
        numbers[i] = numbers[i] / 255
    end

    return is_table and numbers or unpack(numbers)
end

function math.round(number) 
    return math.floor(number + 0.5)
end

function math.clamp(number, min, max) 
    return math.min(math.max(number, min), max)
end
