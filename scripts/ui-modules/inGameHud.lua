local helium = require 'libraries.helium'
local useState = require 'libraries.helium.hooks.state'
local timer = require 'libraries.timer'
local anim8 = require 'libraries.anim8'

local indicatorStates = {
    throwing = 'THROWING',
    combining = 'COMBINING',
    static = 'STATIC'
}
local debug = {}

local inGameHud = {}
local tick = 0
local scale = 2.5

local function getTick()
    return tick
end

function inGameHud:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function inGameHud:load(specialEvents)
    self.specialEvents = specialEvents
    self.specialEvents:setInGameHud(self)

    self.cloneIndicatorSheet = love.graphics.newImage('assets/sprites/clone_ui_indicator_sheet.png')
    self.cloneIndicatorGrid = anim8.newGrid(16, 16, self.cloneIndicatorSheet:getWidth(), self.cloneIndicatorSheet:getHeight())
    self.indicatorScale = 2.5

    local frameLength = 0.04
    self.combineAnim = anim8.newAnimation(self.cloneIndicatorGrid('1-11', 1), frameLength, 'pauseAtEnd')
    self.throwAnim = anim8.newAnimation(self.cloneIndicatorGrid('11-1', 1), frameLength, 'pauseAtEnd')
    self.animTime = 11 * 0.07
    self.activeIndicator = 5
    
    self.indicators = {}
end

function inGameHud:onThrow()
    if self.activeIndicator < 1 then
        return
    end
    self.indicators[self.activeIndicator].table.playThrowAnim()

    self.activeIndicator = self.activeIndicator - 1
end

function inGameHud:playAllCombine(stopIndex)
    local stopIndex = stopIndex or 5

    for i = 1, stopIndex, 1 do
        self.indicators[i].table.playCombineAnim()
    end
end

function inGameHud:onCombine()
    if self.activeIndicator >= 5 then
        return
    end
    self.indicators[self.activeIndicator + 1].table.playCombineAnim()
    self.activeIndicator = self.activeIndicator + 1
end

function inGameHud:onReset()
    if self.activeIndicator < 5 then
        for i = self.activeIndicator, 4, 1 do
            self.indicators[i + 1].table.playCombineAnim()
        end
        self.activeIndicator = 5
    end
end

local circleFactory = helium(function(param, view)
    local anims = useState({
        activeAnim = param.activeAnim,
        isFull = param.isFull
    })

    local dummyTick = useState({
        tick = 0
    })
    
    return function()
        if anims.activeAnim ~= param.activeAnim then
            anims.activeAnim = param.activeAnim
        end

        dummyTick.tick = dummyTick.tick + 1
        anims.activeAnim:draw(param.cloneIndicatorSheet, param.x, param.y, nil, scale, scale, 0, 0)
    end
end)

local prevActiveCircle = 0

function inGameHud:update(dt)
    for i, indicator in pairs(self.indicators) do
        indicator.table.activeAnim:update(dt)
    end

    if tick then
        tick = tick + 1
    end
end


local function drawDebug()
    local y = 70
    if debug then
        for _, message in pairs(debug) do
            love.graphics.print(message, 100, y)
            y = y + 20
        end
    end
end

function inGameHud:initHeliumFunction()
    self.heliumFunction = helium(function(param, view)
        local baseX = 30
        local baseY = 30
        local y = baseY
        local horSpacing = 60
        local vertSpacing = 60
        
        local tickWatcher = useState({
            tick = tick
        })
    
        local inGameHud = useState({
            maxClones = param.maxClones,
            activeCircle = param.maxClones - param.currentClones
        })
    
    
        for i = 1, inGameHud.maxClones do
            local currentIndex = i
            self.indicators[currentIndex] = {}
            local width = view.w
            local height = view.h
    
            self.indicators[currentIndex].animations = {
                throw = self.throwAnim:clone(),
                combine = self.combineAnim:clone()
            }

            self.indicators[currentIndex].table = {
                activeAnim = self.indicators[currentIndex].animations.combine,
                x = baseX,
                y = y,
                isCombining = false,
                tick = tick,
                cloneIndicatorSheet = self.cloneIndicatorSheet,
                indicatorScale = inGameHud.cloneIndicatorScale
            }

            self.indicators[currentIndex].table.playThrowAnim = function()
                self.indicators[currentIndex].table.activeAnim = self.indicators[currentIndex].animations.throw
                self.indicators[currentIndex].table.activeAnim:gotoFrame(1)
                self.indicators[currentIndex].table.activeAnim:resume()
            end
            self.indicators[currentIndex].table.playCombineAnim = function()
                self.indicators[currentIndex].table.activeAnim = self.indicators[currentIndex].animations.combine
                self.indicators[currentIndex].table.activeAnim:gotoFrame(1)
                self.indicators[currentIndex].table.activeAnim:resume()
            end

            self.indicators[currentIndex].component = circleFactory(self.indicators[currentIndex].table, width, height)
    
            y = y + vertSpacing
    
        end
    
    
        return function()
            for _, indicator in pairs(self.indicators) do
                indicator.component:draw()
            end    

            drawDebug()
        end
    end)
end

return inGameHud