local bf = require 'libraries.breezefield'

local physicsManager = {
    wallColliders = {},
    world = nil,
    playerRadius = 10,
    cloneRadius = 5
}

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



function physicsManager:createWall(x, y, width, height, rotation)
    local wall = self.world:newCollider('rectangle', {x, y, width, height})
    wall:setType('static')

    if rotation then
        wall:setAngle(math.rad(rotation))
        wall:setPosition(x - width, y)
    end

    table.insert(self.wallColliders, wall)
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

return physicsManager