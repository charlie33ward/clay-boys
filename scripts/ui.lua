local helium = require 'libraries.helium'

local mainMenu = require 'scripts.ui-modules.mainMenu'
local levelSelect = require 'scripts.ui-modules.levelSelect'

local mainMenuScene = helium.scene.new(true)
local levelSelectScene = helium.scene.new(true)

local ui = {
    palette = {
        background = {0.051, 0.004, 0.102, 1},
        red = {0.89, 0.212, 0.373},
        green = {0.22, 0.831, 0.498},
        yellow = {0.976, 0.98, 0.361},
        purple = {0.698, 0.376, 0.922},
        offWhite = {0.93, 0.93, 0.93}
    }
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
    self.mainMenuRender = self.mainMenu.heliumFunction({}, love.graphics.getWidth(), love.graphics.getHeight())
    -- self.mainMenuRender:draw()
    mainMenuScene:deactivate()

    levelSelectScene:activate()
    self.levelSelect:load()
    self.levelSelect:initHeliumFunction()
    self.levelSelectRender = self.levelSelect.heliumFunction({}, love.graphics.getWidth(), love.graphics.getHeight())
    self.levelSelectRender:draw()
    
    self.currentScene = levelSelectScene
    self.currentScene:activate()
end

function ui:update(dt)
    self.currentScene:update(dt)
end

function ui:draw()
    self.currentScene:draw()
end

return ui