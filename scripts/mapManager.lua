local sti = require 'libraries.sti'
local timer = require 'libraries.timer'

local debug = {}

local mapManager = {
    wallColliders = {}
}

local puzzle1 = {
    filepath = 'maps/puzzle-test1.lua',
    dimensions = {
        rows = 3,
        columns = 3
    }
}

local wallsToUpdate = {}

local activatedPuzzleWalls = {}
local puzzleWallKey = 0

local puzzleState = {
    blue = {
        opacity = 1,
        walls = {},
        switch = nil
    },
    green = {
        opacity = 1,
        walls = {},
        switch = nil
    }
}

local puzzleCamSettings = {
    x = 0,
    y = 0
}

local function setPuzzleOpacity(color, opacity)
    puzzleState[color].opacity = opacity
end

local currentInstance = nil
local physicsManager = nil

function mapManager.setCurrentInstance(instance)
    currentInstance = instance
end

function mapManager.getCurrentInstance()
    return currentInstance
end

local camCoords = {
    x = 0,
    y = 0
}

function mapManager:setCam(cam)
    self.cam = cam
end

function mapManager:setPlayer(player)
    self.player = player
end

function mapManager:new(physics)
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    physicsManager = physics
    mapManager.setCurrentInstance(self)
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
            physicsManager:createWall(obj.x + (obj.width / 2), obj.y + (obj.height / 2), obj.width, obj.height)
        end
    end

    local width = self.map.width * self.map.tilewidth
    local height = self.map.height * self.map.tileheight
    self:createMapBoundaries(width, height)

    self:createPuzzlePhysics()
    self:initializePuzzleState(self.currentMapData)
    self:createPuzzleCamArea()
end

function mapManager:createPuzzleCamArea()
    for _,layer in pairs(self.map.layers) do
        if layer.name:match("cam") then
            for _, obj in pairs(layer.objects) do
                if obj.name == 'puzzle-zone' then
                    local zone = {
                        obj = obj,
                        x = obj.x,
                        y = obj.y,
                        width = obj.width,
                        height = obj.height
                    }
                    zone.collider = physicsManager:createDetectionArea(zone.x, zone.y, zone.width, zone.height)
                    zone.collider:setIdentifier('detectionArea')

                    function zone.collider:enter(other)
                        if other.identifier == 'player' then
                            mapManager.cam:setPuzzleCam(puzzleCamSettings.zoom, puzzleCamSettings.x, puzzleCamSettings.y)
                        end
                    end

                    function zone.collider:exit(other)
                        if other.identifier == 'player' then
                            mapManager.cam:setDefaultCam()
                        end
                    end
                elseif obj.name == 'cam-position' then
                    puzzleCamSettings.x = obj.x
                    puzzleCamSettings.y = obj.y
                    puzzleCamSettings.zoom = obj.properties.zoom
                end
            end
        end
    end


end

function mapManager:createMapBoundaries(width, height)
    physicsManager:createWall(width + 1, height / 2, 2, height)
    physicsManager:createWall(-1, height / 2, 2, height)
    physicsManager:createWall(width / 2, -1, width, 2)
    physicsManager:createWall(width / 2, height + 1, width, 2)
end

function mapManager:getCurrentMap()
    return self.map
end

function mapManager:createPuzzlePhysics()
    for _, layer in pairs(self.map.layers) do
        local layerName = layer.name:match('.-puzzle$')
        if layerName then
            for _, obj in pairs (layer.objects) do
                local color = layerName:match("^(%w+)-puzzle$")
                self:createPuzzleObject(obj, color)
            end
        end
    
    end
end

function mapManager:createPuzzleObject(obj, color)    
    if obj.name == 'switch' then
        if not puzzleState[color].switch then   
            local switch = self:createSwitch(obj, color)
            puzzleState[color].switch = switch
        end
    else
        local wall = self:createPuzzleWall(obj, color)
        table.insert(puzzleState[color].walls, wall)
    end
end

local function createPuzzleCollider(wall)
    
end


function mapManager:createPuzzleWall(obj, color)
    local wall = {
        obj = obj,
        pendingPushes = {}
    }
    wall.collider = physicsManager:createPuzzleWall(obj.x, obj.y, obj.width, obj.height)
    wall.key = puzzleWallKey
    puzzleWallKey = puzzleWallKey + 1

    function wall:deactivateCollider()
        wall.collider:setSensor(true)
    end

    function wall:activateCollider()
        table.insert(wallsToUpdate, wall)
    end

    function wall:update(dt)
        if wall.collider == nil then
            wall.collider = physicsManager:createPuzzleWall(obj.x, obj.y, obj.width, obj.height)
        end
    end

    return wall
end

function mapManager:createSwitch(obj, color)
    local switch = {
        obj = obj,
        color = color,
        isTriggered = false
    }

    switch.collider = physicsManager:createPuzzleWall(obj.x, obj.y, obj.width, obj.height)
    switch.collider:setSensor(true)
    switch.collider:setIdentifier(physicsManager.getValidIdentifiers().switch)

    function switch:getSwitchCollider()
        return switch.collider
    end

    function switch.collider:enter(other)
        if other.identifier ~= physicsManager.getValidIdentifiers().ball then
            switch:onTriggered()
        end
    end

    function switch.collider:exit(other)
        if other.identifier ~= physicsManager.getValidIdentifiers().ball then
            switch:onReleased()
        end
    end

    function switch:onTriggered() 
        switch.isActive = true
        setPuzzleOpacity(switch.color, 0.2)
        for _, wall in pairs(puzzleState[switch.color].walls) do
            wall:deactivateCollider()
        end
    end

    function switch:onReleased()
        switch.isActive = false
        setPuzzleOpacity(switch.color, 1)
        for _, wall in pairs(puzzleState[switch.color].walls) do
            wall:activateCollider()
        end
    end
end


function mapManager:initializePuzzleState(puzzle)

end

function mapManager:draw()

    if self.cam then
        self.map:drawImageLayer(self.map.layers["space"], camCoords, self.cam:getCameraZoom(), self.currentMapData.dimensions)
    else
        self.map:drawImageLayer(self.map.layers["space"])
    end



    self.map:drawLayer(self.map.layers["ground"])
    self.map:drawLayer(self.map.layers["decorations"])
    self.map:drawLayer(self.map.layers["puzzle-walls"])
    self.map:drawLayer(self.map.layers["wall-sprites"])

    love.graphics.setColor(1, 1, 1, puzzleState.green.opacity)
    self.map:drawLayer(self.map.layers["green-puzzle"])
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(1, 1, 1, puzzleState.blue.opacity)
    self.map:drawLayer(self.map.layers["blue-puzzle"])  
    love.graphics.setColor(1, 1, 1, 1)

end

function mapManager:drawDebug()
    local y = 50

    if debug then
        for _, message in pairs(debug) do
            love.graphics.print(message, 400, y)
            y = y + 20
        end
    end
end

function mapManager:update(dt)
    for i = #wallsToUpdate, 1, -1 do
        local wall = wallsToUpdate[i]
        wall.collider:destroy()
        wall.collider = nil
        wall:update(dt)
        table.remove(wallsToUpdate, i)
    end
    
    timer.update(dt)
    if self.cam then
        camCoords.x = self.cam:getX()
        camCoords.y = self.cam:getY()
    end
    
    self.map:update(dt)
end

function mapManager:buttonPressed()

end

return mapManager