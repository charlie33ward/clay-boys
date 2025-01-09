local CameraManager = require 'cameraManager'
local playerCharacter = require 'player'
local physicsManager = require 'physicsManager'
local mapManager = require 'mapManager'

function love.load()
    --- LIBRARIES
    sti = require 'libraries.sti'
    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    gameCanvas = love.graphics.newCanvas(love.graphics.getWidth() + 1, love.graphics.getHeight() + 1)

    phys = physicsManager:new()
    phys:load()

    player = playerCharacter:new(phys)
    player:load()

    cam = CameraManager:new()
    cam:load(player.x + 8, player.y + 8)

    map = mapManager:new(phys)
    map:load()

    
end

function love.update(dt)
    player:update(dt)
    phys:update(dt)

    local currentMap = map:getCurrentMap()
    cam:update(dt, player.x, player.y, currentMap.width, currentMap.height, currentMap.tilewidth)

    if gameCanvas:getWidth() ~= love.graphics.getWidth() or 
    gameCanvas:getHeight() ~= love.graphics.getHeight() then
        gameCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    end
    
end

function love.draw()
    cam:getCam():attach()
        map:draw()
        phys:getWorld():draw()
        player:draw()

    cam:getCam():detach()
end

function love.keypressed(key, scancode, isrepeat)
    if key == 'f' then
        player:throw()
    end
end