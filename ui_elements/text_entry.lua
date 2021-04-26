local button = modules.class.get("button")

local allowed_characters = {
    ["."] = true
}

local text_entry = modules.class("text_entry", "button")

function text_entry:init()
    button.init(self)

    self.time_since_last_keypressed = os.clock()

    self.time_since_last_keydown = os.clock()
    self.keydown_start_delay = 0.5
    self.keydown_event_delay = 0.03

    self.blink_time_passed = 0
    self.blink_duration = 0.5
    self.draw_blink_line = false
    self.numeric = false

    self.max_characters = nil
end

function text_entry:post_init()
    button.post_init(self)
    
    self:set_text("")
    self:set_align(5)
    --TODO make line | appear after the text properly

    self:add_hook("on_keypressed", function(this, key)
        local text = this:get_text()

        this.blink_time_passed = 0
        this.draw_blink_line = true

        if key == "backspace" then
            this:set_text(text:sub(1, #text - 1))
            this.time_since_last_keypressed = os.clock()
        elseif key == "return" then
            this:run_hooks("on_enter_pressed")
        end

        if love.keyboard.isDown("lctrl") then
            if key == "c" then
                love.system.setClipboardText(this:get_text())
            elseif key == "v" then
                this:set_text(love.system.getClipboardText())
            end
        end
    end)

    self:add_hook("on_keydown", function(this, key)
        local time = os.clock()

        this.blink_time_passed = 0
        this.draw_blink_line = true

        if time >= this.time_since_last_keypressed + this.keydown_start_delay then
            if time >= this.time_since_last_keydown + this.keydown_event_delay then
                local text = this:get_text()

                if key == "backspace" then
                    this:set_text(text:sub(1, #text - 1))
                    this.time_since_last_keydown = time
                end
            end
        end
    end)

    self:add_hook("on_textinput", function(this, text)
        if this:get_numeric() and not tonumber(text) then
            if not allowed_characters[text] then
                return
            end
        end

        local current_text = this:get_text()
        local max_characters = this:get_max_characters()

        if max_characters and #current_text + 1 > max_characters then
            return
        end

        this.blink_time_passed = 0
        this.draw_blink_line = true
        
        this:set_text(current_text .. text)
    end)

    self:add_hook("on_mousepressed", function(this)
        this.blink_time_passed = 0
        this.draw_blink_line = true
    end)

    self:add_hook("on_update", function(this, dt)
        if this.ui.active_child == this then
            this.blink_time_passed = this.blink_time_passed + dt
    
            if this.blink_time_passed >= this.blink_duration then
                this.blink_time_passed = 0
                this.draw_blink_line = not this.draw_blink_line
            end
        else
            this.blink_time_passed = 0
            this.draw_blink_line = false
        end
    end)
end

function text_entry:draw()
    button.draw(self)

    if self.ui.active_child == self then
        if self.draw_blink_line then
            local font = self:get_font()
            local previous_font = love.graphics.getFont()

            local x, y = self:get_screen_pos()
            local text = self:get_text()

            love.graphics.setFont(font)
                love.graphics.setColor(self:get_text_color())
                love.graphics.print("|", x + self.w / 2 + font:getWidth(text), y + self.h / 2, 0, 1, 1, font:getWidth(text) / 2, font:getHeight() / 2)
            love.graphics.setFont(previous_font)
        end
    end
end

function text_entry:set_numeric(bool)
    self.numeric = bool
end

function text_entry:get_numeric()
    return self.numeric
end

function text_entry:set_max_characters(number)
    self.max_characters = number
end

function text_entry:get_max_characters()
    return self.max_characters
end

return text_entry