local helium = require 'libraries.helium'
local timer = require 'libraries.timer'
local useButton = require 'libraries.helium.shell.button'
local useState = require 'libraries.helium.hooks.state'
local useContainer = require 'libraries.helium.layout.container'

-- shader is work in progress, not functioning properly yet
local ditherShader = love.graphics.newShader[[
    extern number progress;  // Value from 0 to 1 to animate the dithering stage
    extern vec2 size;        // The dimensions of the button

    // Define our Bayer functions:
    float Bayer2(vec2 a) {
        a = floor(a);
        return fract(a.x / 2.0 + a.y * a.y * 0.75);
    }

    #define Bayer4(a)   (Bayer2(0.5*(a)) * 0.25 + Bayer2(a))
    #define Bayer8(a)   (Bayer4(0.5*(a)) * 0.25 + Bayer2(a))
    #define Bayer16(a)  (Bayer8(0.5*(a)) * 0.25 + Bayer2(a))
    #define Bayer32(a)  (Bayer16(0.5*(a)) * 0.25 + Bayer2(a))
    #define Bayer64(a)  (Bayer32(0.5*(a)) * 0.25 + Bayer2(a))

    vec4 effect(vec4 color, Image tex, vec2 uv, vec2 screen_coords) {
        // Normalize screen coordinates relative to button size:
        vec2 norm = screen_coords / size;
        
        // Compute a dithering offset from Bayer64.
        // Multiplying by 'progress' lets you animate from no effect (progress=0)
        // to the full dithering stage (progress=1).
        float ditherOffset = progress * (Bayer64(screen_coords * 0.25) - 0.5);
        
        // Apply the dithering offset to the x coordinate.
        norm.x += ditherOffset;
        
        // Use a simple threshold to decide whether a fragment is "on" or "off."
        // In this example, if the modified x coordinate is less than 0.5, we show the desired color;
        // otherwise, we make it transparent (so that any background shows through).
        float mask = norm.x < 0.5 ? 1.0 : 0.0;
        
        // Return the original color with the alpha multiplied by our mask.
        return vec4(color.rgb, color.a * mask);
    }
]]

local solidColorShader = love.graphics.newShader[[
    extern vec3 customColor;
    extern float opacity;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 texColor = Texel(texture, texture_coords);
        if (texColor.a == 0.0) {
            discard;
        }
        return vec4(customColor, opacity * texColor.a);
    }
]]

local mainMenu = {}
local palette = nil
love.graphics.setDefaultFilter('nearest', 'nearest')
local playerImage = love.graphics.newImage('assets/images/redDude_title.png')

function mainMenu:new(objects)
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    palette = objects.palette
    return manager
end

local playButton = nil
local settingsButton = nil
local exitButton = nil

function mainMenu:load()
    playButton = {
        color = palette.green,
        text = 'PLAY'
    }
    settingsButton = {
        color = palette.yellow,
        text = 'CONTROLS'
    }
    exitButton = {
        color = palette.purple,
        text = 'EXIT'
    }  
end

function mainMenu:update(dt)

end

  

local buttonFont = love.graphics.newFont('assets/fonts/monogram.ttf', 48)
local titleFont = love.graphics.newFont('assets/fonts/GravityBold8.ttf', 64)
local titleFontMini = love.graphics.newFont('assets/fonts/GravityBold8.ttf', 57)


local buttonMargin = 10


local screenDimensions = {
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight()
}
local buttonStats = {
    width = math.min(math.floor(screenDimensions.width / 3), 300),
    height = 40,
    rounding = 12
}

local menuButtonFactory = helium(function(param, view)
    local baseColor = param.color
    local baseWidth = view.w - 1
    local baseHeight = view.h - 1
    local scaleShift = 0.10
    
    local button = useState({
        state = 0,
        textColor = baseColor,
        scale = 1,
        width = baseWidth,
        height = baseHeight
    })

    local temp = {
        state = 0,
        enterTimer = nil,
        exitTimer = nil
    }

    local function cancelTimer(timerRef)
        if timerRef then
            timer.cancel(timerRef)
            timerRef = nil
        end
    end
    
    local timerLength = 0.3

    local buttonState = useButton(
        param.onClick,
        nil,
        function()
            cancelTimer(temp.exitTimer)

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
            cancelTimer(temp.enterTimer)

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
        love.graphics.rectangle('fill', 0.5, 0.5, baseWidth, baseHeight, buttonStats.rounding, buttonStats.rounding)

        love.graphics.setColor(baseColor)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle('line', 0.5, 0.5, baseWidth, baseHeight, buttonStats.rounding, buttonStats.rounding) 

        love.graphics.setColor(button.textColor[1], button.textColor[2], button.textColor[3])
        love.graphics.setFont(buttonFont)
        local textW = buttonFont:getWidth(param.text)
        love.graphics.print(param.text, (view.w - textW) / 2, -1)
    end
end)

local imageFactory = helium(function(param, view)
    -- w/h 140px to match buttons
    local scaleX = (view.w - 10) / playerImage:getWidth()
    local scaleY = (view.h - 10) / playerImage:getHeight()

    return function()
        local container = useContainer.new('stretch', 'stretch'):width(view.w):height(view.h)

        love.graphics.setShader(solidColorShader)

        solidColorShader:send("customColor", settingsButton.color)
        solidColorShader:send("opacity", 0.4)
        love.graphics.draw(playerImage, 0, 0, 0, scaleX + 0.1, scaleY + 0.3, -5.5, 5.5)
        solidColorShader:send("customColor", exitButton.color)
        love.graphics.draw(playerImage, 0, 0, 0, scaleX + 0.1, scaleY + 0.3, 0.5, -5.5)
        solidColorShader:send("customColor", playButton.color)
        love.graphics.draw(playerImage, 0, 0, 0, scaleX + 0.1, scaleY + 0.3, 8.5, 5.5)
        
        love.graphics.setShader()

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(playerImage, 0, 0, 0, scaleX, scaleY, 0.5, 0.5)
    end
end)

local titleFactory = helium(function(param, view)

    local textW = titleFont:getWidth(param.text)
    return function()
        local textColor = param.color or {0.93, 0.93, 0.93}
        love.graphics.setColor(textColor[1], textColor[2], textColor[3])
        love.graphics.setFont(param.font)
        love.graphics.printf(param.text, 0, 0, view.w, 'center', 0, 1, 1, param.offset or 0, param.offset or 0)

        love.graphics.setColor(1, 1, 1, 1)
    end
end)

function mainMenu:initHeliumFunction()
    self.heliumFunction = helium(function(param, view)
    
        local centeredPos = (screenDimensions.width - buttonStats.width) / 2
        local yStart = 340
        local xOffset = -80
    
        local play = menuButtonFactory(playButton, buttonStats.width, buttonStats.height)
        local settings = menuButtonFactory(settingsButton, buttonStats.width, buttonStats.height)
        local exit = menuButtonFactory(exitButton, buttonStats.width, buttonStats.height)
    
        local imageX = (screenDimensions.width + buttonStats.width) / 2 + xOffset + 10
        local imageY = yStart
        local playerIcon = imageFactory({}, 140, 140)
    
        local titleWidth = 570
        local titleY = 175
        local title1 = titleFactory({text = 'CLAY GAME', font = titleFontMini, color = {palette.red}}, titleWidth, 100)
        local title2 = titleFactory({text = 'PLAYTEST', font = titleFont}, titleWidth, 100)
    
        return function()
            love.graphics.setColor(palette.background[1], palette.background[2], palette.background[3])
            love.graphics.rectangle('fill', -1, -1, screenDimensions.width + 5, screenDimensions.height + 5)
            love.graphics.setColor(1, 1, 1, 1)
    
            play:draw(centeredPos + xOffset, yStart)
            settings:draw(centeredPos + xOffset, yStart + (buttonStats.height + buttonMargin))
            exit:draw(centeredPos + xOffset, yStart + (buttonStats.height + buttonMargin) * 2)
            playerIcon:draw(imageX, imageY)
            
            title1:draw((screenDimensions.width - titleWidth) / 2, titleY)
            title2:draw((screenDimensions.width - titleWidth) / 2, titleY + 72)
        end
    end)
end

return mainMenu