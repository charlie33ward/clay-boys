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

    self.exampleAnim = self.throwAnim:clone()
    

    self.indicators = {}
end




local circleFactory = helium(function(param, view)
    local anims = useState({
        activeAnim = param.activeAnim,
        isFull = param.isFull
    })

    
    return function()
        anims.activeAnim:draw(param.cloneIndicatorSheet, param.x, param.y, nil, param.indicatorScale, param.indicatorScale, 0, 0)
    end
end)

local prevActiveCircle = 0


function inGameHud:update(dt)
    for _, indicator in pairs(self.indicators) do
        indicator.param.activeAnim:update(dt)
    end

    if self.tick then
        self.tick.dummy = self.tick.dummy + 1
    end
    self.exampleAnim:update(dt)
end

function inGameHud:initHeliumFunction()
    self.heliumFunction = helium(function(param, view)
        local baseX = 30
        local baseY = 30
        local y = baseY
        local horSpacing = 60
        local vertSpacing = 60
    
        local inGameHud = useState({
            maxClones = param.maxClones,
            activeCircle = param.maxClones - param.currentClones
        })
    
        debug.indicators = 0
    
        for i = 1, inGameHud.maxClones do
            self.indicators[i] = {}
            local width = 100
            local height = 100
    
            self.indicators[i].param = {
                activeAnim = self.throwAnim:clone(),
                x = baseX,
                y = y,
                cloneIndicatorSheet = self.cloneIndicatorSheet,
                cloneIndicatorGrid = self.cloneIndicatorGrid,
                indicatorScale = self.indicatorScale
                
                -- playThrowAnim = function(self)
                    
                -- end,
    
                -- playCombineAnim = function(self)
    
                -- end
            }
    
    
            self.indicators[i].component = circleFactory(self.indicators[i].param, width, height)
    
            y = y + vertSpacing
    
            debug.indicators = debug.indicators + 1
        end
    
        if prevActiveCircle > inGameHud.activeCircle then
            -- after throw/spend a clone
    
        elseif prevActiveCircle < inGameHud.activeCircle then
            -- after combine/gain a clone
    
        end

        self.tick = useState({
            dummy = 0
        })
    
    
        prevActiveCircle = inGameHud.activeCircle
    
        return function()
            for _, indicator in pairs(self.indicators) do
                love.graphics.rectangle('fill', indicator.param.x, indicator.param.y, 16 * self.indicatorScale, 16 * self.indicatorScale)

                indicator.component:draw()
            end
    
            love.graphics.rectangle('fill', 200, 200, 16 * self.indicatorScale, 16 * self.indicatorScale)
            love.graphics.draw(self.cloneIndicatorSheet, 200, 0)

            self.exampleAnim:draw(self.cloneIndicatorSheet, 200, 200, nil, self.indicatorScale, self.indicatorScale, 0, 0)
            love.graphics.printf(debug.indicators .. ' hud elements', 100, 70, 300, 'left')


        end
    end)
end

return inGameHud