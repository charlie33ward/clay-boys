local timer = require 'libraries.timer'
local anim8 = require 'libraries.anim8'

local specialEvents = {}
local activeAnims = {}
local idCounter = 0
local debug = {}

function specialEvents:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end


function specialEvents:load()
    self.explosionTable = {
        width = 150,
        height = 183,
        frameLength = 0.02,
        scale = 0.8
    }

    self.explosionSheet = love.graphics.newImage('assets/sprites/explosion-sheet.png')
    self.explosionGrid = anim8.newGrid(self.explosionTable.width, self.explosionTable.height, self.explosionSheet:getWidth(), self.explosionSheet:getHeight())
    self.explosionAnim = anim8.newAnimation(self.explosionGrid('1-69', 1), self.explosionTable.frameLength, 'pauseAtEnd')
    
end

function specialEvents:setPlayer(player)
    self.player = player
end

function specialEvents:onDeathEvent(x, y)
    local animation = {
        x = x + 3,
        y = y - 34,
        anim = self.explosionAnim:clone(),
        id = idCounter
    }

    idCounter = idCounter + 1

    table.insert(activeAnims, animation)

    timer.after(1.5, function()
        for i, animTable in pairs(activeAnims) do
            if animTable.id == animation.id then
                table.remove(activeAnims, i)
            end
        end
    end)
end

local victoryZone = {
    frame = 1
}
local timerLength = {
    timeToWin = 1.2
}

local enterTimer = nil
local exitTimer = nil
local interruptTimeLength = 0.0

function specialEvents:onEnterVictoryZone(anim)
    local event = {
        time = 0
    }

    self.player:disableThrows()
    
    enterTimer = timer.tween(timerLength.timeToWin, event, {time = timerLength.timeToWin}, 'linear', function()
        -- executes after timer
    end)

    timer.during(timerLength.timeToWin, function()
        
    end)
end

function specialEvents:onExitVictoryZone(anim)
    self.player:enableThrows()
end

function specialEvents:drawDebug()
    local y = 50

    if debug then
        for _, message in pairs(debug) do
            love.graphics.print(message, 400, y)
            y = y + 20
        end
    end
end

function specialEvents:update(dt)
    self.explosionAnim:update(dt)
    
    if activeAnims then 
        for _, animTable in pairs(activeAnims) do
            animTable.anim:update(dt)
        end
    end
end

function specialEvents:draw()
    if activeAnims then
        for _, animTable in pairs(activeAnims) do
            animTable.anim:draw(self.explosionSheet, animTable.x, animTable.y, nil, self.explosionTable.scale, self.explosionTable.scale, self.explosionTable.width / 2, self.explosionTable.height / 2)
        end
    end
end

return specialEvents