local panel = modules.class.get("panel")

local blank_panel = modules.class("blank_panel", "panel")

function blank_panel:post_init()
    panel.post_init(self)

    self:set_draw_outline(false)
    self:set_draw_background(false)
end

return blank_panel