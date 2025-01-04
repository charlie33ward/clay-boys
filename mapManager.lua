local sti = require 'libraries.sti'
local physicsManager = require 'physicsManager'

local mapManager = {}

function mapManager:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function mapManager:load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    self.map = sti('maps/test-map.lua')

    if self.map.layers["walls"] then
        for i, obj in pairs(self.map.layers["walls"].objects) do
            physicsManager:createWall(obj.x, obj.y, obj.width, obj.height)
        end
    end
end

function mapManager:getCurrentMap()
    return self.map
end

function mapManager:draw()
    self.map:drawLayer(self.map.layers["ground"])
    self.map:drawLayer(self.map.layers["ground-details"])
    self.map:drawLayer(self.map.layers["paths"])
    self.map:drawLayer(self.map.layers["ground-upper"])
    self.map:drawLayer(self.map.layers["decorations"])
    self.map:drawLayer(self.map.layers["decorations-2"])
end

function mapManager:update(dt)
    
end

return mapManager