local panel = modules.class.get("panel")

local scroll_panel = modules.class("scroll_panel", "panel")

function scroll_panel:init()
    panel.init(self)

    self.wheel_scroll_x = 0
    self.wheel_scroll_y = 0

    self.wheel_scrolling = false
    self.wheel_enabled = true
    self.scroll_y = 0
end

function scroll_panel:post_init()
    panel.post_init(self)

    self.right_panel = self:add("panel")
    self.right_panel:dock("right")
    self.right_panel:set_scalable(false)
    self.right_panel:set_width(self.ui.theme.scroll_panel.scrollbar_width)

    self.right_panel:add_hook("on_mousepressed", function(this, x, y, button)
        if button == 1 then
            local local_x, local_y = this:mouse_to_local(x, y)
            local scrollbar_height = self.scrollbar:get_height()
            self.scrollbar:set_pos(0, math.min(math.max(0, local_y - scrollbar_height / 2), self:get_height() - scrollbar_height))

            self.main_panel.y = -self.scrollbar.y * (self.main_panel:get_height() / self:get_height())
            self.scroll_y = self.main_panel.y

            --Fake it 'til you make it. Honestly this is probably not a good idea though. 
            --TODO: Check for bugs where depressed_child is set by ui
            self.ui.depressed_child = self.scrollbar
            self.scrollbar.depressed = true
            this.depressed = false
            --self.ui:set_focus(self.scrollbar)
        end
    end)
    
    self.scrollbar = self.right_panel:add("button")
    self.scrollbar:set_text("")
    self.scrollbar:set_width(self.right_panel:get_width())
    self.scrollbar:set_background_color(self.ui.theme.scroll_panel.scrollbar_color)

    self.scrollbar:add_hook("on_dragged", function(this, x, y, dx, dy)
        local local_x, local_y = this:mouse_to_local(x, y)
        local scrollbar_height = self.scrollbar:get_height()

        --self.scrollbar:set_pos(0, math.min(math.max(0, this.y + dy), self:get_height() - scrollbar_height))
        self.scrollbar:set_pos(0, this.y + dy)

        self.main_panel.y = modules.util.math.round(-self.scrollbar.y * (self.main_panel:get_height() / self:get_height()))
        self.scroll_y = self.main_panel.y
                
        local duration = 0.1
        local time_passed = 0

        local function slide_down(this, dt)
            time_passed = modules.util.math.clamp(time_passed + dt, 0, duration)
    
            if time_passed == duration then
                self:remove_hook("on_update", "slide_down")
                return
            elseif self.scroll_y <= 0 then
                self:remove_hook("on_update", "slide_down")
                return
            end

            self.scrollbar:run_hooks("on_dragged", mx, my, x, self.scroll_y * (time_passed / duration))
        end
        
        local function slide_up(this, dt)
            time_passed = modules.util.math.clamp(time_passed + dt, 0, duration)
    
            if time_passed == duration then
                self:remove_hook("on_update", "slide_up")
                return
            elseif self.scroll_y >= -self.main_panel:get_height() + self:get_height() then
                self:remove_hook("on_update", "slide_up")
                return
            end

            self.scrollbar:run_hooks("on_dragged", mx, my, x, (self.scroll_y + self.main_panel:get_height() - self:get_height()) * (time_passed / duration))
        end

        --if too far scrolled up
        if self.scroll_y > 0 then
            self:add_hook("on_update", "slide_down", slide_down)
        elseif self.scroll_y < -self.main_panel:get_height() + self:get_height() then
            self:add_hook("on_update", "slide_up", slide_up)
        end
    end)

    self.right_panel:add_hook("on_dragged", function(this, x, y, dx, dy)
        self.scrollbar:run_hooks("on_dragged", x, y, dx, dy)
    end)

    local p = self:add("panel")
    p:set_draw_outline(false)
    p:set_draw_background(false)
    p:dock("fill")

    self.main_panel = p:add("panel")
    self.main_panel:set_draw_outline(false)
    self.main_panel:set_draw_background(false)
    self.main_panel:dock("fill")

    self.main_panel:add_hook("on_validate", function(this)
        local new_height = self:get_height() * (self:get_height() / self.main_panel:get_height())
        local max_height = self:get_height()
        --self.scrollbar:set_height(math.min(new_height, max_height))
        self.scrollbar.h = (math.min(new_height, max_height))

        this.y = self.scroll_y
    end)

    self:add_hook("on_wheelmoved", function(this, x, y)
        local mx, my = self.ui:get_mouse_pos()

        local duration = 0.5
        local time_passed = 0
        local remaining = -y * 40 --distance to travel over duration of scroll

        local func 

        func = function(this, dt)
            time_passed = modules.util.math.clamp(time_passed + dt, 0, duration)

            if time_passed == duration then
                self:remove_hook("on_update", func)
                return
            end

            local distance = remaining * (time_passed / duration)
            remaining = remaining - distance

            self.scrollbar:run_hooks("on_dragged", mx, my, x, distance)
        end

        self:add_hook("on_update", func)
    end)

    self:add_hook("on_mousepressed", function(this, x, y, button)
        if button == 3 and self.wheel_enabled then
            self.wheel_scroll_x = x
            self.wheel_scroll_y = y

            self.wheel_scrolling = true
        end
    end)

    self:add_hook("on_mousereleased", function(this, x, y, button)
        if button == 3 then
            self.wheel_scrolling = false
        end
    end)

    self:add_hook("on_update", function(this, dt)
        if self.wheel_scrolling then
            local mx, my = self.ui:get_mouse_pos()
            local dx, dy = 0, my - self.wheel_scroll_y

            self.scrollbar:run_hooks("on_dragged", mx, my, dx, dy / 4)
        end
    end)

    self:add_hook("on_update", "hide_right_panel", function(this, dt)
        if self.main_panel.h > self.h then
            self.right_panel:unhide()
        else
            self:scroll_to_top()
            self.right_panel:hide()
        end
    end)

    self:add_hook("post_draw_children", function(this)
        if self.wheel_scrolling then
            local x, y = self.wheel_scroll_x, self.wheel_scroll_y
            local r = 20

            love.graphics.setColor(self.ui.theme.scroll_panel.scrollbar_color)
            love.graphics.circle("fill", x, y, r)

            love.graphics.setColor(self:get_outline_color())
            love.graphics.circle("line", x, y, r)
        end
    end)
end

function scroll_panel:add(type)
    local main_panel = self.main_panel

    if main_panel then
        local child = main_panel:add(type)

        child:add_hook("on_validate", function()
            main_panel:size_to_contents()
        end)

        return child
    end

    return panel.add(self, type)
end

function scroll_panel:remove_children()
    self.main_panel:remove_children()
end

function scroll_panel:get_main_panel()
    return self.main_panel
end

function scroll_panel:get_children()
    return self.main_panel:get_children()
end

function scroll_panel:scroll_to_bottom()
    local scroll_panel_h = self:get_height()
    local main_panel_h = self.main_panel:get_height()

    self.scrollbar:set_pos(0, scroll_panel_h - self.scrollbar:get_height())
    self.main_panel.y = main_panel_h > scroll_panel_h and scroll_panel_h - main_panel_h or 0
    self.scroll_y = self.main_panel.y
end

function scroll_panel:scroll_to_top()
    self.scrollbar:set_pos(0, 0)
    self.main_panel.y = 0
    self.scroll_y = 0
end

return scroll_panel

--ANYTHING THAT ACTS ON THE CHILDREN OF A SCROLL PANEL NEEDS TO DETOUR TO THE MAIN PANEL