local bf = require 'libraries.breezefield'

local physicsManager = {
    wallColliders = {},
    world = nil,
    playerRadius = 10,
    cloneRadius = 5
}

local debug = {}

function physicsManager:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function physicsManager:load()
    self.world = bf.newWorld()
end

function physicsManager:update(dt)
    self.world:update(dt)
end

function physicsManager:createPlayerCollider(x, y)
    self.playerCollider = self.world:newCollider("circle", {x, y, self.playerRadius})
    self.playerCollider:setFixedRotation(true)
    self.playerCollider:setType('dynamic')
    return self.playerCollider
end

function physicsManager:createCloneCollider(x, y)
    local cloneCollider = self.world:newCollider("circle", {x, y, self.cloneRadius})
    cloneCollider:setFixedRotation(true)
    cloneCollider:setType('dynamic')
    return cloneCollider
end

function physicsManager:createStaticCircleCollider(x, y, r)
    local collider = self.world:newCollider('circle', {x, y, r})
    collider:setFixedRotation(true)
    collider:setType('static')
    return collider
end

function physicsManager:updatePlayerVelocity(vx, vy)
    self.playerCollider:setLinearVelocity(vx, vy)
end

function physicsManager:createPuzzleWall(x, y, width, height)
    local args = {x + width / 2, y - height / 2, width, height}
    local wall = self.world:newCollider('rectangle', args)
    wall:setType('static')
    return wall
end

function physicsManager:createDetectionArea(x, y, width, height)
    local args = {x + width / 2, y + height / 2, width, height}
    local area = self.world:newCollider('rectangle', args)
    area:setType('static')
    area:setSensor(true)
    return area
end

function physicsManager:createTube(x, y, width, height, rotation)
    -- TILED rotates these around bottom left, love2d around center
    local args = {x + width / 2, y - height / 2, width, height}
    local tube = self.world:newCollider('rectangle', args)

    if rotation ~= 0 then
        local rads = math.rad(rotation)

        local renderOffset = math.sqrt((width / 2) ^ 2 + (height / 2) ^ 2)
        local offsetX = (width / 2) * math.cos(rads) - (-height / 2) * math.sin(rads)
        local offsetY = (width / 2) * math.sin(rads) + (-height / 2) * math.cos(rads)

        tube:setAngle(rads)
        tube:setPosition(x + offsetX, y + offsetY)
    end

    tube:setType('static')
    tube:setIdentifier('tube')

    return tube
end

function physicsManager:createWall(x, y, width, height, rotation)
    -- TILED rotates these around top left, love2d around center

    local wall = self.world:newCollider('rectangle', {x, y, width, height})

    if rotation then
        local rads = math.rad(rotation)

        local renderOffset = math.sqrt((width / 2) ^ 2 + (height / 2) ^ 2)
        local offsetX = (width / 2) * math.cos(rads) - (height / 2) * math.sin(rads)
        local offsetY = (width / 2) * math.sin(rads) + (height / 2) * math.cos(rads)

        wall:setAngle(rads)
        wall:setPosition(x + offsetX, y + offsetY)
    end

    wall:setType('static')

    return wall
end

function physicsManager:createBallCollider(args)
    local ball = self.world:newCollider('circle', args)
    ball:setFixedRotation(true)
    return ball
end

function physicsManager.getValidIdentifiers()
    return bf.Collider.getValidIdentifiers()
end

function physicsManager:getWalls()
    return self.wallColliders
end

function physicsManager:getWorld()
    return self.world
end


function physicsManager:drawDebug()
    local y = 110

    if debug then
        for _, message in pairs(debug) do
            love.graphics.print(message, 400, y)
            y = y + 20
        end
    end
end

return physicsManager