local helium = require 'libraries.helium'
local timer = require 'libraries.timer'

local deathTextFont = love.graphics.newFont('assets/fonts/GravityBold8.ttf', 64)
local restartFont = love.graphics.newFont('assets/fonts/monogram.ttf', 48)



return helium(function(param, view)
    local palette = param.palette
    local backgroundOpacity = 0.6
    
    
    local deathText = {
        x = view.w / 2,
        y = view.h * 0.3,
        opacity = 1,
        text = 'YOU DIED',
        width = 500
    }

    local restartText = {
        x = view.w / 2,
        y = deathText.y + 100,
        opacity = 1,
        text = 'Press \'r\' at any time to restart level',
        width = 400
    }

    return function()
        love.graphics.setColor(palette.background[1], palette.background[2], palette.background[3], backgroundOpacity)
        love.graphics.rectangle('fill', -1, -1, view.w + 5, view.h + 5)

        love.graphics.setColor(palette.red[1], palette.red[2], palette.red[3], deathText.opacity)
        love.graphics.setFont(deathTextFont)
        love.graphics.printf(deathText.text, deathText.x - (deathText.width / 2), deathText.y, deathText.width, 'center')

        love.graphics.setColor(palette.offWhite[1], palette.offWhite[2], palette.offWhite[3], restartText.opacity)
        love.graphics.setFont(restartFont)
        love.graphics.printf(restartText.text, restartText.x - (restartText.width / 2), restartText.y, restartText.width, 'center')
        love.graphics.setColor(1, 1, 1, 1)
    end
end)