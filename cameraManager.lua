camera = require 'libraries.camera'

local cameraManager = {
    cam = nil,
    cameraZoom = 2.25
}

function cameraManager:new() 
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function cameraManager:load(x, y)
    self.cam = camera.new(x, y, self.cameraZoom)
    self.cam.smoother = camera.smooth.damped(5)
end

function cameraManager:update(dt, x, y, width, height, tileWidth)

    self.cam:lockPosition(x, y, self.cam.smoother)

    local minX = (love.graphics.getWidth() / 2) / self.cameraZoom
    local minY = (love.graphics.getHeight() / 2) / self.cameraZoom

    if self.cam.x < minX then self.cam.x = minX end
    if self.cam.y < minY then self.cam.y = minY end

    --- right/bottom clamps
    local mapW = (width * tileWidth)
    local mapH = (height * tileWidth)

    if self.cam.x > (mapW - minX) then
        self.cam.x = (mapW - minX)
    end
    if self.cam.y > (mapH - minY) then
        self.cam.y = (mapH - minY)
    end

end

function cameraManager:getCam()
    return self.cam
end

return cameraManager