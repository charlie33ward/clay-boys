local anim8 = require 'libraries.anim8'
local timer = require 'libraries.timer'
local clone = require 'scripts.cloneManager'
local gameManager = require 'scripts.gameManager'

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

local smoothingFactor = 50
local function lerp(a, b, t)
    return a + (b - a) * t
end

local playerAnims = {
    move = {},
    throw = {}
}

local gameParams = {
    walkSpeed = 150,
    throwLength = 2.5,
    combineDistance = 24,
    playerMass = 5
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
    maxClones = 5,
    currentClones = 0,
    balls = {},
    dir = 'd'
}

local debugMessages = {}
local ballId = 0

function player:new(physicsManager, mapManager)
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    self.physicsManager = physicsManager
    self.mapManager = mapManager
    self.cloneManager = clone:new(physicsManager, self)
    return manager
end


function player:load()
    self.movementSheet = love.graphics.newImage('assets/sprites/redDude_movement.png')
    self.throwSheet = love.graphics.newImage('assets/sprites/redDude_throwing.png')
    self.currentSheet = self.movementSheet


    self.moveGrid = anim8.newGrid(16, 16, self.movementSheet:getWidth(), self.movementSheet:getHeight())
    self.throwGrid = anim8.newGrid(16, 16, self.throwSheet:getWidth(), self.throwSheet:getHeight())

    self:setAnims()

    self.dir = 'd'
    self.anim = playerAnims.move[self.dir]
    self.state = validStates.IDLE

    self:loadBall()
    self.fizzling = {}

    local spawnLayer = self.mapManager:getCurrentMap().layers['spawn-point']
    if spawnLayer then
        for i, obj in pairs(spawnLayer.objects) do
            self.spawnPoint.x = obj.x
            self.spawnPoint.y = obj.y
            break
        end
    end

    self.collider = self.physicsManager:createPlayerCollider(self.spawnPoint.x, self.spawnPoint.y)
    self.collider:setIdentifier(self.physicsManager.getValidIdentifiers().player)
    self.collider:setParent(self)
    self.collider.body:setMass(gameParams.playerMass)

    self.combineSensor = self:addCombineSensor(gameParams.combineDistance)

    self.cloneManager:setValidStates(validStates)
    self.cloneManager:load()
end

function player:reset()
    self.currentClones = 0
    self.collider:setPosition(self.spawnPoint.x, self.spawnPoint.y)
    for _, ball in pairs(self.balls) do
        ball:onReset()
    end
    self.balls = {}
    self.cloneManager:reset()
end

function player:onCombine()
    self.currentClones = self.currentClones - 1
    -- table.insert(debugMessages, )
end


function player:addCombineSensor(radius)
    local combineCollider = self.physicsManager:createBallCollider({self.spawnPoint.x, self.spawnPoint.y, radius})

    combineCollider:getBody():setMass(0)
    combineCollider:setSensor(true)
    local ax, ay = self.collider.getX(), self.collider.getY()
    self.combineJoint = love.physics.newWeldJoint(self.collider:getBody(), combineCollider:getBody(), ax, ay, false)
    combineCollider:setIdentifier('combineSensor')
    combineCollider:setParent(self)

    return combineCollider
 end


function player:loadBall()
    self.ball = {}
    self.ball.sheet = love.graphics.newImage('assets/sprites/ball-fizzle.png')
    self.ball.grid = anim8.newGrid(8, 8, self.ball.sheet:getWidth(), self.ball.sheet:getHeight())
    self.ball.anim = anim8.newAnimation(self.ball.grid('1-8', 1), 0.1)
end

function player:update(dt)
    timer.update(dt)

    self.vx = 0
    self.vy = 0

    if self.state == validStates.THROWING then
        self.speed = gameParams.walkSpeed * .2
    else
        self.speed = gameParams.walkSpeed
    end

    self:handleMovementInput()

    self.x = lerp(self.x, self.collider.getX(), smoothingFactor * dt)
    self.y = lerp(self.y, self.collider.getY(), smoothingFactor * dt)

    local newAnim = self:decideAnim()
    if newAnim ~= self.anim then
        self.anim = newAnim
        if self.state == validStates.MOVING then
            self.anim:gotoFrame(2)
        elseif self.state == validStates.THROWING then
            self.anim:gotoFrame(1)
        end
    end

    self.anim:update(dt)
    if self.state == validStates.IDLE then
        self.anim:gotoFrame(1)
    end

    if self.balls then
        for _, obj in pairs(self.balls) do
            if obj.anim then
                obj.anim:update(dt)
            end
        end
    end

    self.physicsManager:updatePlayerVelocity(self.vx, self.vy)
    self.cloneManager:update(dt, self.vx, self.vy, self.dir, self.state)


    debugMessages.cloneCount = 'clones available: '..tostring(self.currentClones)
end

function player:draw()
    self.anim:draw(self.currentSheet, self.x, self.y, nil, self.scale, self.scale, 8, 8)
    if self.balls then
        for _, ball in pairs(self.balls) do
            if ball.collider then
                local x = ball.collider.getX()
                local y = ball.collider.getY()

                ball.anim:draw(self.ball.sheet, x, y, nil, 2, 2, 4, 4)
            elseif ball.anim then
                ball.anim:draw(self.ball.sheet, ball.endX, ball.endY, nil, 2, 2, 4, 4)
            end
        end
    end

    self.cloneManager:draw()
end

function player:getCurrentSheet()

end

function player:drawDebug()
    local y = 50
    if debugMessages then
        for i, message in pairs(debugMessages) do
            love.graphics.print(message, 50, y)
            y = y + 20
        end
    end

    self.cloneManager:drawDebug()
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

local throwCooldown = 0.5
local canThrow = true
local startedThrow = false

function player:startThrowBall()
    if not canThrow then
        startedThrow = false
        return
    end
    self.state = validStates.THROWING   
    startedThrow = true
end

function player:throwBall()
    if not canThrow or not startedThrow then
        return
    end
    
    if self.currentClones < self.maxClones then
        self.currentClones = self.currentClones + 1
        canThrow = false
        timer.after(throwCooldown, function() canThrow = true end)
        
        local ball = {
            spawnDistance = 20,
            radius = 4,
            speed = 120,
            spinSpeed = 10,
            anim = self.ball.anim:clone(),
            endX = 0,
            endY = 0
        }

        self.anim:gotoFrame(2)
        ball.anim:gotoFrame(1)
        ball.anim:pause()
        ball.id = ballId
        ballId = ballId + 1

        ball.collider = self.physicsManager:createBallCollider(calculateBallArgs(self.x, self.y, self.dir, ball.spawnDistance, ball.radius))
        ball.collider:setIdentifier(self.physicsManager.getValidIdentifiers().ball)
        ball.collider:setLinearVelocity(ball.speed * throwVectors[self.dir].x, ball.speed * throwVectors[self.dir].y)

        function ball.collider:enter(other)
            if other.userData and other.userData.identifier == 'combineSensor' then  
                return
            elseif other.identifier == 'wall' or other.identifier == 'clone' or other.identifier == '' then
                player:destroyBall(ball)
            end
        end

        function ball:onReset()
            timer.cancel(ball.throwTimer)
            if ball.collider then
                ball.collider:destroy()
                ball.collider = nil
                ball = nil
            end
        end

        self.balls[ball.id] = ball
        
        timer.after(0.25, function()
            self.state = validStates.IDLE
        end)
        ball.throwTimer = timer.after(gameParams.throwLength, function()
            if self.balls[ball.id] then
                player:destroyBall(ball)
            end
        end)
    else
        self:failThrow()
    end
end

function player:failThrow()
    self.anim:gotoFrame(2)
    timer.after(0.25, function()
        self.state = validStates.IDLE
    end)
end

function player:destroyBall(ball)
    if ball.collider then

        ball.anim:resume()
        ball.endX = ball.collider.getX()
        ball.endY = ball.collider.getY()

        ball.collider:destroy()
        ball.collider = nil


        timer.after(0, function()
            self.cloneManager:newClone(ball.endX, ball.endY, gameParams.playerMass)
        end)

        local destroyTimer = timer.after(0.5, function()
            if self.balls[ball.id] then
                self.balls[ball.id] = nil
                ball.anim = nil
            end
        end)
        
    end
end

function player:decideAnim()
    if self.state == validStates.THROWING then
        self.currentSheet = self.throwSheet
        return playerAnims.throw[self.dir]
    else
        self.currentSheet = self.movementSheet
        return playerAnims.move[self.dir]
    end
end

function player:decideStateAfterMove()
    if self.state ~= validStates.THROWING then
        self.state = validStates.MOVING
    end
end

function player:moveDown()
    self.vy = self.speed
    self:decideStateAfterMove()
end

function player:moveDownLeft()
    self.vx = self.speed * -1 * diagonalOffset
    self.vy = self.speed * diagonalOffset
    self:decideStateAfterMove()
end

function player:moveLeft()
    self.vx = self.speed * -1
    self:decideStateAfterMove()
end

function player:moveUpLeft()
    self.vx = self.speed * -1 * diagonalOffset
    self.vy = self.speed * -1 * diagonalOffset
    self:decideStateAfterMove()
end

function player:moveUp()
    self.vy = self.speed * -1
    self:decideStateAfterMove()
end

function player:moveUpRight()
    self.vx = self.speed * diagonalOffset
    self.vy = self.speed * -1 * diagonalOffset
    self:decideStateAfterMove()
end

function player:moveRight()
    self.vx = self.speed
    self:decideStateAfterMove()
end

function player:moveDownRight()
    self.vx = self.speed * diagonalOffset 
    self.vy = self.speed * diagonalOffset
    self:decideStateAfterMove()
end

function player:handleMovementInput()
    if love.keyboard.isDown("w") then
        if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
            self:moveUpLeft()
            self.dir = 'ul'
        elseif love.keyboard.isDown("d") and not love.keyboard.isDown("a") then
            self:moveUpRight()
            self.dir = 'ur'
        else
            self:moveUp()
            self.dir = 'u'
        end
    elseif love.keyboard.isDown("s") then
        if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
            self:moveDownLeft()
            self.dir = 'dl'
        elseif love.keyboard.isDown("d") and not love.keyboard.isDown("a") then
            self:moveDownRight()
            self.dir = 'dr'
        else
            self:moveDown()
            self.dir = 'd'
        end
    elseif love.keyboard.isDown("d") then
        self:moveRight()
        self.dir = 'r'
    elseif love.keyboard.isDown("a") then
        self:moveLeft()
        self.dir = 'l'
    else
        if self.state ~= validStates.THROWING then
            self.state = validStates.IDLE
        end
    end
end

function player:setAnims()
    playerAnims.move['d'] = anim8.newAnimation(self.moveGrid('1-4', 1), 0.2)
    playerAnims.move['dl'] = anim8.newAnimation(self.moveGrid('1-4', 2), 0.2)
    playerAnims.move['l'] = anim8.newAnimation(self.moveGrid('1-4', 3), 0.2)
    playerAnims.move['ul'] = anim8.newAnimation(self.moveGrid('1-4', 4), 0.2)
    playerAnims.move['u'] = anim8.newAnimation(self.moveGrid('1-4', 5), 0.2)
    playerAnims.move['ur'] = anim8.newAnimation(self.moveGrid('1-4', 6), 0.2)
    playerAnims.move['r'] = anim8.newAnimation(self.moveGrid('1-4', 7), 0.2)
    playerAnims.move['dr'] = anim8.newAnimation(self.moveGrid('1-4', 8), 0.2)

    playerAnims.throw['d'] = anim8.newAnimation(self.throwGrid('1-2', 1), 10)
    playerAnims.throw['dl'] = anim8.newAnimation(self.throwGrid('1-2', 2), 10)
    playerAnims.throw['l'] = anim8.newAnimation(self.throwGrid('1-2', 3), 10)
    playerAnims.throw['ul'] = anim8.newAnimation(self.throwGrid('1-2', 4), 10)
    playerAnims.throw['u'] = anim8.newAnimation(self.throwGrid('1-2', 5), 10)
    playerAnims.throw['ur'] = anim8.newAnimation(self.throwGrid('1-2', 6), 10)
    playerAnims.throw['r'] = anim8.newAnimation(self.throwGrid('1-2', 7), 10)
    playerAnims.throw['dr'] = anim8.newAnimation(self.throwGrid('1-2', 8), 10)
end

return player