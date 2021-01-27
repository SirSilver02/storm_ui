local panel = require((...):gsub("[^/]+$", "/panel"))

local progress = class(panel)

function progress:post_init()
    panel.post_init(self)

    self.bar = self:add("panel")
    self.bar:set_background_color(self.ui_manager.theme.button.depressed_color)
    self.bar:dock("left")
end

function progress:set_percent(percent)
    self.bar:set_width(self:get_width() * (percent / 100))
end

return progress