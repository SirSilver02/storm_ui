local panel = modules.class.get("panel")

local slider = modules.class("slider", "panel")

function slider:post_init()
    panel.post_init(self)

    self.slider = self:add("panel")
    self.slider:set_size(20, 20)
    self.slider:set_background_color(self.ui.theme.button.depressed_color)
    self.slider:set_outline_radius(10, 10)

    self.percent = 0.5
    self.increment = 0.1

    local move_slider = function(this)
        local x = (self:get_width() - self.slider:get_width()) * self.percent + self.slider:get_width() / 2

        --local x = self.percent * self:get_width()
        self.slider:center_on(x, self:get_height() / 2)
    end

    local on_dragged = function(this, mx, my, dx, dy)
        local x, y = self:mouse_to_local(mx, my)
        local percent = (x - self.slider:get_width() / 2) / (self:get_width() - self.slider:get_width()) 
        self:set_percent(percent)
    end

    self:add_hook("on_mousepressed", function(this, mx, my, button)
        on_dragged(this, mx, my)
    end)

    self:add_hook("on_dragged", on_dragged)
    self.slider:add_hook("on_dragged", on_dragged)

    self:add_hook("post_draw", function(this)
        local x, y = this:get_screen_pos()
        local w, h = this:get_size()
        local height = 8

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", x, y + h / 2 - height / 2, w, height, height, height)
    end)

    self:add_hook("on_validate", function(this)
        move_slider(this)
    end)

    self:add_hook("on_percent_changed", function(this, percent)
        move_slider(this)
    end)
end

--increment divisions (2 is a boolean, 100 is percentage, 1000 is a lot)
--set line width
--set circle radius
--blah blah blah

function slider:set_percent(percent)
    --0.823 ->.8 mod by increment, floor the number, then add rounded remainder (either 0 or the value of the increment)

    if self.increments then
        local remainder = percent % self.increment


        if remainder < self.increment then
        --percent = modules.util.math.round()
        end
    end

    self.percent = modules.util.math.clamp(percent, 0, 1)
    self:run_hooks("on_percent_changed", percent)

    print(self.percent)
end

function slider:get_percent()
    return self.percent
end

return slider