local bf = require 'libraries.breezefield'

local physicsManager = {
    wallColliders = {},
    world = nil
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
    self.playerCollider = self.world:newCollider("circle", {x, y, 10})
    self.playerCollider:setFixedRotation(true)
    return self.playerCollider
end

function physicsManager:updatePlayerVelocity(vx, vy)
    self.playerCollider:setLinearVelocity(vx, vy)
end

function physicsManager:createWall(x, y, width, height)
    local args = {x, y, width, height}

    local wall = self.world:newCollider('rectangle', args)
    wall:setType('static')
    table.insert(self.wallColliders, wall)
end

function physicsManager:createBallCollider(args)
    local ball = self.world:newCollider('circle', args)

    return ball
end

function physicsManager:destroyBallCollider()

end

function physicsManager:getWalls()
    return self.wallColliders
end

function physicsManager:getWorld()
    return self.world
end

return physicsManager