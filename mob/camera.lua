local Mob = require('mob')
local Maph = require('maph')
local Cam = require('cam')

local Camera = {}
Camera.__index = Camera
setmetatable(Camera, {__index = Mob})

function Camera.new(owner)
    local self = setmetatable(Mob.new(), Camera)
    self.owner = owner
    self.cam = Cam.new(0, 0, love.graphics.getDimensions())
    self.cam:setScale(4)
    self.follow_speed = 10

    return self
end

function Camera:tick(dt, game)
    Mob.tick(self, dt, game)

    -- move to owner
    if self.owner then
        local speed =
            Maph.distance(self.x, self.y, self.owner.x, self.owner.y) *
                self.follow_speed
        local dir_x, dir_y = Maph.normalized(self.owner.x - self.x,
                                             self.owner.y - self.y)
        self.x = self.x + dir_x * speed * dt
        self.y = self.y + dir_y * speed * dt
    end

    -- tick cam
    self.cam:setPosition(self.x, self.y)
    self.cam:setWorld(0, 0, game.map.width * 16, game.map.height * 16)
    self.cam:setWindow(0, 0, love.graphics.getDimensions())
end

function Camera:draw(game) end

return Camera
