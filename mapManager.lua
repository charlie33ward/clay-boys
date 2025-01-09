local sti = require 'libraries.sti'

local mapManager = {}

function mapManager:new(physicsManager)
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    self.physicsManager = physicsManager
    return manager
end

function mapManager:load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    self.map = sti('maps/puzzle-test1.lua')

    if self.map.layers["walls"] then
        for i, obj in pairs(self.map.layers["walls"].objects) do
            self.physicsManager:createWall(obj.x + (obj.width / 2), obj.y + (obj.height / 2), obj.width, obj.height)
        end
    end
end

function mapManager:getCurrentMap()
    return self.map
end

function mapManager:draw()
    self.map:drawLayer(self.map.layers["ground"])
    self.map:drawLayer(self.map.layers["wall-sprites"])
    self.map:drawLayer(self.map.layers["wall-sprites-2"])
    self.map:drawLayer(self.map.layers["wall-sprites-3"])
    self.map:drawLayer(self.map.layers["green-puzzle"])
    self.map:drawLayer(self.map.layers["blue-puzzle"])
end

function mapManager:update(dt)
    
end

return mapManager