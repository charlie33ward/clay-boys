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
    return self.playerCollider
end

function physicsManager:createCloneCollider(x, y)
    local cloneCollider = self.world:newCollider("circle", {x, y, self.cloneRadius})
    cloneCollider:setFixedRotation(true)
    return cloneCollider
end

function physicsManager:updatePlayerVelocity(vx, vy)
    self.playerCollider:setLinearVelocity(vx, vy)
end

function physicsManager:createPuzzleWall(args)
    local wall = self.world:newCollider('rectangle', args.x, args.y, args.width, args.height)
    wall:setType('static')
    return wall
end

function physicsManager:createWall(x, y, width, height)
    local wall = self.world:newCollider('rectangle', {x, y, width, height})
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