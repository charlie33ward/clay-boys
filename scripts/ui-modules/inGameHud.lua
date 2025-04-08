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

function inGameHud:load()
    self.cloneIndicatorSheet = love.graphics.newImage('assets/sprites/clone_ui_indicator_sheet.png')
    self.cloneIndicatorGrid = anim8.newGrid(16, 16, self.cloneIndicatorSheet:getWidth(), self.cloneIndicatorSheet:getHeight())
    self.indicatorScale = 2.5

    self.combineAnim = anim8.newAnimation(self.cloneIndicatorGrid('1-11', 1), 0.03)
    self.throwAnim = anim8.newAnimation(self.cloneIndicatorGrid('11-1', 1), 0.03)
    self.animTime = 11 * 0.07
    

    self.indicators = {}
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
        dummyTick.tick = dummyTick.tick + 1
        anims.activeAnim:draw(param.cloneIndicatorSheet, param.x, param.y, nil, scale, scale, 0, 0)
    end
end)

local prevActiveCircle = 0


function inGameHud:update(dt)
    for _, indicator in pairs(self.indicators) do
        indicator.table.activeAnim:update(dt)
    end

    if tick then
        tick = tick + 1
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
    
        debug.indicators = 0
    
        for i = 1, inGameHud.maxClones do
            self.indicators[i] = {}
            local width = view.w
            local height = view.h
    
            self.indicators[i].table = {
                activeAnim = self.throwAnim:clone(),
                x = baseX,
                y = y,
                isFull = true,
                tick = tick,
                cloneIndicatorSheet = self.cloneIndicatorSheet,
                indicatorScale = inGameHud.cloneIndicatorScale
                
                -- playThrowAnim = function(self)
                    
                -- end,
    
                -- playCombineAnim = function(self)
    
                -- end
            }
    
            

            self.indicators[i].component = circleFactory(self.indicators[i].table, width, height)
    
            y = y + vertSpacing
    
            debug.indicators = debug.indicators + 1
        end
    
        if prevActiveCircle > inGameHud.activeCircle then
            -- after throw/spend a clone
    
        elseif prevActiveCircle < inGameHud.activeCircle then
            -- after combine/gain a clone
    
        end

    
        prevActiveCircle = inGameHud.activeCircle
    
        return function()
            for _, indicator in pairs(self.indicators) do
                indicator.component:draw()
            end    

        end
    end)
end

return inGameHud