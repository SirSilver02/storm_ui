local old_class = class
local old_tween = tween

tween = require(... .. "/modules/vendor/tween")
class = require(... .. "/modules/class")

require(... .. "/modules/math")

local base_theme = require(... .. "/theme")

local elements = {}

local elements_folder = ... .. "/ui_elements"
elements_folder = elements_folder:gsub("%.", "/")

local function register_from_folder(folder_path)
    for _, element in ipairs(love.filesystem.getDirectoryItems(folder_path)) do
        if element ~= "init.lua" then
            local file_path = folder_path .. "/" ..  element
        
            if love.filesystem.getInfo(file_path) then
                local extension_pattern = "%.(.+)"  --Pattern that finds a "." and all other characters after it.
                local ui_element = require(file_path:gsub(extension_pattern, ""))
                local element_name = element:gsub(extension_pattern, "")
                ui_element.element_name = element_name
                elements[element_name] = ui_element
            end
        end
    end
end

register_from_folder(elements_folder)

local panel = require(... .. "/ui_elements/panel")

local ui_manager = class(panel)
ui_manager.base_theme = base_theme
ui_manager.theme = ui_manager.base_theme
ui_manager.elements = elements
ui_manager.class = class
ui_manager.tween = tween

function ui_manager.register(element_name, ui_element)
    elements[element_name] = ui_element
end

function ui_manager.register_from_folder(folder_path)
    register_from_folder(folder_path)
end

function ui_manager.get_element(element_name)
    return elements[element_name]
end

function ui_manager.get_elements()
    return elements
end

function ui_manager:init()
    panel.init(self)

    self.ui_manager = self

    self.x = 0
    self.y = 0
    self.w = self.theme.window.designed_width
    self.h = self.theme.window.designed_height

    self.last_width = self.w
    self.last_height = self.h

    self.font = self.theme.label.font
    self.text_color = self.theme.label.text_color

    self.mouse_button_down = nil

    self.last_hovered_child = nil
    self.hovered_child = nil
    self.depressed_child = nil
    self.active_child = nil

    self.depressed_keys = {}
    self.depressed_key = nil

    self.uninstalled_events = {}

    panel.post_init(self)
    self:set_draw_outline(false)
end

function ui_manager:update_children(dt, mx, my)
    for i = 1, #self.children do
        local child = self.children[i] 

        if not child then
            break
        end

        local hover_enabled = child:get_hover_enabled()

        local sx, sy = child:get_screen_pos()
        local sw, sh = sx + child.w, sy + child.h

        child.hovered = false
        
        local parent = child:get_parent()

        while parent and hover_enabled do
            local x, y = parent:get_screen_pos()
            local w, h = x + parent.w, y + parent.h

            sx, sy = math.max(sx, x), math.max(sy, y)
            sw, sh = math.min(sw, w), math.min(sh, h)
        
            if not parent:get_hover_enabled() then
                hover_enabled = false
                break
            end

            parent = parent:get_parent()
        end
    
        if hover_enabled then
            if mx >= sx and mx <= sw then
                if my >= sy and my <= sh then    
                    if self.ui_manager.hovered_child then
                        self.ui_manager.hovered_child.hovered = false
                    end
 
                    child.hovered = true
                    self.ui_manager.hovered_child = child
                end
            end
        end
        
        child:update(dt)

        child:run_hooks("on_update", dt)

        ui_manager.update_children(child, dt, mx, my)
    end
end

function ui_manager:update(dt)
    if not self:is_on_screen() then
        return
    end

    local mx, my = love.mouse.getPosition()

    self.hovered_child = nil

    self:update_children(dt, mx, my)

    local hovered_child = self.hovered_child

    if self.last_hovered_child then
        if self.last_hovered_child ~= hovered_child then
            self.last_hovered_child:run_hooks("on_hover_end")
        end
    end
    
    if hovered_child then
        --If we're hovering over a different child than last frame.
        if hovered_child ~= self.last_hovered_child then
            hovered_child:run_hooks("on_hovered")
        end
    end
 
    self.last_hovered_child = hovered_child

    local active_child = self.active_child

    if active_child and self.depressed_key then
        active_child:run_hooks("on_keydown", self.depressed_key)
    end

    self:update_resolution()
end

function ui_manager:update_resolution()
    local ww, wh = love.graphics.getDimensions()

    if ww ~= self.last_width or wh ~= self.last_height then
        --self:resize(ww, wh)
    end
end

function ui_manager:draw()
    local r, g, b, a = love.graphics.getColor()

    self:validate()
    
    love.graphics.setColor(1, 1, 1)
        self:draw_children_of()
    love.graphics.setColor(r, g, b, a)
end

function ui_manager:draw_children_of()
    local max = math.max

    for i = 1, #self.children do
        local child = self.children[i]

        if child:get_visible() then
            if child:is_on_screen() then
                child:run_hooks("pre_draw_no_scissor")
                
                --local parent = child
                local parent = self

                while parent do
                    local x, y = parent:get_screen_pos()
                    local w, h = parent:get_size()

                    x, y = math.round(x), math.round(y)
                    w, h = math.round(w), math.round(h)
                    
                    love.graphics.intersectScissor(max(x, 0), max(y, 0), max(w, 0), max(h, 0))

                    parent = parent:get_parent()
                end

                local sx, sy, sw, sh = love.graphics.getScissor()

                local x, y = child:get_screen_pos()
                local w, h = child:get_size()

                x, y = math.round(x), math.round(y)
                w, h = math.round(w), math.round(h)

                local sx2, sy2, sw2, sh2 = love.graphics.intersectScissor(max(x, 0), max(y, 0), max(w, 0), max(h, 0))

                child:run_hooks("pre_draw")
                    child:draw()
                child:run_hooks("post_draw")

                ui_manager.draw_children_of(child)

                love.graphics.setScissor()
                love.graphics.intersectScissor(sx, sy, sw, sh)
            
                --dont want outline to be covered by it's children
                if child:get_draw_outline() then
                    love.graphics.setColor(child:get_outline_color())
                    child:draw_outline()
                end

                child:run_hooks("post_draw_children")

                love.graphics.setScissor()
            end
        end
    end
end

function ui_manager:mousepressed(x, y, button)
    local hovered_child = self.hovered_child

    if hovered_child and hovered_child.mouse_enabled then
        self:set_focus(hovered_child)

        if button == 1 then
            hovered_child.depressed = true
            self.depressed_child = hovered_child

            hovered_child:run_hooks("on_mousepressed", x, y, button)
            
            --pretty much just for buttons
            if hovered_child.last_pressed then
                local time = os.clock()

                if hovered_child.last_pressed + hovered_child.time_between_double_click >= time then
                    hovered_child:run_hooks("on_double_clicked")
                end

                hovered_child.last_pressed = time
            end
        elseif button == 2 then
            hovered_child:run_hooks("on_mousepressed", x, y, button)
        end

        if button == 3 then
            local parent = hovered_child

            while parent do
                if parent.wheel_enabled then
                    self.depressed_child = parent
                    self:set_focus(parent)

                    parent:run_hooks("on_mousepressed", x, y, button)
                    break
                end

                parent = parent:get_parent()
            end
        end
    end

    self.mouse_button_down = button
end

function ui_manager:mousereleased(x, y, button)
    local depressed_child = self.depressed_child
    
    if depressed_child and depressed_child.mouse_enabled then
        depressed_child.depressed = false
        self.depressed_child = nil

        depressed_child:run_hooks("on_mousereleased", x, y, button)

        if self.hovered_child == depressed_child then
            if button == 1 then
                depressed_child:run_hooks("on_clicked")
            elseif button == 2 then
                depressed_child:run_hooks("on_right_clicked")
            end
        end
    end

    self.mouse_button_down = nil
end

function ui_manager:mousemoved(x, y, dx, dy)
    local depressed_child = self.depressed_child

    if depressed_child and depressed_child.mouse_enabled then
        depressed_child:run_hooks("on_dragged", x, y, dx, dy)
    end
end

function ui_manager:keypressed(key)
    local active_child = self.active_child

    if key == "escape" then
        self:set_focus()
    else
        self.depressed_key = key
        self.depressed_keys[#self.depressed_keys + 1] = key

        if active_child then
            active_child:run_hooks("on_keypressed", key)
        end
    end
end

function ui_manager:keyreleased(key)
    local active_child = self.active_child
    local depressed_keys = self.depressed_keys

    for i = #depressed_keys, 1, -1 do
        if depressed_keys[i] == key then
            table.remove(depressed_keys, i)
            break
        end
    end

    self.depressed_key = depressed_keys[#depressed_keys]

    if active_child then
        active_child:run_hooks("on_keyreleased", key)

        if self.depressed_key then
            active_child:run_hooks("on_keypressed", self.depressed_key)
        end
    end
end

function ui_manager:textinput(text)
    local active_child = self.active_child

    if active_child then
        active_child:run_hooks("on_textinput", text)
    end
end

function ui_manager:wheelmoved(x, y)
    local hovered_child = self.hovered_child

    if hovered_child then
        local parent = hovered_child

        while parent do
            if parent.wheel_enabled then
                parent:run_hooks("on_wheelmoved", x, y)
                break
            end

            parent = parent:get_parent()
        end
    end
end

function ui_manager:resize(w, h)
    --self:scale(w / self.last_width, h / self.last_height)

    self.last_width, self.last_height = w, h
    self.w, self.h = w, h
    self:invalidate()
    self:validate()
end

function ui_manager:add(ui_element, ...)
    local element = assert(elements[ui_element], ui_element ..  " not a registered ui_element.").new(...)
    element.ui_manager = self.ui_manager
    element.type = ui_element
    element.parent = self
    element.z_index = #self.children
    
    element:post_init()

    table.insert(self.children, element)

    element.parent:run_hooks("on_add", element)
    self:invalidate()
    
    return element
end

function ui_manager:remove(child)
    self:invalidate()
    
    local parent = child:get_parent()
    local children = parent:get_children()

    for i = 1, #children do
        if children[i] == child then
            table.remove(children, i)

            if self:get_focus() == child then
                child:run_hooks("on_focus_lost")
            end

            child:run_hooks("on_remove")
            parent:run_hooks("on_remove_child", child)
            break
        end
    end
end

function ui_manager:set_focus(child)
    local focused_child = self.active_child

    self.active_child = child

    if child then
        self.active_child:run_hooks("on_focus")
    end

    if focused_child and focused_child ~= child then
        focused_child:run_hooks("on_focus_lost")
    end
end

function ui_manager:get_focus()
    return self.active_child
end

function ui_manager:set_font(font)
    self.font = font
end

function ui_manager:get_font()
    return self.font
end

function ui_manager:get_theme()
    return self.theme
end

function ui_manager:set_theme(theme)
    self.theme = setmetatable(theme, self.base_theme)

    for k, v in pairs(theme) do
        local base_value = self.base_theme[k]

        if type(v) == "table" and base_value then
            setmetatable(v, base_value)
        end
    end
end

function ui_manager:install(table)
    local events = {update = true, draw = true}

    for event in pairs(love.handlers) do
        events[event] = true
    end

    for event in pairs(events) do
        local old_event = table[event]

        table[event] = function(...)
            local _, a, b, c, d, e, f, g = ...

            if old_event then
                old_event(...)
            end

            if self[event] and not self.uninstalled_events[event] then
                if type(_) == "table" then
                    self[event](self, a, b, c, d, e, f, g)
                else
                    self[event](self, ...)
                end
            end
        end
    end
end

function ui_manager:uninstall_event(event)
    self.uninstalled_events[event] = true
end

class = old_class
tween = old_tween

return ui_manager