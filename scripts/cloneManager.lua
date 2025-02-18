local anim8 = require 'libraries.anim8'
local timer = require 'libraries.timer'

local cloneManager = {
    moveAnims = {},
    activeClones = {},
    cloneScale = 1.25,
    combiningClones = {}
}

local cloneID = 0
local debug = {}

function cloneManager:new(physicsManager, player)
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    self.physicsManager = physicsManager
    self.player = player
    return manager
end

function cloneManager:load()
    self.cloneSheet = love.graphics.newImage('assets/sprites/clone_movement.png')
    self.moveGrid = anim8.newGrid(16, 16, self.cloneSheet:getWidth(), self.cloneSheet:getHeight())

    self.moveAnims['d'] = anim8.newAnimation(self.moveGrid('1-4', 1), 0.2)
    self.moveAnims['dl'] = anim8.newAnimation(self.moveGrid('1-4', 2), 0.2)
    self.moveAnims['l'] = anim8.newAnimation(self.moveGrid('1-4', 3), 0.2)
    self.moveAnims['ul'] = anim8.newAnimation(self.moveGrid('1-4', 4), 0.2)
    self.moveAnims['u'] = anim8.newAnimation(self.moveGrid('1-4', 5), 0.2)
    self.moveAnims['ur'] = anim8.newAnimation(self.moveGrid('1-4', 6), 0.2)
    self.moveAnims['r'] = anim8.newAnimation(self.moveGrid('1-4', 7), 0.2)
    self.moveAnims['dr'] = anim8.newAnimation(self.moveGrid('1-4', 8), 0.2)
    self.cloneAnim = self.moveAnims['d']

    self.prevState = self.validStates.IDLE
    self.currentState = self.validStates.IDLE
end

function cloneManager:update(dt, vx, vy, dir, state)
    timer.update(dt)
    self.cloneAnim = self.moveAnims[dir]
    self.cloneAnim:update(dt)

    self.currentState = state
    if self.prevState ~= self.currentState then
        if self.currentState == self.validStates.MOVING then
            self.cloneAnim:gotoFrame(2)
        end
    end
    if self.currentState == self.validStates.IDLE then
        self.cloneAnim:gotoFrame(1)
    end

    if self.activeClones then
        for _, clone in pairs(self.activeClones) do
            clone.collider:setLinearVelocity(vx, vy)
        end
    end
    
    if self.combiningClones then
        for _, clone in pairs(self.combiningClones) do
            if clone.readyToDestroy == true then
                table.removekey(clone.parent.combiningClones, clone.id)
                clone.collider:destroy() 
            else
                clone.collider:setPosition(clone.x, clone.y)
            end
        end
    end
    self.prevState = self.currentState
end

function table.removekey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

function cloneManager:draw()
    if self.activeClones then
        for _, clone in pairs(self.activeClones) do
            local x = clone.collider.getX()
            local y = clone.collider.getY()

            self.cloneAnim:draw(self.cloneSheet, x, y, nil, self.cloneScale, self.cloneScale, 8, 8)
        end
    end
    if self.combiningClones then
        for _, clone in pairs(self.combiningClones) do
            local x = clone.x
            local y = clone.y

            love.graphics.setColor(1, 1, 1, clone.opacity)
            clone.anim:draw(self.cloneSheet, x, y, nil, self.cloneScale, self.cloneScale, 8, 8)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function cloneManager:reset()
    self:destroyAllClones()
end

function cloneManager:destroyAllClones()
    self.activeClones = {}
    self.combiningClones = {}
end

function cloneManager:drawDebug()
    local y = 50

    if debug then
        for _, message in pairs(debug) do
            love.graphics.print(message, 250, y)
            y = y + 20
        end
    end
end

function cloneManager:newClone(x, y, mass)
    local clone = {}
    clone.collider = cloneManager.physicsManager:createCloneCollider(x, y)
    clone.collider:setIdentifier('clone')
    clone.collider:getBody():setMass(mass)
    clone.collider:setParent(clone)

    clone.id = cloneID
    cloneID = cloneID + 1
    clone.mergeTimer = 0.75
    clone.opacity = 1
    clone.parent = self

    function clone.collider:enter(other)
        if other.identifier == 'combineSensor' then
            clone.parent:combine(other, clone)
            table.removekey(clone.parent.activeClones, clone.id)
        end
    end

    self.activeClones[clone.id] = clone
end

function cloneManager:combine(sensor, clone)
    self.player:onCombine()
    
    clone.readyToDestroy = false
    clone.parent.combiningClones[clone.id] = clone
    clone.collider:setSensor(true)
    clone.anim = clone.parent.cloneAnim:clone()
    clone.anim.position = clone.parent.cloneAnim.position
    clone.anim:pause()

    clone.x, clone.y = clone.collider:getX(), clone.collider:getY()
    local parent = sensor:getParent()
    clone.endX, clone.endY = parent.collider.getX(), parent.collider.getY()


    timer.tween(clone.mergeTimer, clone, { opacity = 0, x = clone.endX, y = clone.endY }, 'out-expo',
    function()
        clone.readyToDestroy = true
    end)
end

function cloneManager:setValidStates(validStates)
    self.validStates = validStates
end

function cloneManager:getActiveClones()
   return self.activeClones
end

return cloneManager