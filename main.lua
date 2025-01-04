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

    player = playerCharacter:new(phys)
    player:load()

    map = mapManager:new()
    map:load()
    
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

        player:draw()
        phys:getWorld():draw()
    cam:getCam():detach()

end