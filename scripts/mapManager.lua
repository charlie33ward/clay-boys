local sti = require 'libraries.sti'
local timer = require 'libraries.timer'
local gameManager = require 'scripts.gameManager'

local debug = {}

local mapManager = {
    wallColliders = {},
    currentMap = nil
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
    },
    yellow = {
        opacity = 1,
        walls = {},
        switch = nil
    },
    darkBlue = {
        opacity = 1,
        walls = {},
        switch = nil
    },
    orange = {
        opacity = 1,
        walls = {},
        switch = nil
    },
    purple = {
        opacity = 1,
        walls = {},
        switch = nil
    },
    pink = {
        opacity = 1,
        walls = {},
        switch = nil
    },
    lime = {
        opacity = 1,
        walls = {},
        switch = nil
    },
    darkRed = {
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

local puzzle1 = {
    filepath = 'maps/puzzle-test1.lua',
    dimensions = {
        rows = 3,
        columns = 3
    },
    draw = function(manager)
        manager.map:drawLayer(manager.map.layers["ground"])
        manager.map:drawLayer(manager.map.layers["decorations"])
        manager.map:drawLayer(manager.map.layers["puzzle-walls"])
        manager.map:drawLayer(manager.map.layers["wall-sprites"])

        love.graphics.setColor(1, 1, 1, puzzleState.green.opacity)
        manager.map:drawLayer(manager.map.layers["green-puzzle"])
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setColor(1, 1, 1, puzzleState.blue.opacity)
        manager.map:drawLayer(manager.map.layers["blue-puzzle"])
        love.graphics.setColor(1, 1, 1, 1)
    end
}

local puzzle2 = {
    filepath = 'maps/puzzle-test2.lua',
    dimensions = {
        rows = 3,
        columns = 3
    },
    draw = function(manager)
        manager.map:drawLayer(manager.map.layers["ground"])
        manager.map:drawLayer(manager.map.layers["decorations"])
        manager.map:drawLayer(manager.map.layers["puzzle-walls"])

        love.graphics.setColor(1, 1, 1, puzzleState.green.opacity)
        manager.map:drawLayer(manager.map.layers["green-puzzle"])
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setColor(1, 1, 1, puzzleState.blue.opacity)
        manager.map:drawLayer(manager.map.layers["blue-puzzle"])  
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setColor(1, 1, 1, puzzleState.yellow.opacity)
        manager.map:drawLayer(manager.map.layers["yellow-puzzle"])  
        love.graphics.setColor(1, 1, 1, 1)
    end
}

local puzzle3 = {
    filepath = 'maps/puzzle-test3.lua',
    dimensions = {
        rows = 3,
        columns = 4
    },
    draw = function(manager)
        manager.map:drawLayer(manager.map.layers["ground"])
        manager.map:drawLayer(manager.map.layers["bridges"])
        manager.map:drawLayer(manager.map.layers["decorations"])
        manager.map:drawLayer(manager.map.layers["decorations2"])
        manager.map:drawLayer(manager.map.layers["puzzle-walls"])

        love.graphics.push()
        love.graphics.translate(0, 32)
        manager.map:drawLayer(manager.map.layers["tubes"])
        love.graphics.pop()

        love.graphics.setColor(1, 1, 1, puzzleState.green.opacity)
        manager.map:drawLayer(manager.map.layers["green-puzzle"])
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setColor(1, 1, 1, puzzleState.blue.opacity)
        manager.map:drawLayer(manager.map.layers["blue-puzzle"])  
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setColor(1, 1, 1, puzzleState.orange.opacity)
        manager.map:drawLayer(manager.map.layers["orange-puzzle"])  
        love.graphics.setColor(1, 1, 1, 1)
    end
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

function mapManager:reset()
    if self.currentSwitches then
        for _, switch in pairs(self.currentSwitches) do
            switch:onReleased()
        end
    end
end

function mapManager:load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    self.map = sti(puzzle3.filepath)
    self.currentMapData = puzzle3
    self.currentSwitches = {}

    local bgLayer = self.map.layers["space"]
    if bgLayer then
        bgLayer.image:setWrap('repeat', 'repeat')
        bgLayer.parallaxx = 1.3
        bgLayer.parallaxy = 1.3
    end

    self:createWalls()

    local width = self.map.width * self.map.tilewidth
    local height = self.map.height * self.map.tileheight
    
    self.game = gameManager.getInstance()
    self.game:setMapManager(self)

    self:createMapBoundaries(width, height)
    self:createTubes()
    self:createMapHazards()

    self:createPuzzlePhysics()
    self:initializePuzzleState(self.currentMapData)
    self:createPuzzleCamArea()
end

function mapManager:createWalls()
    if self.map.layers["walls"] then
        for i, obj in pairs(self.map.layers["walls"].objects) do
            local wall = nil
            local type = nil

            if obj.properties.wallType then
                type = obj.properties.wallType
                if obj.properties.wallType == 'islandBorder' then
                    debug.border = 'islandborder detected'
                end
            end
            
            if obj.rotation ~= 0 then
                wall = physicsManager:createWall(obj.x, obj.y, obj.width, obj.height, obj.rotation, type)
            else
                wall = physicsManager:createWall(obj.x + (obj.width / 2), obj.y + (obj.height / 2), obj.width, obj.height, nil, type)
            end

            if obj.properties.isIslandBorder then

                wall:setWallType('islandBorder')
                
                function wall:preSolve(other, collision)
                    if other.identifier == 'ball' then
                        debug.islandPresolve = 'presolve'
                        collision:setEnabled(false)
                    end
                end
            end
        end
    end
end

function mapManager:createMapHazards()
    if self.map.layers["hazard"] then

        local currentGame = self.game

        for _, obj in pairs(self.map.layers['hazard'].objects) do
            local hazard = nil

            if obj.rotation ~= 0 then
                hazard = physicsManager:createWall(obj.x, obj.y, obj.width, obj.height, obj.rotation)
            else
                hazard = physicsManager:createWall(obj.x + (obj.width / 2), obj.y + (obj.height / 2), obj.width, obj.height)
            end

            hazard:setSensor(true)

            function hazard:enter(other)
                if other.identifier == 'clone' or other.identifier == 'player' then
                    currentGame:triggerDeathEvent(other.getX(), other.getY())
                end
            end
        end
    end
end

function mapManager:createTubes()
    if self.map.layers["tubes"] then
        for i, obj in pairs(self.map.layers["tubes"].objects) do
            local tube = {}
            tube.collider = physicsManager:createTube(obj.x, obj.y, obj.width, obj.height, obj.rotation)

            function tube.collider:preSolve(other, collision)
                if other.identifier == 'ball' then
                    collision:setEnabled(false)
                end
            end

            function tube.collider:postSolve(other, collision)
                if other.identifier == 'ball' then
                    
                end
            end
        end
    end
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
        -- if not puzzleState[color].switch then   
            local switch = self:createSwitch(obj, color)
            puzzleState[color].switch = switch
        -- end
    elseif obj.name == 'switch-sprite' then
        
    else
        local wall = self:createPuzzleWall(obj, color)
        table.insert(puzzleState[color].walls, wall)
    end
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

    local x = obj.x
    local y = obj.y
    local objectsInside = 0

    -- custom shapes displace 1 height above for some reason, this fixes
    if obj.properties.isCustomShape then
        y = y + obj.height
    end

    switch.collider = physicsManager:createPuzzleWall(x, y, obj.width, obj.height)
    switch.collider:setSensor(true)
    switch.collider:setIdentifier('switch')

    function switch:getSwitchCollider()
        return switch.collider
    end

    function switch.collider:enter(other)
        if other.identifier ~= 'ball' and other.identifier ~= 'combineSensor' then
            objectsInside = objectsInside + 1
            switch:onTriggered()
        end
    end

    function switch.collider:exit(other)
        if other.identifier ~= 'ball' and other.identifier ~= 'combineSensor' then
            objectsInside = objectsInside - 1
            if objectsInside == 0 then
                switch:onReleased()
            end
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

    table.insert(self.currentSwitches, switch)
end


function mapManager:initializePuzzleState(puzzle)

end

function mapManager:draw()

    if self.cam then
        self.map:drawImageLayer(self.map.layers["space"], camCoords, self.cam:getCameraZoom(), self.currentMapData.dimensions)
    else
        self.map:drawImageLayer(self.map.layers["space"])
    end

    self.currentMapData.draw(self)

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
    
    if self.cam then
        camCoords.x = self.cam:getX()
        camCoords.y = self.cam:getY()
    end

    
    
    self.map:update(dt)
end

function mapManager:buttonPressed()

end

return mapManager