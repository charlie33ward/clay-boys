local sti = require 'libraries.sti'

local mapManager = {
    wallColliders = {}
}

local puzzle1 = {
    filepath = 'maps/puzzle-test1.lua',
    blue = {
        walls = {}
    },
    green = {
        walls = {}
    }
}

local camCoords = {
    x = 0,
    y = 0
}

function mapManager:setCam(cam)
    self.cam = cam
end

function mapManager:new(physicsManager)
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    self.physicsManager = physicsManager
    return manager
end

function mapManager:load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    self.map = sti(puzzle1.filepath)
    self.currentMapData = puzzle1

    local bgLayer = self.map.layers["space"]
    if bgLayer then
        bgLayer.image:setWrap('repeat', 'repeat')
        bgLayer.parallaxx = 1.3
        bgLayer.parallaxy = 1.3
    end

    if self.map.layers["walls"] then
        for i, obj in pairs(self.map.layers["walls"].objects) do
            self.physicsManager:createWall(obj.x + (obj.width / 2), obj.y + (obj.height / 2), obj.width, obj.height)
        end
    end

    local width = self.map.width * self.map.tilewidth
    local height = self.map.height * self.map.tileheight
    self:createMapBoundaries(width, height)

    self:createPuzzlePhysics()
    self:initializePuzzleState(self.currentMapData)
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

function mapManager:createPuzzlePhysics()
    
    if self.currentMapData.blue then
        for _, obj in pairs(self.map.layers['blue-puzzle'].objects) do
            if obj.name == 'switch' then
                local switch = {
                    obj = obj,
                    -- collider = self.physicsManager:
                }
                obj:setSensor(true)
                -- local switchCollider = 
            else
                local puzzleWall = self.physicsManager:createPuzzleWall(obj.x + (obj.width / 2), obj.y + (obj.height / 2), obj.width, obj.height)
                table.insert(self.currentMapData.blue.walls, puzzleWall)
            end
        end
    end

end

function mapManager:initializePuzzleState(puzzle)

end

function mapManager:draw()

    if self.cam then
        self.map:drawImageLayer(self.map.layers["space"], camCoords, self.cam:getCameraZoom())
    else
        self.map:drawImageLayer(self.map.layers["space"])
    end



    self.map:drawLayer(self.map.layers["ground"])
    self.map:drawLayer(self.map.layers["decorations"])
    -- self.map:drawLayer(self.map.layers["walls"])
    self.map:drawLayer(self.map.layers["wall-sprites"])
    self.map:drawLayer(self.map.layers["green-puzzle"])
    self.map:drawLayer(self.map.layers["blue-puzzle"])

end

function mapManager:update(dt)
    if self.cam then
        camCoords.x = self.cam:getX()
        camCoords.y = self.cam:getY()
    end
    
    self.map:update(dt)
end

function mapManager:buttonPressed()

end

return mapManager