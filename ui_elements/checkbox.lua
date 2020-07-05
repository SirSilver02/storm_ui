local button = require((...):gsub("[^/]+$", "/button"))

local checkbox = class(button)

function checkbox:init()
    button.init(self)

    self.checked = false
    
    self:add_hook("on_clicked", function()
        self.checked = not self.checked
        self.background_color, self.depressed_color = self.depressed_color, self.background_color

        if self.checked then
            self:run_hooks("on_checked")
        else
            self:run_hooks("on_unchecked")
        end
    end)
end

function checkbox:post_init()
    button.post_init(self)

    self.outline_color = self.ui_manager.theme.checkbox.outline_color
end

function checkbox:check_internal()
    self.checked = true
    self.background_color, self.depressed_color = self.depressed_color, self.background_color
end

function checkbox:uncheck_internal()
    self.checked = false
    self.background_color, self.depressed_color = self.ui_manager.theme.panel.background_color, self.ui_manager.theme.button.depressed_color
end

function checkbox:post_init()
    button.post_init(self)
    self:set_text("")
end

return checkbox