local Mob = require('mob')
local Maph = require('maph')
local MobDeath = require('mob.particle.mob_death')
local pi, max = math.pi, math.max

local ShellyShell = {}
ShellyShell.__index = ShellyShell
setmetatable(ShellyShell, {__index = Mob})

function ShellyShell.new(assets, x, y, xspd, yspd)
    local self = setmetatable(Mob.new(), ShellyShell)
    self.tags.shelly_shell = true
    self.sprite = assets.sprites.shelly_shell
    self.x = x
    self.y = y
    self.xspd = xspd or 0
    self.yspd = yspd or 0
    --- The number of seconds before the shell can hit the same mob again.
    self.hit_cooldown = 1
    --- The hit cooldown for each mob the shell has hit.
    self.mob_hit_cooldowns = {}
    self.spin_speed = pi * 2
    self.can_hit_timer = 0.25

    return self
end

function ShellyShell:kill(game, attacker)
    self.is_alive = false
    self.xspd, self.yspd = Maph.normalized(self.x - attacker.x,
                                           self.y - attacker.y)
    self.xspd = self.xspd * 200
    self.yspd = self.yspd * 200
    game.world:addMob(MobDeath.new(self.sprite, self.x, self.y, self.angle,
                                   self.xspd, self.yspd))
end

function ShellyShell:tick(dt, game)
    -- bounce off walls
    if self:isCollision(game.map, self.x + self.xspd * dt, self.y) then
        -- x collsion
        self.xspd = -self.xspd
    elseif self:isCollision(game.map, self.x, self.y + self.yspd * dt) then
        -- y collsion
        self.yspd = -self.yspd
    end

    -- move and spin
    self:move(dt, game, self.xspd, self.yspd)
    self.angle = (self.angle + self.spin_speed * dt) % (pi * 2)

    -- hurt enemies
    for mob in pairs(game.world:tagged('enemy')) do
        if not self.mob_hit_cooldowns[mob] and self:isTouching(mob) then
            mob:hurt(game, 100, self)
            self.mob_hit_cooldowns[mob] = self.hit_cooldown
        end
    end

    -- hurt players
    for mob in pairs(game.world:tagged('player')) do
        if not self.mob_hit_cooldowns[mob] and self:isTouching(mob) then
            mob:hurt(game, 100, self)
            -- player has their own hurt cooldown
            -- self.mob_hit_cooldowns[mob] = self.hit_cooldown
        end
    end

    -- bounce off shells
    for mob in pairs(game.world:tagged('shelly_shell')) do
        if mob ~= self and self:isTouching(mob) then
            local dirx, diry = Maph.normalized(self.x - mob.x, self.y - mob.y)
            local speed = Maph.hypot(self.xspd, self.yspd)
            self.xspd = dirx * speed
            self.yspd = diry * speed
            mob.xspd = -dirx * speed
            mob.yspd = -diry * speed
        end
    end

    -- hit cooldowns
    for mob, timer in pairs(self.mob_hit_cooldowns) do
        self.mob_hit_cooldowns[mob] = max(self.mob_hit_cooldowns[mob] - dt, 0)
        if self.mob_hit_cooldowns[mob] <= 0 then
            self.mob_hit_cooldowns[mob] = nil
        end
    end

    --
    self.can_hit_timer = max(self.can_hit_timer - dt, 0)
end

return ShellyShell
