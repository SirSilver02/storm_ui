--word_colors is a table with words as keys and colors as values

local iterations = 0

local function colored_text(text, word_colors, default_color)
    default_color = default_color or {1, 1, 1}
    local lower_text = text:lower()

    local colored_text = {original_text = text}
    local matches = {}

    for word, color in pairs(word_colors) do
        iterations = iterations + 1
        local start, stop = lower_text:find(word)

        while start do
            iterations = iterations + 1
            table.insert(matches, {start = start, stop = stop, color = color})
            start, stop = lower_text:find(word, stop)
        end
    end

    table.sort(matches, function(a, b)
        return a.start < b.start
    end)

    local string_i = 1
    local matches_i = 1

    while string_i < #text + 1 do
        local match = matches[matches_i]

        if match then
            if match.start == string_i then
                table.insert(colored_text, match.color)
                table.insert(colored_text, text:sub(match.start, match.stop))

                string_i = match.stop
                matches_i = matches_i + 1
            else
                table.insert(colored_text, default_color)
                table.insert(colored_text, text:sub(string_i, match.start - 1))

                string_i = match.start - 1
            end

            string_i = string_i + 1
        else
            table.insert(colored_text, default_color)
            table.insert(colored_text, text:sub(string_i, #text))

            break
        end
    end

    iterations = 0
    return colored_text
end

return colored_text