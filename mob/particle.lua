local Mob = require('mob')
local max = math.max

local Particle = {}
Particle.__index = Particle
setmetatable(Particle, {__index = Mob})

function Particle.new(alive_time)
    local self = setmetatable(Mob.new(), Particle)
    self.tags.particle = true
    --- How many seconds the particle is alive for.
    self.alive_time = alive_time or 1

    return self
end

--- Is called when is particle's `alive_time` goes below zero.
function Particle:kill(game) end

function Particle:tick(dt, game)
    self.alive_time = max(self.alive_time - dt, 0)
    if self.alive_time <= 0 then
        self:kill(game)
        self.is_alive = false
    end
end

return Particle
