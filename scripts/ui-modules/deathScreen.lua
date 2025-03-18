local helium = require 'libraries.helium'
local useState = require 'libraries.helium.hooks.state'
local useContainer = require 'libraries.helium.layout.container'
local timer = require 'libraries.timer'

local deathTextFont = love.graphics.newFont('assets/fonts/GravityBold8.ttf', 56)
local restartFont = love.graphics.newFont('assets/fonts/monogram.ttf', 48)

return helium(function(param, view)
    --initialization logic
    local palette = param.pallete
    local backgroundOpacity = 0.4
    local screenDimensions = {
        width = love.graphics.getWidth(),
        height = love.graphics.getHeight()
    }
    
    local deathText = {
        x = screenDimensions.width // 2,
        y = 240,
        text = 'YOU DIED'
    }

    local respawnText = {
        x = screenDimensions.width // 2,
        y = 500,
        text = 'Press \'r\' to restart level'
    }

    return function()
        -- drawing logic
        love.graphics.setColor(palette.background[1], palette.background[2], palette.background[3], backgroundOpacity)
        love.graphics.rectangle('fill', -1, -1, screenDimensions.width + 5, screenDimensions.height + 5)
        love.graphics.setColor(1, 1, 1, 1)


    end
end)