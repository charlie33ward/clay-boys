anim8 = require 'libraries.anim8'

--- load: player table, spritesheet animations, collider

local player = {
    x = 400,
    y = 300,
    speed = 150,
    scale = 2,
    vx = 0,
    vy = 0,
    isMoving = false
}

function player:new(physicsManager)
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    self.physicsManager = physicsManager
    return manager
end


function player:load()
    self.spriteSheet = love.graphics.newImage('assets/MC/greenDude_movement.png')

    self.grid = anim8.newGrid(16, 16, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

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
    self.isMoving = false

    self.collider = self.physicsManager:createPlayerCollider()
end

function player:update(dt)
    self.vx = 0
    self.vy = 0

    if love.keyboard.isDown("w") then
        if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
            self:moveUpLeft()
            self.isMoving = true
        elseif love.keyboard.isDown("d") and not love.keyboard.isDown("a") then
            self:moveUpRight()
            self.isMoving = true
        else
            self:moveUp()
            self.isMoving = true
        end
    elseif love.keyboard.isDown("s") then
        if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
            self:moveDownLeft()
            self.isMoving = true
        elseif love.keyboard.isDown("d") and not love.keyboard.isDown("a") then
            self:moveDownRight()
            self.isMoving = true
        else
            self:moveDown()
            self.isMoving = true
        end
    elseif love.keyboard.isDown("d") then
        self:moveRight()
        self.isMoving = true
    elseif love.keyboard.isDown("a") then
        self:moveLeft()
        self.isMoving = true
    else
        self.isMoving = false
    end

    self.x = self.collider.getX()
    self.y = self.collider.getY()
    self.anim:update(dt)
    
    self.physicsManager:updatePlayerVelocity(self.vx, self.vy)
end

function player:draw()
    self.anim:draw(self.spriteSheet, self.x, self.y, nil, self.scale, self.scale, 8, 8)
end

function player:getPlayer()
    return self.player
end

local diagonalOffset = math.sqrt(2) / 2

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
    if (isMoving == false) then
        animation:gotoFrame(2)
    end 
end


return player