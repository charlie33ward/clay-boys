local camera = require 'libraries.camera'

local cameraManager = {
    cam = nil,
    defaultCameraZoom = 2,
    cameraZoom = 2,
    yOffset = 0,
    xOffset = 0
}

local inPuzzle = false
local puzzleCamPosition = {
    x = 0,
    y = 0
}

function cameraManager:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function cameraManager:setPuzzleCam(zoom, x, y)
    self.cameraZoom = zoom
    puzzleCamPosition.x = math.floor(x)
    puzzleCamPosition.y = math.floor(y)
    inPuzzle = true
end

function cameraManager:setDefaultCam()
    self.cameraZoom = self.defaultCameraZoom
    inPuzzle = false
end

function cameraManager:setCameraZoom(zoom)
    self.cameraZoom = zoom
end

function cameraManager:getCameraZoom()
    return self.cameraZoom
end

function cameraManager:load(x, y)
    self.cam = camera.new(x, y, self.cameraZoom)
    self.cam.smoother = camera.smooth.damped(5)

    love.graphics.setDefaultFilter("nearest", "nearest")
end

function cameraManager:update(dt, x, y, width, height, tileWidth)
    if inPuzzle then
        self.cam:lockPosition(puzzleCamPosition.x, puzzleCamPosition.y, camera.smooth.damped(8))
    else
        self.cam.smoother = camera.smooth.damped(5)
        self.cam:lockPosition(x, y, self.cam.smoother)
    end

    local xRound = math.floor(self.cam.x * self.cameraZoom + 0.5) / self.cameraZoom
    local yRound = math.floor(self.cam.y * self.cameraZoom + 0.5) / self.cameraZoom
    self.cam.x = xRound
    self.cam.y = yRound


    local minX = (love.graphics.getWidth() / 2) / self.cameraZoom
    local minY = (love.graphics.getHeight() / 2) / self.cameraZoom


    
    --- MAP SIZE CLAMPS
    if self.cam.x < minX then self.cam.x = minX end
    if self.cam.y < minY then self.cam.y = minY end
    local mapW = (width * tileWidth)
    local mapH = (height * tileWidth)
    if self.cam.x > (mapW - minX) then
        self.cam.x = (mapW - minX)
    end
    if self.cam.y > (mapH - minY) then
        self.cam.y = (mapH - minY)
    end

end

function cameraManager:getX()
    return self.cam.x
end

function cameraManager:getY()
    return self.cam.y
end

function cameraManager:getCam()
    return self.cam
end

return cameraManager