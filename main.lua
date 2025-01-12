local CameraManager = require 'cameraManager'
local playerCharacter = require 'player'
local physicsManager = require 'physicsManager'
local mapManager = require 'mapManager'

function love.load()
    --- LIBRARIES
    sti = require 'libraries.sti'
    love.graphics.setDefaultFilter('nearest', 'nearest')

    phys = physicsManager:new()
    phys:load()

    map = mapManager:new(phys)
    map:load()

    player = playerCharacter:new(phys, map)
    player:load()

    cam = CameraManager:new()
    cam:load(player.x + 8, player.y + 8)


    
end

function love.update(dt)
    player:update(dt)
    phys:update(dt)

    local currentMap = map:getCurrentMap()
    cam:update(dt, player.x, player.y, currentMap.width, currentMap.height, currentMap.tilewidth)
    
end

function love.draw()
    cam:getCam():attach()
        map:draw()
        phys:getWorld():draw()
        player:draw()

    cam:getCam():detach()
end

function love.keypressed(key, scancode, isrepeat)
    if key == 'space' or key == 'lalt' then
        player:startThrowBall()
    end
end

function love.keyreleased(key, scancode, isrepeat)
    if key == 'space' or key == 'lalt' then
        player:throwBall()
    end
end