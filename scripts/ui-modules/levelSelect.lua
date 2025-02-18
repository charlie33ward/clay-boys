local helium = require 'libraries.helium'
local timer = require 'libraries.timer'
local useButton = require 'libraries.helium.shell.button'
local useState = require 'libraries.helium.hooks.state'
local useContainer = require 'libraries.helium.layout.container'

local levelSelect = {}
local palette = nil

function levelSelect:new(objects)
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    palette = objects.palette
    return manager
end

function levelSelect:load()

end

local levelNumFont = love.graphics.newFont('assets/fonts/GravityBold8.ttf', 48)

local screenDimensions = {
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight()
}

local levelButtonFactory = helium(function(param, view)
    local baseColor = param.color
    local radius = 30

    return function()

    end
end)

local levelsGridFactory = helium(function(param, view)

    return function()

    end
end)

function levelSelect:initHeliumFunction()
    self.heliumFunction = helium(function(param, view)
        
        return function()
            love.graphics.setColor(palette.background[1], palette.background[2], palette.background[3])
            love.graphics.rectangle('fill', -1, -1, screenDimensions.width + 5, screenDimensions.height + 5)
            love.graphics.setColor(1, 1, 1, 1)


        end
    end)
end

return levelSelect