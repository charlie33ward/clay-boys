local sti = require 'libraries.sti'

local mapManager = {
}

local puzzle1 = {
    blueSwitch = false,
    greenSwitch = false
}

function mapManager:new(physicsManager)
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    self.physicsManager = physicsManager
    return manager
end

function mapManager:load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    self.map = sti('maps/test-map.lua')

    if self.map.layers["walls"] then
        for i, obj in pairs(self.map.layers["walls"].objects) do
            self.physicsManager:createWall(obj.x + (obj.width / 2), obj.y + (obj.height / 2), obj.width, obj.height)
        end
    end

    local width = self.map.width * self.map.tilewidth
    local height = self.map.height * self.map.tileheight
    self:createMapBoundaries(width, height)
end

function mapManager:createMapBoundaries(width, height)
    self.physicsManager:createWall(width + 1, height / 2, 2, height)
    self.physicsManager:createWall(-1, height / 2, 2, height)
    self.physicsManager:createWall(width / 2, -1, width, 2)
    self.physicsManager:createWall(width / 2, height + 1, width, 2)
end

function mapManager:getCurrentMap()
    return self.map
end

function mapManager:draw()
    -- self.map:drawLayer(self.map.layers["space"])
    self.map:drawLayer(self.map.layers["ground"])
    self.map:drawLayer(self.map.layers["ground-details"])
    self.map:drawLayer(self.map.layers["paths"])
    self.map:drawLayer(self.map.layers["ground-upper"])
    self.map:drawLayer(self.map.layers["decorations"])
    self.map:drawLayer(self.map.layers["decorations-2"])
end

function mapManager:update(dt)
    self.map:update(dt)
end

return mapManager