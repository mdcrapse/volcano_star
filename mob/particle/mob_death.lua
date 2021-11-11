local Particle = require('mob.particle')
local DeathPoof = require('mob.particle.death_poof')
local Maph = require('maph')
local pi, max, floor = math.pi, math.max, math.floor

local MobDeath = {}
MobDeath.__index = MobDeath
setmetatable(MobDeath, {__index = Particle})

function MobDeath.new(sprite, x, y, angle, xspd, yspd)
    local self = setmetatable(Particle.new(0.5), MobDeath)
    self.sprite = sprite
    self.x = x
    self.y = y
    self.angle = angle or 0
    self.xspd = xspd or 0
    self.yspd = yspd or 0
    self.xscale = 1
    self.yscale = 1
    self.jitter_wait = 0.1
    self.jitter_timer = 0
    self.jitter_dir = 1
    self.jitter_amount = pi / 4
    self.splatted = false

    return self
end

function MobDeath:tick(dt, game)
    Particle.tick(self, dt, game)

    -- jitter
    self.jitter_timer = max(self.jitter_timer - dt, 0)
    if self.jitter_timer <= 0 then
        self.jitter_timer = self.jitter_wait
        self.angle = self.angle + self.jitter_amount * self.jitter_dir
        self.jitter_dir = -self.jitter_dir
    end

    -- splat into walls
    if not self.splatted and
        self:isCollision(game.map, self.x + self.xspd * dt,
                         self.y + self.yspd * dt) then
        self.splatted = true
        self.alive_time = 0.5
        self.jitter_timer = self.alive_time
        self.yscale = 0.5
        self.xscale = 1.5
        if self:isCollision(game.map, self.x + self.xspd * dt, self.y) then
            -- x collision
            self.angle = pi / 2
            self.x = floor(self.x / 16) * 16 + 8 + (8 - 2) *
                         Maph.sign(self.xspd)
        else
            -- assume y collision
            self.angle = 0
            self.y = floor(self.y / 16) * 16 + 8 + (8 - 2) *
                         Maph.sign(self.yspd)
        end
        self.xspd = 0
        self.yspd = 0
    end

    -- friction
    local FRICTION = 300
    self.xspd = Maph.moveToward(self.xspd, 0, FRICTION * dt)
    self.yspd = Maph.moveToward(self.yspd, 0, FRICTION * dt)

    -- move
    self.xspd, self.yspd = self:move(dt, game, self.xspd, self.yspd)
end

function MobDeath:kill(game)
    game.world:addMob(DeathPoof.new(game.assets, self.x, self.y))
end

function MobDeath:draw(game)
    love.graphics.draw(self.sprite or game.assets.sprites.null_item, self.x,
                       self.y, self.angle + pi, self.xscale, self.yscale, 8, 8)
end

return MobDeath
