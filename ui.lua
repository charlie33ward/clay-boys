local ui = {}

function ui:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function ui:load()
    
end

function ui:update(dt)

end

function ui:draw()

end

return ui