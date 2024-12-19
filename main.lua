function love.load()
    --- LIBRARIES
    camera = require 'libraries.camera'

    anim8 = require 'libraries.anim8'
    love.graphics.setDefaultFilter('nearest', 'nearest')

    sti = require 'libraries.sti'
    gameMap = sti('maps/test-map.lua')
    
    --- PLAYER SPRITE CONFIG
    player = {}
    player.x = 400
    player.y = 300
    player.speed = 125
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

    cameraZoom = 2.25
    cam = camera.new(player.x + 8, player.y + 8, cameraZoom)
    cam.smoother = camera.smooth.damped(5)
end
 
function love.update(dt)
    if love.keyboard.isDown("w") then
        if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
            moveUpLeft(dt)
            isMoving = true
        elseif love.keyboard.isDown("d") and not love.keyboard.isDown("a") then
            moveUpRight(dt)
            isMoving = true
        else
            moveUp(dt)
            isMoving = true
        end
    elseif love.keyboard.isDown("s") then
        if love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
            moveDownLeft(dt)
            isMoving = true
        elseif love.keyboard.isDown("d") and not love.keyboard.isDown("a") then
            moveDownRight(dt)
            isMoving = true
        else
            moveDown(dt)
            isMoving = true
        end
    elseif love.keyboard.isDown("d") then
        moveRight(dt)
        isMoving = true
    elseif love.keyboard.isDown("a") then
        moveLeft(dt)
        isMoving = true
    else
        isMoving = false
    end

    if isMoving == false then
        player.anim:gotoFrame(1)
    end

    player.anim:update(dt)
    cam:lockPosition(player.x, player.y, camera.smoother)

    --- left/top clamps
    local minX = (love.graphics.getWidth() / 2) / cameraZoom
    local minY = (love.graphics.getHeight() / 2) / cameraZoom

    if cam.x < minX then
        cam.x = minX
    end
    if cam.y < minY then
        cam.y = minY
    end

    --- right/bottom clamps
    local mapW = (gameMap.width * gameMap.tilewidth)
    local mapH = (gameMap.height * gameMap.tilewidth)

    if cam.x > (mapW - minX) then
        cam.x = (mapW - minX)
    end
    if cam.y > (mapH - minY) then
        cam.y = (mapH - minY)
    end
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["ground"])
        gameMap:drawLayer(gameMap.layers["ground-details"])
        gameMap:drawLayer(gameMap.layers["paths"])
        gameMap:drawLayer(gameMap.layers["ground-upper"])
        gameMap:drawLayer(gameMap.layers["decorations"])
        gameMap:drawLayer(gameMap.layers["decorations-2"])

        player.anim:draw(player.spriteSheet, player.x, player.y, nil, player.scale, player.scale, 8, 8)
    cam:detach()
    
    -- love.graphics.setBlendMode("alpha")
    -- love.graphics.origin()
    -- love.graphics.setColor(0, 0, 0, 1)
    -- love.graphics.print("Hello", 10, 10)
    -- love.graphics.setColor(1, 1, 1, 1)
end

diagonalOffset = math.sqrt(2) / 2

function moveDown(dt)
    player.y = player.y + (player.speed * dt)
    player.anim = player.animations.down
    changeMovementStartFrame(player.anim)
end

function moveDownLeft(dt)
    player.y = player.y + (player.speed * diagonalOffset * dt)
    player.x = player.x - (player.speed * diagonalOffset * dt)
    player.anim = player.animations.downLeft
    changeMovementStartFrame(player.anim)
end

function moveLeft(dt)
    player.x = player.x - (player.speed * dt)
    player.anim = player.animations.left
    changeMovementStartFrame(player.anim)
end

function moveUpLeft(dt)
    player.y = player.y - (player.speed * diagonalOffset * dt)
    player.x = player.x - (player.speed * diagonalOffset * dt)
    player.anim = player.animations.upLeft
    changeMovementStartFrame(player.anim)
end

function moveUp(dt)
    player.y = player.y - (player.speed * dt)
    player.anim = player.animations.up
    changeMovementStartFrame(player.anim)
end

function moveUpRight(dt)
    player.y = player.y - (player.speed * diagonalOffset * dt)
    player.x = player.x + (player.speed * diagonalOffset * dt)
    player.anim = player.animations.upRight
    changeMovementStartFrame(player.anim)
end

function moveRight(dt)
    player.x = player.x + (player.speed * dt)
    player.anim = player.animations.right
    changeMovementStartFrame(player.anim)
end

function moveDownRight(dt)
    player.y = player.y + (player.speed * diagonalOffset * dt)
    player.x = player.x + (player.speed * diagonalOffset * dt)
    player.anim = player.animations.downRight
    changeMovementStartFrame(player.anim)
end

--- Because walking animation starts frame 2
function changeMovementStartFrame(animation)
    if (isMoving == false) then
        animation:gotoFrame(2)
    end 
end
