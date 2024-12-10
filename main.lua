function love.load()
    anim8 = require 'libraries.anim8'
    love.graphics.setDefaultFilter('nearest', 'nearest')

    sti = require 'libraries.sti'
    gameMap = sti('maps/test-map.lua')
    
    player = {}
    player.x = 400
    player.y = 300
    player.speed = 5
    player.scale = 2
    player.spriteSheet = love.graphics.newImage('assets/MC/greenDude_movement.png')
    player.grid = anim8.newGrid(16, 16, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.downLeft = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.upLeft = anim8.newAnimation(player.grid('1-4', 4), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 5), 0.2)
    player.animations.upRight = anim8.newAnimation(player.grid('1-4', 6), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 7), 0.2)
    player.animations.downRight = anim8.newAnimation(player.grid('1-4', 8), 0.2)

    player.anim = player.animations.down
    
    background = love.graphics.newImage('assets/backgrounds/redBackground.png')
end
 
function love.update(dt)
    local isMoving = false

    if love.keyboard.isDown("w") then
        isMoving = true
        if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
            moveUpLeft()
        elseif love.keyboard.isDown("d") and not love.keyboard.isDown("a") then
            moveUpRight()
        else
            moveUp()
        end
    elseif love.keyboard.isDown("s") then
        isMoving = true
        if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
            moveDownLeft()
        elseif love.keyboard.isDown("d") and not love.keyboard.isDown("a") then
            moveDownRight()
        else
            moveDown()
        end
    elseif love.keyboard.isDown("d") then
        isMoving = true
        moveRight()
    elseif love.keyboard.isDown("a") then
        isMoving = true
        moveLeft()
    end

    if isMoving == false then
        player.anim:gotoFrame(1)
    end


    player.anim:update(dt)
end

function love.draw()
    gameMap:draw()
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, player.scale)
    
end

diagonalOffset = math.sqrt(2) / 2

function moveDown()
    player.y = player.y + player.speed
    player.anim = player.animations.down
end

function moveDownLeft()
    player.y = player.y + (player.speed * diagonalOffset)
    player.x = player.x - (player.speed * diagonalOffset)
    player.anim = player.animations.downLeft
end

function moveLeft()
    player.x = player.x - player.speed
    player.anim = player.animations.left
end

function moveUpLeft()
    player.y = player.y - (player.speed * diagonalOffset)
    player.x = player.x - (player.speed * diagonalOffset)
    player.anim = player.animations.upLeft
end

function moveUp()
    player.y = player.y - player.speed
    player.anim = player.animations.up
end

function moveUpRight()
    player.y = player.y - (player.speed * diagonalOffset)
    player.x = player.x + (player.speed * diagonalOffset)
    player.anim = player.animations.upRight
end

function moveRight()
    player.x = player.x + player.speed
    player.anim = player.animations.right
end

function moveDownRight()
    player.y = player.y + (player.speed * diagonalOffset)
    player.x = player.x + (player.speed * diagonalOffset)
    player.anim = player.animations.downRight
end