--This whole thing needs to be reconsidered because
--as it stands I keep coming in here to change the
--designed width and designed height on a per game basis

local divide_by_255 = modules.util.math.divide_by_255

local theme = {
    panel = {
        background_color = divide_by_255({30, 34, 33, 255}),
        outline_color = divide_by_255({0, 0, 0, 255}),
        outline_width = 1,
        outline = true,
        background = true
    },

    label = {
        text_color = {1, 1, 1, 1},
        text_shadow_color = {0, 0, 0, 0.5},
        text_outline_color = {0, 0, 0, 1},
        text_outline_distance = 2,
        dropshadow_offset = {2, 2},
        font = love.graphics.newFont(18)
    },

    button = {
        hovered_color = divide_by_255({50, 50, 50, 100, 255}),
        depressed_color = divide_by_255({110, 5, 180, 255})
    },

    checkbox = {
        outline_color = divide_by_255({100, 100, 100, 100})
    },

    scroll_panel = {
        scrollbar_width = 16,
        scrollbar_color = divide_by_255({64, 64, 64, 255}),
    },

    progress = {

    },

    slider = {
        
    }
}

theme.__index = theme

for k, v in pairs(theme) do
    if type(v) == "table" then
        v.__index = v
    end
end

return theme