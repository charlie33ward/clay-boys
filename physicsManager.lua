bf = require 'libraries.breezefield'

local physicsManager = {

}

function physicsManager:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function physicsManager:load()
    world = bf.newWorld()
end

function physicsManager:update()
    
end

function physicsManager:createWall()

end

function physicsManager:getWorld()
    return
end

return physicsManager