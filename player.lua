anim8 = require 'libraries.anim8'
bf = require 'libraries.breezefield'

--- load: player table, spritesheet animations, collider

local player = {
    x = 400,
    y = 300,
    speed = 150,
    scale = 2,
    spriteSheet = love.graphics.newImage('assets/MC/greenDude_movement.png')
}

function player:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end


function player:load()
    self.grid = anim8.newGrid(16, 16, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

    self.animations = {}
    self.animations.down = anim8.newAnimation(self.grid('1-4', 1), 0.2)
    self.animations.downLeft = anim8.newAnimation(self.grid('1-4', 2), 0.2)
    self.animations.left = anim8.newAnimation(self.grid('1-4', 3), 0.2)
    self.animations.upLeft = anim8.newAnimation(self.grid('1-4', 4), 0.2)
    self.animations.up = anim8.newAnimation(self.grid('1-4', 5), 0.2)
    self.animations.upRight = anim8.newAnimation(self.grid('1-4', 6), 0.2)
    self.animations.right = anim8.newAnimation(self.grid('1-4', 7), 0.2)
    self.animations.downRight = anim8.newAnimation(self.grid('1-4', 8), 0.2)

    player.anim = player.animations.down
    isMoving = false

    
end

function player:update()

end

function player:getPlayer()
    return self.player
end

return player