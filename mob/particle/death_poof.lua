local Particle = require('mob.particle')
local floor = math.floor
local newQuad = love.graphics.newQuad

local DeathPoof = {}
DeathPoof.__index = DeathPoof
setmetatable(DeathPoof, {__index = Particle})

DeathPoof.ANIMATION = {
    ---@diagnostic disable-next-line: redundant-parameter
    newQuad(0, 0, 16, 16, 64, 16), newQuad(16, 0, 16, 16, 64, 16),
    ---@diagnostic disable-next-line: redundant-parameter
    newQuad(32, 0, 16, 16, 64, 16), newQuad(48, 0, 16, 16, 64, 16)
}

function DeathPoof.new(assets, x, y)
    local self = setmetatable(Particle.new(0.5), DeathPoof)
    self.x = x
    self.y = y
    self.sprite = assets.sprites.death_poof
    self.frame = 0
    self.num_frames = 4
    self.anim_time = self.alive_time

    return self
end

function DeathPoof:tick(dt, game)
    Particle.tick(self, dt, game)
    self.frame = (self.frame + dt / self.anim_time * self.num_frames) %
                     self.num_frames
end

function DeathPoof:draw(game)
    love.graphics.draw(self.sprite, DeathPoof.ANIMATION[floor(self.frame) + 1],
                       self.x - 8, self.y - 8)
end

return DeathPoof
