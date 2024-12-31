local CameraManager = require 'cameraManager'

function love.load()
    --- LIBRARIES
    anim8 = require 'libraries.anim8'
    bf = require 'libraries.breezefield'

    sti = require 'libraries.sti'
    gameMap = sti('maps/test-map.lua')

    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    --- PLAYER SPRITE CONFIG
    player = {}
    player.x = 400
    player.y = 300
    player.speed = 150
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
    isMoving = false

    --- PHYSICS/COLLISION
    world = bf.newWorld()
    player.collider = world:newCollider("rectangle", {350, 100, 20, 32})
    player.collider:setFixedRotation(true)

    wall = world:newCollider("rectangle", {500, 300, 100, 10})
    wall:setType("static")

    
    cam = CameraManager:new()
    cam:load(player.x + 8, player.y + 8)
end

function love.update(dt)
    vx = 0
    vy = 0

    if love.keyboard.isDown("w") then
        if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
            moveUpLeft()
            isMoving = true
        elseif love.keyboard.isDown("d") and not love.keyboard.isDown("a") then
            moveUpRight()
            isMoving = true
        else
            moveUp()
            isMoving = true
        end
    elseif love.keyboard.isDown("s") then
        if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
            moveDownLeft()
            isMoving = true
        elseif love.keyboard.isDown("d") and not love.keyboard.isDown("a") then
            moveDownRight()
            isMoving = true
        else
            moveDown()
            isMoving = true
        end
    elseif love.keyboard.isDown("d") then
        moveRight()
        isMoving = true
    elseif love.keyboard.isDown("a") then
        moveLeft()
        isMoving = true
    else
        isMoving = false
    end

    player.collider:setLinearVelocity(vx, vy)

    if isMoving == false then
        player.anim:gotoFrame(1)
    end

    world:update(dt)
    player.x = player.collider.getX()
    player.y = player.collider.getY()
    player.anim:update(dt)

    cam:update(dt, player.x, player.y, gameMap.width, gameMap.height, gameMap.tilewidth)

end

function love.draw()
    cam:getCam():attach()
        gameMap:drawLayer(gameMap.layers["ground"])
        gameMap:drawLayer(gameMap.layers["ground-details"])
        gameMap:drawLayer(gameMap.layers["paths"])
        gameMap:drawLayer(gameMap.layers["ground-upper"])
        gameMap:drawLayer(gameMap.layers["decorations"])
        gameMap:drawLayer(gameMap.layers["decorations-2"])

        player.anim:draw(player.spriteSheet, player.x, player.y, nil, player.scale, player.scale, 8, 8)
        world:draw()
    cam:getCam():detach()

end

diagonalOffset = math.sqrt(2) / 2

function moveDown()
    vy = player.speed
    player.anim = player.animations.down
    changeMovementStartFrame(player.anim)
end

function moveDownLeft()
    vx = player.speed * -1 * diagonalOffset
    vy = player.speed * diagonalOffset
    player.anim = player.animations.downLeft
    changeMovementStartFrame(player.anim)
end

function moveLeft()
    vx = player.speed * -1
    player.anim = player.animations.left
    changeMovementStartFrame(player.anim)
end

function moveUpLeft()
    vx = player.speed * -1 * diagonalOffset
    vy = player.speed * -1 * diagonalOffset
    player.anim = player.animations.upLeft
    changeMovementStartFrame(player.anim)
end

function moveUp()
    vy = player.speed * -1
    player.anim = player.animations.up
    changeMovementStartFrame(player.anim)
end

function moveUpRight()
    vx = player.speed * diagonalOffset 
    vy = player.speed * -1 * diagonalOffset
    player.anim = player.animations.upRight
    changeMovementStartFrame(player.anim)
end

function moveRight()
    vx = player.speed
    player.anim = player.animations.right
    changeMovementStartFrame(player.anim)
end

function moveDownRight()
    vx = player.speed * diagonalOffset 
    vy = player.speed * diagonalOffset
    player.anim = player.animations.downRight
    changeMovementStartFrame(player.anim)
end

--- Because walking animation starts frame 2
function changeMovementStartFrame(animation)
    if (isMoving == false) then
        animation:gotoFrame(2)
    end 
end
