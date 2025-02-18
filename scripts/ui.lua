local timer = require 'libraries.timer'

local ui = {}

local palette = {
    background = {0.051, 0.004, 0.102, 1},
    red = {0.89, 0.212, 0.373},
    green = {0.22, 0.831, 0.498},
    yellow = {0.976, 0.98, 0.361},
    purple = {0.698, 0.376, 0.922},
    offWhite = {0.93, 0.93, 0.93}
}

function ui.getPalette()
    return palette
end

function ui:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function ui:load()
    
end

function ui:update(dt)

end

function ui:draw()

end

return ui