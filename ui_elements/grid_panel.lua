local panel = require((...):gsub("[^/]+$", "/panel"))

local grid_panel = class(panel)
grid_panel.columns = 1
grid_panel.grid_width = 60
grid_panel.grid_height = 60

local on_validate = function(self)
    local w = self:get_width()
    local count = #self.children
    local columns = self.columns
    --adjust the child panels position in the self
    for i = 1, count do
        local child = self.children[i]
        child:center_on(w / (columns + 1) * i, 100)
        print(columns)
    end
end

function grid_panel:post_init()
    panel.post_init(self) 
    self:add_hook("on_validate", on_validate)
end

function grid_panel:set_grid_width(w)
    self.grid_width = w
end

function grid_panel:set_grid_height(h)
    self.grid_height = h
end

--the size of EACH individual item added to the grid
function grid_panel:set_grid_size(w, h)
    self:set_grid_width(w)
    self:set_grid_height(h)
end

function grid_panel:set_columns(columns)
    self.columns = columns
end

return grid_panel