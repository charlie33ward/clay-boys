local anim8 = require 'libraries.anim8'

local cloneManager = {
    moveAnims = {},
    activeClones = {},
    cloneScale = 1.25,
    combineHitbox = {}
}

function cloneManager:new(physicsManager)
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    self.physicsManager = physicsManager
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
    self.prevState = self.currentState
end

function cloneManager:draw()
    if self.activeClones then
        for _, clone in pairs(self.activeClones) do
            local x = clone.collider.getX()
            local y = clone.collider.getY()

            self.cloneAnim:draw(self.cloneSheet, x, y, nil, self.cloneScale, self.cloneScale, 8, 8)
        end
    end
end

function cloneManager:newClone(x, y)
    local clone = {}

    clone.collider = self.physicsManager:createCloneCollider(x, y)
    clone.collider:setIdentifier(self.physicsManager.getValidIdentifiers().clone)
    table.insert(self.activeClones, clone)
end

function cloneManager:setValidStates(validStates)
    self.validStates = validStates
end

function cloneManager:getActiveClones()
   return self.activeClones
end

return cloneManager