local timer = require 'libraries.timer'
local anim8 = require 'libraries.anim8'

local specialEvents = {}
local activeAnims = {}

function specialEvents:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manage
end

function specialEvents:onDeathEvent(x, y)

end

function specialEvents:load()
    -- 150 x 183 frames
    self.explosionSheet = love.graphics.newImage('assets/sprites/explosion-sheet.png')
    self.explosionGrid = anim8.newGrid(16, 16, self.explosionSheet.getWidth(), self.explosionSheet.getHeight())
    self.explosionAnim = anim8.newAnimation(self.explosionGrid('1-69', 1), 0.02)


end

function specialEvents:update(dt)
    if activeAnims then
        for _, animTable in pairs(activeAnims) do
            animTable.anim:update(dt)
        end
    end
end

function specialEvents:draw()

end