local Mob = require('mob')
local Maph = require('maph')
local pi = math.pi

--- Represents a projectile that hits mobs.
local Arrow = {}
Arrow.__index = Arrow
setmetatable(Arrow, {__index = Mob})

function Arrow.new(sprite)
    local self = setmetatable(Mob.new(), Arrow)
    self.sprite = sprite
    --- The number of seconds left before the mob disappears.
    self.life_time = 10
    --- The distance at which the arrow hurts the target.
    self.hurt_dist = 16
    --- Then amount of damage the arrow deals to mobs.
    self.damage = 100

    return self
end

function Arrow:tick(dt, game)
    self.x = self.x + self.xspd * dt
    self.y = self.y + self.yspd * dt

    -- update angle
    self.angle = Maph.angle(self.xspd, self.yspd) - pi

    -- hurt target and destroy self
    for mob in pairs(game.world:tagged('enemy')) do
        if self:isTouching(mob) then
            if mob.hurt then
                mob:hurt(game, self.damage, self)
                self.is_alive = false
                return nil
            end
        end
    end

    -- hit darts back
    for mob in pairs(game.world:tagged('darter_dart')) do
        if self:isTouching(mob) then
            mob:hitBack(self, self.angle + pi)
            self.is_alive = false
            return nil
        end
    end

    -- hit shells
    for mob in pairs(game.world:tagged('shelly_shell')) do
        if self:isTouching(mob) and
            mob.can_hit_timer <= 0 then
            mob:kill(game, self)
            self.is_alive = false
            return nil
        end
    end

    -- destroy when hitting walls
    local xx, yy = game.map:posToIdx(self.x, self.y)
    if xx and yy and game.map:isSolid(xx, yy) then
        self.is_alive = false
        return nil
    end

    -- destroy when expired
    self.life_time = self.life_time - dt
    if self.life_time <= 0 then
        self.is_alive = false
        return nil
    end
end

return Arrow
