local panel = require((...):gsub("[^/]+$", "/panel"))

local slider = class(panel)

function slider:post_init()
    panel.post_init(self)

    self.slider = self:add("panel")
    self.slider:set_size(20, 20)
    self.slider:set_background_color(self.ui_manager.theme.button.depressed_color)
    self.slider:set_outline_radius(10, 10)

    self.percent = 0.5

    local move_slider = function(this)
        self.slider:center_on(self:get_width() * self.percent, self:get_height() / 2)
    end

    local on_dragged = function(this, mx, my, dx, dy)
        local x, y = self:mouse_to_local(mx, my)
        local percent = math.clamp(x / self:get_width(), 0, 1)
        self:set_percent(percent)
    end

    self:add_hook("on_mousepressed", function(this, mx, my, button)
        local x, y = self:mouse_to_local(mx, my)
        local percent = math.clamp(x / self:get_width(), 0, 1)
        self:set_percent(percent)
    end)

    self:add_hook("on_dragged", on_dragged)
    self.slider:add_hook("on_dragged", on_dragged)

    self:add_hook("post_draw", function(this)
        local x, y = this:get_screen_pos()
        local w, h = this:get_size()
        local old_line_width = love.graphics.getLineWidth()

        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(8)
        love.graphics.line(x, y + h / 2, x + w, y + h / 2)
        love.graphics.setLineWidth(old_line_width)
    end)

    self:add_hook("on_validate", function(this)
        move_slider(this)
    end)

    self:add_hook("on_percent_changed", function(this, percent)
        move_slider(this)
    end)
end

--set line width
--set circle radius
--blah blah blah

function slider:set_percent(percent)
    self.percent = percent
    self:run_hooks("on_percent_changed", percent)
end

return slider