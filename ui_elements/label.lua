local table_copy = modules.util.table.copy

local panel = modules.class.get("panel")

local label = modules.class("label", "panel")

function label:init()
    panel.init(self)

    self:set_hover_enabled(false)
end

function label:post_init()
    panel.post_init(self)

    self:set_draw_background(false)
    self:set_draw_outline(false)

    self.font = self.ui.theme.label.font
    self.text = "label"
    self.text_align = 7
    self.rotation = 0
    self.text_object = love.graphics.newText(self.font, self.text)

    self:set_text_color({unpack(self.ui.theme.label.text_color)})
    self:set_dropshadow_color({unpack(self.ui.theme.label.text_shadow_color)})
    self:set_text_outline_color({unpack(self.ui.theme.label.text_outline_color)})
    self:set_text_outline_distance(self.ui.theme.label.text_outline_distance)
    self:set_dropshadow_offset(self.ui.theme.label.dropshadow_offset)

    self:add_hook("on_validate", function(this)
        this:set_text(this.text) --use .text over get_text() in case self.text is a text_object
    end)
end

function label:size_to_contents()
    local padding = self:get_dock_padding()
    self.w = self.font:getWidth(self:get_text()) + padding[1] + padding[3] 
    self.h = self.font:getHeight() + padding[2] + padding[4]

    if self.should_draw_text_outline then
        self.w = self.w + self:get_text_outline_distance() * 2
        self.h = self.h + self:get_text_outline_distance() * 2
    end

    self:set_text(self.text)
end

function label:get_horizontal_align()
    local align = self.text_align

    if align == 1 or align == 4 or align == 7 then
        return "left"
    elseif align == 2 or align == 5 or align == 8 then
        return "center"
    elseif align == 3 or align == 6 or align == 9 then
        return "right"
    end
end

function label:get_align()
    return self.text_align
end

function label:set_align(align)
    self.text_align = align
    self:set_text(self.text)
end

local function is_colored_text(colored_text)
    return type(colored_text) == "table" and colored_text.original_text and colored_text[1] and colored_text[2] and type(colored_text[1]) == "table" and type(colored_text[2]) == "string"
end

function label:get_text()
    --if text is colored_text_table
    if is_colored_text(self.text) then
        return self.text.original_text
    end

    return self.text
end

function label:set_text(text)
    if not text then
        text = ""
    end

    --local outline_distance = self.should_draw_text_outline and self.outline 

    if is_colored_text(text) then
        self.text = text --store the colored_text here
    else
        self.text = tostring(text)
    end

    self.text_object:setf(self.text, self.w, self:get_horizontal_align())

    self:run_hooks("on_set_text", self.text)
end

function label:set_text_colored(text, word_colors, default_color)
    self:set_text(modules.colored_text(text, word_colors, default_color))
end

function label:get_font()
    return self.font
end

function label:set_font(font)
    self.font = font
    self.text_object:setFont(self.font)
end

function label:set_dropshadow_color(r, g, b, a)
    self.text_shadow_color = type(r) == "table" and table_copy(r) or {r, g, b, a}
end

function label:get_dropshadow_color()
    return self.text_shadow_color
end

function label:set_text_color(r, g, b, a)
    assert(r, "No color passed to set_text_color.")
    self.text_color = type(r) == "table" and table_copy(r) or {r, g, b, a}
end

function label:set_text_alpha(a)
    self.text_color[4] = a
end

function label:get_text_color()
    return self.text_color
end

function label:set_dropshadow(bool)
    self.should_draw_dropshadow = bool
end

function label:get_dropshadow()
    return self.should_draw_dropshadow
end

function label:set_dropshadow_offset(x, y)
    self.dropshadow_offset = type(x) == "table" and table_copy(x) or {x, y}
end

function label:get_dropshadow_offset()
    return self.dropshadow_offset
end

function label:set_text_outline(bool)
    self.should_draw_text_outline = bool
end

function label:get_text_outline()
    return self.should_draw_text_outline
end

function label:set_text_outline_color(r, g, b, a)
    self.text_outline_color = type(r) == "table" and table_copy(r) or {r, g, b, a}
end

function label:set_text_outline_alpha(a)
    self.text_outline_color[4] = a
end

function label:get_text_outline_color()
    return self.text_outline_color
end

function label:set_text_outline_distance(distance)
    self.text_outline_distance = distance
end

function label:get_text_outline_distance()
    return self.text_outline_distance
end

local left_offset = function(x, distance)
    return x + distance
end

local right_offset = function(x, distance)
    return x - distance
end

local x_offset = {
    [1] = left_offset,
    [4] = left_offset,
    [7] = left_offset,

    [3] = right_offset,
    [6] = right_offset,
    [9] = right_offset
}

function label:draw_text()
    if not self.text then
        return
    end

    local text_height = self.text_object:getHeight()
    local x, y = self:get_screen_pos()

    if self.text_align < 4 then
        y =  y + self.h - text_height
    elseif self.text_align > 3 and self.text_align < 7 then
        y = y + self.h / 2 - text_height / 2
    end

    if self.should_draw_text_outline then
        local offset_func = x_offset[self.text_align]
        
        if offset_func then
            x = offset_func(x, self:get_text_outline_distance())
        end
    end

    if self.should_draw_dropshadow then
        local offset = self:get_dropshadow_offset()
        love.graphics.setColor(self.text_shadow_color)
        love.graphics.draw(self.text_object, x + offset[1], y + offset[2])
    end
    
    if self.should_draw_text_outline then
        local distance = self:get_text_outline_distance()
        love.graphics.setColor(self:get_text_outline_color())

        for y2 = -distance, distance do
            for x2 = -distance, distance do
                love.graphics.draw(self.text_object, x + x2 , y + y2)  --Buggy wuggy, text_outline_color_alpha will make this less transparent than it should be, could use canvases.... maybe blending mode?
            end
        end
    end

    love.graphics.setColor(self.text_color)
    love.graphics.draw(self.text_object, x, y)
end

function label:draw()
    panel.draw(self)
    self:draw_text()
end

return label