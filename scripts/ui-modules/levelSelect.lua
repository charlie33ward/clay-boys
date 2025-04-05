local helium = require 'libraries.helium'
local timer = require 'libraries.timer'
local useButton = require 'libraries.helium.shell.button'
local useState = require 'libraries.helium.hooks.state'

local useGrid = require 'libraries.helium.layout.grid'
local useContainer = require 'libraries.helium.layout.container'

local levelSelect = {}
local palette = nil
local debug = {}

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
local subPixelOffset = 0.5

function levelSelect:load()
    buttons = {
        lvl1 = {text = 1},
        lvl2 = {text = 2},
        lvl3 = {text = 3},
        lvl4 = {text = 4},
        lvl5 = {text = 5},
        lvl6 = {text = 6},
        lvl7 = {text = 7},
        lvl8 = {text = 8},
        lvl9 = {text = 9},
        lvl10 = {text = 10}
    }
    
end

local levelButtonFactory = helium(function(param, view)
    local centerX, centerY = view.w / 2, view.h / 2
    local baseColor = param.color or palette.green
    local baseRadius = (view.h / 2) - 5
    local scaleShift = 0.1

    local button = useState({
        state = 0,
        textColor = baseColor,
        radius = baseRadius
    })

    local temp = {
        state = 0,
        enterTimer = nil,
        exitTimer = nil
    }

    local function isInsideCircle(x, y)
        local dx, dy = x - centerX, y - centerY
        return (dx * dx + dy * dy) <= (button.radius)
    end

    local function isOutsideCircle(x, y)
        local dx, dy = x - centerX, y - centerY
        return (dx * dx + dy * dy) >= (button.radius - 3) ^ 2
    end

    local timerLength = 0.3

    local buttonState = useButton(
        param.onClick,
        nil,
        function()
            -- local mouseX, mouseY = love.mouse.getPosition()
            -- if isOutsideCircle(mouseX, mouseY) then
            --     debug.outside = 'outside'
            --     return
            -- end

            if temp.exitTimer then   
                timer.cancel(temp.exitTimer)
            end
            temp.exitTimer = nil

            temp.enterTimer = timer.tween(timerLength, temp, {state = 1}, 'out-back', function()
                button.textColor = palette.background
            end)

            timer.during(timerLength, function()
                button.state = temp.state
                button.textColor = {
                    baseColor[1] + ((palette.background[1] - baseColor[1]) * temp.state),
                    baseColor[2] + ((palette.background[2] - baseColor[2]) * temp.state),
                    baseColor[3] + ((palette.background[3] - baseColor[3]) * temp.state)
                }
            end)
        end,
        function()
            
            if temp.enterTimer then
                timer.cancel(temp.enterTimer)
            end
            temp.enterTimer = nil

            temp.exitTimer = timer.tween(timerLength, temp, {state = 0}, 'out-back', function()
                button.textColor = baseColor
            end)

            timer.during(timerLength, function()
                button.state = temp.state
                button.textColor = {
                    baseColor[1] + ((palette.background[1] - baseColor[1]) * temp.state),
                    baseColor[2] + ((palette.background[2] - baseColor[2]) * temp.state),
                    baseColor[3] + ((palette.background[3] - baseColor[3]) * temp.state)
                }
            end)
        end
    )

    return function()
        love.graphics.setColor(baseColor[1], baseColor[2], baseColor[3], button.state)
        love.graphics.circle('fill', view.w / 2, view.h / 2, button.radius)

        love.graphics.setColor(baseColor)
        love.graphics.setLineWidth(2)
        love.graphics.circle('line', view.w / 2, view.h / 2, button.radius)

        if param.text then
            love.graphics.setColor(button.textColor[1], button.textColor[2], button.textColor[3])
            love.graphics.setFont(levelNumFont)
            local textW = levelNumFont:getWidth(param.text)
            local textH = levelNumFont:getHeight(param.text)
            love.graphics.print(param.text, (view.w - textW) / 2 + 3, (view.h - textH) / 2)
        end

        love.graphics.setColor(1, 1, 1, 1)
    end
end)


local levelGridFactory = helium(function(param, view)
    local gridData = {
        width = param.width,
        height = param.height
    }

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

    local sideLength = gridData.width / gridConfig.columns

    local gridContents = {
        button1 = levelButtonFactory(buttons.lvl1, sideLength, sideLength),
        button2 = levelButtonFactory(buttons.lvl2, sideLength, sideLength),
        button3 = levelButtonFactory(buttons.lvl3, sideLength, sideLength),
        button4 = levelButtonFactory(buttons.lvl4, sideLength, sideLength),
        button5 = levelButtonFactory(buttons.lvl5, sideLength, sideLength),
        button6 = levelButtonFactory(buttons.lvl6, sideLength, sideLength),
        button7 = levelButtonFactory(buttons.lvl7, sideLength, sideLength),
        button8 = levelButtonFactory(buttons.lvl8, sideLength, sideLength),
        button9 = levelButtonFactory(buttons.lvl9, sideLength, sideLength),
        button10 = levelButtonFactory(buttons.lvl10, sideLength, sideLength)
    }
    
    
    return function()
        local grid = useGrid.new(gridConfig):width(gridData.width)

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

function levelSelect:update(dt)

end

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

function levelSelect:drawDebug()
    local y = 80

    if debug then
        for _, message in pairs(debug) do
            love.graphics.print(message, 700, y)
            y = y + 20
        end
    end
end

return levelSelect