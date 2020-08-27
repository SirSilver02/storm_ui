--This whole thing needs to be reconsidered because
--as it stands I keep coming in here to change the
--designed width and designed height on a per game basis

local theme = {
    window = {
        designed_width = love.graphics.getWidth(),
        designed_height = love.graphics.getHeight()
    },

    panel = {
        background_color = math.divide_by_255({30, 34, 33, 255}),
        outline_color = math.divide_by_255({0, 0, 0, 255}),
        outline_width = 1
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
        hovered_color = math.divide_by_255({50, 50, 50, 100, 255}),
        depressed_color = math.divide_by_255({110, 5, 180, 255})
    },

    checkbox = {
        outline_color = math.divide_by_255({100, 100, 100, 100})
    }
}

theme.__index = theme

for k, v in pairs(theme) do
    if type(v) == "table" then
        v.__index = v
    end
end

return theme