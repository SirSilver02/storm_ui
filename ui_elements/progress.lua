local panel = modules.class.get("panel")

local progress = modules.class("progress", "panel")

function progress:post_init()
    panel.post_init(self)

    self.bar = self:add("panel")
    self.bar:set_background_color(self.ui.theme.button.depressed_color)
    self.bar:set_hover_enabled(false)
    self.bar:dock("left")
end

function progress:set_percent(percent)
    self.bar:set_width(self:get_width() * percent)
end

return progress