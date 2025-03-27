local helium = require 'libraries.helium'

local mainMenu = require 'scripts.ui-modules.mainMenu'
local levelSelect = require 'scripts.ui-modules.levelSelect'
local deathScreenFactory = require 'scripts.ui-modules.deathScreen'

local mainMenuScene = helium.scene.new(true)
local levelSelectScene = helium.scene.new(true)
local deathScreenScene = helium.scene.new(true)

local debug = {}

local ui = {
    palette = {
        background = {0.051, 0.004, 0.102, 1},
        red = {0.89, 0.212, 0.373},
        green = {0.22, 0.831, 0.498},
        yellow = {0.976, 0.98, 0.361},
        purple = {0.698, 0.376, 0.922},
        offWhite = {0.93, 0.93, 0.93}
    },
    showDeath = false
}

local screenDimensions = {
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight()
}


function ui:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self

    self.mainMenu = mainMenu:new({palette = self.palette})
    self.levelSelect = levelSelect:new({palette = self.palette})

    return manager
end

function ui:load()
    mainMenuScene:activate()
    self.mainMenu:load()
    self.mainMenu:initHeliumFunction()
    self.mainMenuRender = self.mainMenu.heliumFunction({}, screenDimensions.width, screenDimensions.height)
    -- self.mainMenuRender:draw()
    mainMenuScene:deactivate()

    levelSelectScene:activate()
    self.levelSelect:load()
    self.levelSelect:initHeliumFunction()
    self.levelSelectRender = self.levelSelect.heliumFunction({}, screenDimensions.width, screenDimensions.height)
    -- self.levelSelectRender:draw()
    mainMenuScene:deactivate()

    deathScreenScene:activate()
    self.deathScreenRender = deathScreenFactory({palette = self.palette}, screenDimensions.width, screenDimensions.height)
    self.deathScreenRender:draw()
    deathScreenScene:deactivate()
    
    self.currentScene = mainMenuScene
    self.currentScene:activate()
end

function ui:update(dt)
    self.currentScene:update(dt)
    if self.showDeath then
        deathScreenScene:update(dt)
    end
end

function ui:draw()
    self.currentScene:draw()
    if self.showDeath then
        deathScreenScene:draw()
    end

    self:drawDebug()
end

function ui:showDeathScreen()
    deathScreenScene:activate()
    self.showDeath = true
end

function ui:hideDeathScreen()
    deathScreenScene:deactivate()
    self.showDeath = false
end

function ui:drawDebug()
    local y = 50
    if debug then
        for _, message in pairs(debug) do
            love.graphics.print(message, 50, y)
            y = y + 20
        end
    end
end

return ui