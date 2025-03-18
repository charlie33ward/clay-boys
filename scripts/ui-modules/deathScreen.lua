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
        x = screenDimensions.width / 2,
        y = 240,
        opacity = 1,
        text = 'YOU DIED'
    }

    local restartText = {
        x = screenDimensions.width / 2,
        y = 500,
        opacity = 1,
        text = 'Press \'r\' at any time to restart level',
        width = 400
    }

    return function()
        -- drawing logic
        love.graphics.setColor(palette.background[1], palette.background[2], palette.background[3], backgroundOpacity)
        love.graphics.rectangle('fill', -1, -1, screenDimensions.width + 5, screenDimensions.height + 5)
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setColor(palette.red[1], palette.red[2], palette.red[3], deathText.opacity)
        love.graphics.setFont(deathTextFont)
        love.graphics.printf(deathText.text, deathText.x - (deathText.width / 2), deathText.y, deathText.width, 'center')
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setColor(palette.offWhite[1], palette.offWhite[2], palette.offWhite[3], respawnText.opacity)
        love.graphics.setFont(restartFont)
        love.graphics.printf(deathText.text, deathText.x - (deathText.width / 2), deathText.y, deathText.width, 'center')
        love.graphics.setColor(1, 1, 1, 1)
    end
end)