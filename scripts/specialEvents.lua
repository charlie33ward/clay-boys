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

function specialEvents:setInGameHud(inGameHud)
    self.inGameHud = inGameHud
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
    timeToWin = 2,
    timePerClone = 0.12
}

local enterTimer = nil
local enterTimerDuring = nil
local exitTimer = nil
local exitTimerDuring = nil

function specialEvents:onEnterVictoryZone(anim)
    self.player:onEnterVictoryZone()
    local clonesAvailable = self.player.maxClones - self.player.currentClones
    
    local event = {
        time = 0
    }

    debug.frame = 1
    debug.clones = 'clones available: ' .. clonesAvailable

    local function nextFrame()
        if victoryZone.frame < 11 then
            debug.frame = debug.frame + 1
            victoryZone.frame = victoryZone.frame + 1

            anim:gotoFrame(victoryZone.frame)
        end
    end

    local function prevFrame()

    end

    enterTimer = timer.tween(timerLength.timeToWin, event, {time = timerLength.timeToWin}, 'linear', function()
        -- executes after timer
        debug.win = 'win'
    end)

    enterTimerDuring = timer.during(timerLength.timeToWin, function()
        if victoryZone.frame == 1 and event.time >= timerLength.timePerClone then
            if clonesAvailable >= 1 then
                nextFrame()
            end
        elseif victoryZone.frame == 2 and event.time >= (timerLength.timePerClone * 2) then
            if clonesAvailable >= 2 then
                nextFrame()
            end
        elseif victoryZone.frame == 3 and event.time >= (timerLength.timePerClone * 3) then
            if clonesAvailable >= 3 then
                nextFrame()
            end
        elseif victoryZone.frame == 4 and event.time >= (timerLength.timePerClone * 4) then
            if clonesAvailable >= 4 then
                nextFrame()
            end
        elseif victoryZone.frame == 5 and event.time >= (timerLength.timePerClone * 5) then
            if clonesAvailable >= 5 then
                nextFrame()
            end
        elseif victoryZone.frame == 6 and event.time >= (timerLength.timePerClone * 6) then
            nextFrame()
        end
        
    end)
end

function specialEvents:onExitVictoryZone(anim)
    self.player:onExitVictoryZone()

    if enterTimer then
        timer.cancel(enterTimer)
        enterTimer = nil
    end
    if enterTimerDuring then
        timer.cancel(enterTimerDuring)
        enterTimerDuring = nil
    end

    self.inGameHud:playAllCombine()

    victoryZone.frame = 1
    anim:gotoFrame(victoryZone.frame)
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