--word_colors is a table with words as keys and colors as values

--returns a colored_text table that is usable with love.graphics.newText()
local function colored_text(text, word_colors, default_color)
    default_color = default_color or {1, 1, 1}
    local lower_text = text:lower()

    local colored_text = {original_text = text}
    local matches = {}

    --keeps track of the start and end substring pos of each word match
    for word, color in pairs(word_colors) do
        local start, stop = lower_text:find(word, 1, true)
        stop = stop and stop + 1

        while start do
            table.insert(matches, {start = start, stop = stop - 1, color = color})
            start, stop = lower_text:find(word, stop, true)
            stop = stop and stop + 1
        end
    end

    --sorts by which came first, necessary step.
    table.sort(matches, function(a, b)
        return a.start < b.start
    end)

    local string_i = 1
    local matches_i = 1

    while string_i < #text + 1 do
        local match = matches[matches_i]

        if match then
            if match.start == string_i then
                --have a match and currently dealing with it.
                table.insert(colored_text, match.color)
                table.insert(colored_text, text:sub(match.start, match.stop))

                string_i = match.stop
                matches_i = matches_i + 1
            else
                --if we have a match but we have non matches that we have to deal with.
                table.insert(colored_text, default_color)
                table.insert(colored_text, text:sub(string_i, match.start - 1))

                string_i = match.start - 1
            end

            --start the next substring 1 letter over.
            string_i = string_i + 1
        else
            --finishing up the end of the string that is not a match.
            table.insert(colored_text, default_color)
            table.insert(colored_text, text:sub(string_i, #text))

            break
        end
    end

    return colored_text
end

return colored_text