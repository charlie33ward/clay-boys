local timer = require 'libraries.timer'
local anim8 = require 'libraries.anim8'

local specialEvents = {}
local activeAnims = {}

function specialEvents:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function specialEvents:onDeathEvent(x, y)

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

function specialEvents:update(dt)
    self.explosionAnim:update(dt)
    
    -- if activeAnims then 
    --     for _, animTable in pairs(activeAnims) do
    --         animTable.anim:update(dt)
    --     end
    -- end
end

function specialEvents:draw()
    self.explosionAnim:draw(self.explosionSheet, 300, 300, nil, self.explosionTable.scale, self.explosionTable.scale, self.explosionTable.width / 2, self.explosionTable.height / 2)
end

return specialEvents