local anim8 = require 'libraries.anim8'

local diagonalOffset = math.sqrt(2) / 2
local throwVectors = {
    d = {x = 0, y = 1},
    dl = {x = -1 * diagonalOffset, y = 1 * diagonalOffset},
    l = {x = -1, y = 0},
    ul = {x = -1 * diagonalOffset, y = -1 * diagonalOffset},
    u = {x = 0, y = -1},
    ur = {x = 1 * diagonalOffset, y = -1 * diagonalOffset},
    r = {x = 1, y = 0},
    dr = {x = 1 * diagonalOffset, y = 1 * diagonalOffset}
}

local animTable = {}

local gameParams = {
    walkSpeed = 150
}

local validStates = {
    IDLE = 'idle',
    MOVING = 'moving',
    THROWING = 'throwing'
}

local player = {
    spawnPoint = {x = 10, y = 10},
    x = 10,
    y = 10,
    speed = gameParams.walkSpeed,
    scale = 2,
    vx = 0,
    vy = 0,
    state = validStates.IDLE,
    maxClones = 1,
    currentClones = 0,
    balls = {},
    dir = 'd'
}

function player:new(physicsManager, mapManager)
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    self.physicsManager = physicsManager
    self.mapManager = mapManager
    return manager
end


function player:load()
    self.movementSheet = love.graphics.newImage('assets/sprites/redDude_movement.png')
    self.throwSheet = love.graphics.newImage('assets/sprites/redDude_throwing.png')


    self.grid = anim8.newGrid(16, 16, self.movementSheet:getWidth(), self.movementSheet:getHeight())

    self.animations = {}
    self.animations.down = anim8.newAnimation(self.grid('1-4', 1), 0.2)
    self.animations.downLeft = anim8.newAnimation(self.grid('1-4', 2), 0.2)
    self.animations.left = anim8.newAnimation(self.grid('1-4', 3), 0.2)
    self.animations.upLeft = anim8.newAnimation(self.grid('1-4', 4), 0.2)
    self.animations.up = anim8.newAnimation(self.grid('1-4', 5), 0.2)
    self.animations.upRight = anim8.newAnimation(self.grid('1-4', 6), 0.2)
    self.animations.right = anim8.newAnimation(self.grid('1-4', 7), 0.2)
    self.animations.downRight = anim8.newAnimation(self.grid('1-4', 8), 0.2)

    self.anim = self.animations.down
    self.dir = 'd'
    self.state = validStates.IDLE

    self:loadBall()

    local spawnLayer = self.mapManager:getCurrentMap().layers['spawn-point']
    if spawnLayer then
        for i, obj in pairs(spawnLayer.objects) do
            self.spawnPoint.x = obj.x
            self.spawnPoint.y = obj.y
        end
    end

    self.collider = self.physicsManager:createPlayerCollider(self.spawnPoint.x, self.spawnPoint.y)
end

function player:loadBall()
    self.ball = {}
    self.ball.sheet = love.graphics.newImage('assets/sprites/ball-fizzle.png')
    self.ball.grid = anim8.newGrid(8, 8, self.ball.sheet:getWidth(), self.ball.sheet:getHeight())
    self.ball.anim = anim8.newAnimation(self.ball.grid('1-7', 1), 0.1)
    self.ball.anim:pauseAtStart()
end

function player:update(dt)
    player.prevState = self.state
    self.vx = 0
    self.vy = 0

    if self.state == validStates.THROWING then
        self.speed = gameParams.walkSpeed * .2
    else
        self.state = validStates.IDLE
    end

    if love.keyboard.isDown("w") then
        if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
            self:moveUpLeft()
            -- self.isMoving = true
            self.dir = 'ul'
        elseif love.keyboard.isDown("d") and not love.keyboard.isDown("a") then
            self:moveUpRight()
            -- self.isMoving = true
            self.dir = 'ur'
        else
            self:moveUp()
            -- self.isMoving = true
            self.dir = 'u'
        end
    elseif love.keyboard.isDown("s") then
        if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
            self:moveDownLeft()
            -- self.isMoving = true
            self.dir = 'dl'
        elseif love.keyboard.isDown("d") and not love.keyboard.isDown("a") then
            self:moveDownRight()
            -- self.isMoving = true
            self.dir = 'dr'
        else
            self:moveDown()
            -- self.isMoving = true
            self.dir = 'd'
        end
    elseif love.keyboard.isDown("d") then
        self:moveRight()
        -- self.isMoving = true
        self.dir = 'r'
    elseif love.keyboard.isDown("a") then
        self:moveLeft()
        -- self.isMoving = true
        self.dir = 'l'
    else
        self.state = validStates.IDLE
    end

    self.x = self.collider.getX()
    self.y = self.collider.getY()

    if self.state == validStates.MOVING then
        self.anim:update(dt)
    elseif self.prevState == validStates.MOVING then  -- If we just stopped moving
        self.anim:gotoFrame(1)  -- Go to idle frame
    end

    if self.balls then
        for i, obj in pairs(self.balls) do
            --- update ball anim
        end
    end
    
    self.physicsManager:updatePlayerVelocity(self.vx, self.vy)
end

function player:draw()
    self.anim:draw(self.movementSheet, self.x, self.y, nil, self.scale, self.scale, 8, 8)
    if self.balls then
        --- draw anim on ball
    end
end

function player:getPlayer()
    return self.player
end

local function calculateBallArgs(playerX, playerY, dir, spawnDistance, radius)
    local args = {
        playerX + throwVectors[dir].x * spawnDistance,
        playerY + throwVectors[dir].y * spawnDistance,
        radius
    }

    return args
end

function player:startThrowBall()

end

function player:throwBall()
    if self.currentClones < self.maxClones then
        local ball = {
            spawnDistance = 20,
            radius = 8,
            speed = 120,
            spinSpeed = 10,
            timer = 5,
            anim = self.ball.anim
        }

        ball.collider = self.physicsManager:createBallCollider(calculateBallArgs(self.x, self.y, self.dir, ball.spawnDistance, ball.radius))

        ball.collider:setLinearVelocity(ball.speed * throwVectors[self.dir].x, ball.speed * throwVectors[self.dir].y)

        function ball.collider:enter(other)
            player:destroyBall(ball)
        end

        table.insert(self.balls, ball)
        self.state = validStates.THROWING

    end
end

function player:destroyBall(ball)

end

function player:combine(clone)

end

-- function player:decideAnim()
--     if player.state != validStates.THROWING then
        
--     end
-- end

function player:moveDown()
    self.vy = self.speed
    self.anim = self.animations.down
    self:changeMovementStartFrame(self.anim)
end

function player:moveDownLeft()
    self.vx = self.speed * -1 * diagonalOffset
    self.vy = self.speed * diagonalOffset
    self.anim = self.animations.downLeft
    self:changeMovementStartFrame(self.anim)
end

function player:moveLeft()
    self.vx = self.speed * -1
    self.anim = self.animations.left
    self:changeMovementStartFrame(self.anim)
end

function player:moveUpLeft()
    self.vx = self.speed * -1 * diagonalOffset
    self.vy = self.speed * -1 * diagonalOffset
    self.anim = self.animations.upLeft
    self:changeMovementStartFrame(self.anim)
end

function player:moveUp()
    self.vy = self.speed * -1
    self.anim = self.animations.up
    self:changeMovementStartFrame(self.anim)
end

function player:moveUpRight()
    self.vx = self.speed * diagonalOffset
    self.vy = self.speed * -1 * diagonalOffset
    self.anim = self.animations.upRight
    self:changeMovementStartFrame(self.anim)
end

function player:moveRight()
    self.vx = self.speed
    self.anim = self.animations.right
    self:changeMovementStartFrame(self.anim)
end

function player:moveDownRight()
    self.vx = self.speed * diagonalOffset 
    self.vy = self.speed * diagonalOffset
    self.anim = self.animations.downRight
    self:changeMovementStartFrame(self.anim)
end

--- Because walking animation starts frame 2
function player:changeMovementStartFrame(animation)
    if self.prevState == validStates.IDLE then
        animation:gotoFrame(2)
    end 
    self.state = validStates.MOVING
end


return player