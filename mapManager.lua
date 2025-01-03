sti = require 'libraries.sti'

local mapManager = {

}

function mapManager:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function mapManager:load()
    
end

function mapManager:update()
    
end

return mapManager