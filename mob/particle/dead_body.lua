local Particle = require('mob.particle')
local DeathPoof = require('mob.particle.death_poof')

local DeadBody = {}
DeadBody.__index = DeadBody
setmetatable(DeadBody, {__index = Particle})

function DeadBody.new(sprite, x, y)
    local self = setmetatable(Particle.new(), DeadBody)
    self.sprite = sprite
    self.x = x
    self.y = y
    self.xscale = 1
    self.yscale = 1

    return self
end

function DeadBody:kill(game)
    game.world:addMob(DeathPoof.new(game.assets, self.x, self.y))
end

function DeadBody:draw(game)
    love.graphics.draw(self.sprite or game.assets.sprites.null_item, self.x,
                       self.y, self.angle + math.pi, self.xscale, self.yscale,
                       8, 8)
end

return DeadBody
