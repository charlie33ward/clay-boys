local helium = require 'libraries.helium'
local timer = require 'libraries.timer'
local useButton = require 'libraries.helium.shell.button'
local useState = require 'libraries.helium.hooks.state'

local useGrid = require 'libraries.helium.layout.grid'
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

local levelNumFont = love.graphics.newFont('assets/fonts/GravityBold8.ttf', 48)

local screenDimensions = {
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight()
}

local buttons = nil
local buttonSpacing = 10
local gridColumns = 5

function levelSelect:load()
    buttons = {
        lvl1 = {},
        lvl2 = {},
        lvl3 = {},
        lvl4 = {},
        lvl5 = {},
        lvl6 = {},
        lvl7 = {},
        lvl8 = {},
        lvl9 = {},
        lvl10 = {}
    }
    
end

local levelButtonFactory = helium(function(param, view)
    local baseColor = param.color or palette.green
    local radius = (view.h / 2) - 10

    return function()
        local container = useContainer.new('center', 'center'):width(view.w):height(view.h)

        love.graphics.setColor(baseColor[1], baseColor[2], baseColor[3], 1)
        love.graphics.circle('fill', view.w / 2, view.h / 2, radius)
        love.graphics.setColor(1, 1, 1, 1)
    end
end)

local levelGridFactory = helium(function(param, view)
    local gridData = {
        width = param.width,
        height = param.height,
        xStart = 200,
        yStart = 200
    }

    return function()
        -- -@class GridConfig
        -- -@field layout GridLayout|nil @preconfigured layout table
        -- -@field rows HGridRow|number|nil @set these instead of layout if you just want a regularly spaced 'table'
        -- -@field columns WGridCol|number|nil @set these instead of layout if you just want a regularly spaced 'table' leave empty to flow in as many elements as you have
        -- -@field verticalStretchMode "'stretch'"|"'normal'" 
        -- -@field horizontalStretchMode "'stretch'"|"'normal'"
        -- -@field horizontalAlignMode "'left'"|"'center'"|"'right'"
        -- -@field verticalAlignMode "'top'"|"'center'"|"'bottom'"
        -- -@field rowSpacing number @size in pixels to space the rows
        -- -@field colSpacing number @size in pixels to space the columns
        -- -@field rowSizeMode "'relative'"|"'absolute'" 
        -- -@field colSizeMode "'relative'"|"'absolute'"
        
        ---@type GridConfig
        local gridConfig = {
            colSpacing = buttonSpacing,
            rowSpacing = buttonSpacing,
            verticalStretchMode = 'stretch',
            horizontalStretchMode = 'stretch',
            verticalAlignMode = 'center',
            horizontalAlignMode = 'center',
            columns = gridColumns
        }

        local grid = useGrid.new(gridConfig):width(gridData.width) --:height(gridData.height)

        local sideLength = gridData.width / gridConfig.columns

        local gridContents = {
            button1 = levelButtonFactory(buttons.lvl1, sideLength, sideLength),
            button2 = levelButtonFactory(buttons.lvl1, sideLength, sideLength),
            button3 = levelButtonFactory(buttons.lvl1, sideLength, sideLength),
            button4 = levelButtonFactory(buttons.lvl1, sideLength, sideLength),
            button5 = levelButtonFactory(buttons.lvl1, sideLength, sideLength),
            button6 = levelButtonFactory(buttons.lvl1, sideLength, sideLength),
            button7 = levelButtonFactory(buttons.lvl1, sideLength, sideLength),
            button8 = levelButtonFactory(buttons.lvl1, sideLength, sideLength),
            button9 = levelButtonFactory(buttons.lvl1, sideLength, sideLength),
            button10 = levelButtonFactory(buttons.lvl1, sideLength, sideLength)
        }

        gridContents.button1:draw()
        gridContents.button2:draw()
        gridContents.button3:draw()
        gridContents.button4:draw()
        gridContents.button5:draw()
        gridContents.button6:draw()
        gridContents.button7:draw()
        gridContents.button8:draw()
        gridContents.button9:draw()
        gridContents.button10:draw()

        grid:draw(0, 0, gridData.width, gridData.height, gridContents)
    end
end)

function levelSelect:initHeliumFunction()
    self.heliumFunction = helium(function(param, view)
        
        local gridParams = {
            width = 600,
            height = 300
        }

        local x = (screenDimensions.width - (buttonSpacing * (gridColumns - 1) + gridParams.width + 2)) / 2
        local y = 220

        local levelGrid = levelGridFactory(gridParams, view.w, view.h)

        return function()
            love.graphics.setColor(palette.background[1], palette.background[2], palette.background[3])
            love.graphics.rectangle('fill', -1, -1, screenDimensions.width + 5, screenDimensions.height + 5)
            love.graphics.setColor(1, 1, 1, 1)

            levelGrid:draw(x, y)
        end
    end)
end

return levelSelect