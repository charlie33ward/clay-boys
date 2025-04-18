local uiManager = require 'scripts.ui'
local specEvents = require 'scripts.specialEvents'
local timer = require 'libraries.timer'

local validGameStates = {
    startScreen = "START-SCREEN",
    playing = "PLAYING",
    paused = "PAUSED",
    dead = "DEAD"
}

local debug = {}

local gameManager = {
    instance = nil,
    mapManager = nil
}


function gameManager.getInstance()
    if not gameManager.instance then
        gameManager.instance = {
            state = validGameStates.playing,
            prevState = validGameStates.playing,
            specialEvents = specEvents:new(),
            player = nil
        }

        setmetatable(gameManager.instance, {__index = gameManager})

        gameManager.instance.ui = uiManager:new(gameManager.instance)
    end
    
    return gameManager.instance
end

local updateCamAfterReset = false
local resetCoords = {
    x = 0,
    y = 0
}

local currTick = 0


function gameManager:setMapManager(mapManager)
    self.mapManager = mapManager
end

function gameManager:getPalette()
    return self.ui.getPalette()
end

function gameManager:onThrow()
    self.ui:onThrow()
end

function gameManager:onCombine()
    self.ui:onCombine()
end

function gameManager:triggerDeathEvent(x, y)
    self.state = validGameStates.dead
    self.ui:showDeathScreen()
    self.specialEvents:onDeathEvent(x, y)
    self.player:onDeath()
end

function gameManager:triggerVictoryEvent()
    debug.victoryEvent = 'victory'
end

function gameManager:chooseLevel(levelName)

end

function gameManager:completedLevel(levelName)

end

function gameManager:load()
    self.specialEvents:load()
    self.ui:load(self.specialEvents)

    self.specialEvents:setGame(self)
end

function gameManager:drawSpecialEvents()
    self.specialEvents:draw()
end

function gameManager:drawSpecialEventsDebug()
    self.specialEvents:drawDebug()
end

function gameManager:update(dt)
    self.ui:update(dt)
    self.specialEvents:update(dt)
    timer.update(dt)
end

function gameManager:draw()
    self.ui:draw()

    self:drawDebug()
end

function gameManager:getSpecialEvents()
    return self.specialEvents
end

function gameManager:getState()
    return self.state
end

function gameManager.getValidGameStates()
    return validGameStates
end

function gameManager:setPlayer(player)
    self.player = player
    self.specialEvents:setPlayer(player)
end

function gameManager:loadLevel()

end

function gameManager:restartPuzzle()
    if self.player then
        self.player:reset()
    end
    self.mapManager:reset()
    self.state = validGameStates.playing
    self.ui:hideDeathScreen()

    self.ui:onReset()
end

function gameManager:drawDebug()
    local y = 50
    if debug then
        for i, message in pairs(debug) do
            love.graphics.print(message, 300, y)
            y = y + 20
        end
    end
end

return gameManager