local panel = require((...):gsub("[^/]+$", "/panel"))

local tab_panel = class(panel)

function tab_panel:post_init()
    panel.post_init(self)

    self.button_panel = self:add("panel")
    self.button_panel:dock("top")

    self.tab_panel = self:add("blank_panel")
    self.tab_panel:dock("fill")
end

function tab_panel:set_button_width(width)
    for _, button in pairs(self.button_panel.children) do
        button:set_width(width)
    end
end

function tab_panel:add_tab(name)
    local button = self.button_panel:add("button")
    button:set_text(name)
    button:dock("left")

    button:add_hook("on_clicked", function(this)

        for i, b in pairs(self.button_panel.children) do
            if b == button then
                self:set_tab(i)
                break
            end
        end
    end)

    local panel = self.tab_panel:add("panel")
    panel:hide()
    panel:dock("fill")

    return panel
end

function tab_panel:set_tab(index)
    for i, panel in pairs(self.tab_panel.children) do
        if i == index then
            panel:unhide()
        else
            panel:hide()
        end
    end
end

return tab_panel