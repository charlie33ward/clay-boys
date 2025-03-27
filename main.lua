local cameraManager = require 'scripts.cameraManager'
local playerCharacter = require 'scripts.player'
local physicsManager = require 'scripts.physicsManager'
local mapManager = require 'scripts.mapManager'
local gameManager = require 'scripts.gameManager'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    game = gameManager.getInstance()
    game:load()

    phys = physicsManager:new()
    phys:load()

    map = mapManager:new(phys)
    map:load()

    player = playerCharacter:new(phys, map)
    player:load()

    game:setPlayer(player)

    cam = cameraManager:new()
    cam:load(player.x + 8, player.y + 8)
    mapManager:setCam(cam)

end

function love.update(dt)
    if game:isPlaying() then
        player:update(dt)
        phys:update(dt)

        local currentMap = map:getCurrentMap()
        cam:update(dt, player.x, player.y, currentMap.width, currentMap.height, currentMap.tilewidth)

        map:update(dt)
    end

    game:update(dt)
end

function love.draw()
    if game:isPlaying() then
        cam:getCam():attach()
            map:draw()
            -- phys:getWorld():draw()
            player:draw()
            game:drawSpecialEvents()
        cam:getCam():detach()

        -- map:getCurrentMap():drawDebug()
        player:drawDebug()
        map:drawDebug()
        
    end

    game:draw()
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 700, 50)
end

function love.keypressed(key, scancode, isrepeat)
    if key == 'space' or key == 'lalt' then
        player:startThrowBall()
    end
    if key == 'escape' then
        game:onPauseButton()
    end
    if key == 'r' then
        game:restartPuzzle()
    end
    if key == 't' then
        game:triggerDeathEvent()
    end
end

function love.keyreleased(key, scancode, isrepeat)
    if key == 'space' or key == 'lalt' then
        player:throwBall()
    end
end