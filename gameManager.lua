
gameManager = {
    
}

function gameManager:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function gameManager:load()

end

function gameManager:update()

end

function gameManager:draw()

end

function gameManager:restartPuzzle()

end

