local uiManager = require 'ui'

local validGameStates = {
    startScreen = "START-SCREEN",
    playing = "PLAYING",
    paused = "PAUSED"
}

local debug = {}

local gameManager = {
    instance = nil
}

function gameManager.getInstance()
    if not gameManager.instance then
        gameManager.instance = {
            state = validGameStates.playing,
            ui = uiManager:new(),
            player = nil
        }

        setmetatable(gameManager.instance, {__index = gameManager})
    end
    
    return gameManager.instance
end

function gameManager:load()
    self.startScreenImage = love.graphics.newImage('assets/backgrounds/greenBackground.png')
end

function gameManager:update(dt)

end

function gameManager:draw()

end

function gameManager:isPlaying()
    return self.state == validGameStates.playing
end

function gameManager.getValidGameStates()
    return validGameStates
end

function gameManager:setPlayer(player)
    self.player = player
end

function gameManager:loadLevel()

end

function gameManager:restartPuzzle()    
    if self.player then
        self.player:reset()
    end
end

function gameManager:drawDebug()
    local y = 50
    if debug then
        for i, message in pairs(debug) do
            love.graphics.print(message, 50, y)
            y = y + 20
        end
    end
end

return gameManager