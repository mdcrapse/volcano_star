local Mob = require('mob')
local Maph = require('maph')
local DeathPoof = require('mob.particle.death_poof')
local sin, cos, pi = math.sin, math.cos, math.pi

local DarterDart = {}
DarterDart.__index = DarterDart
setmetatable(DarterDart, {__index = Mob})

function DarterDart.new(sprite)
    local self = setmetatable(Mob.new(), DarterDart)
    self.tags.darter_dart = true
    self.sprite = sprite
    --- The number of seconds left before the mob disappears.
    self.life_time = 10
    --- The distance at which the dart hurts enemies.
    self.enemy_hurt_dist = 16
    --- The distance at which the dart hurts players.
    self.player_hurt_dist = 12
    --- Then amount of damage the dart deals to mobs.
    self.damage = 100
    --- Whether or not the dart was hit back.
    --- Is toggled to `true` when the player smacks it.
    self.was_hit = false

    return self
end

function DarterDart:tick(dt, game)
    self.x = self.x + self.xspd * dt
    self.y = self.y + self.yspd * dt

    -- update angle
    self.angle = Maph.angle(self.xspd, self.yspd) - math.pi

    -- hurt players
    for mob in pairs(game.world:tagged('player')) do
        if Maph.distance(self.x, self.y, mob.x, mob.y) < self.player_hurt_dist then
            if mob.hurt then
                mob:hurt(game, self.damage, self)
                game.world:addMob(DeathPoof.new(game.assets, self.x, self.y))
                self.is_alive = false
                return nil
            end
        end
    end

    -- hurt enemies
    if self.was_hit then
        for mob in pairs(game.world:tagged('enemy')) do
            if Maph.distance(self.x, self.y, mob.x, mob.y) <
                self.enemy_hurt_dist then
                if mob.hurt then
                    mob:hurt(game, self.damage, self)
                    game.world:addMob(DeathPoof.new(game.assets, self.x, self.y))
                    self.is_alive = false
                    return nil
                end
            end
        end
    end

    -- destroy when hitting walls
    local xx, yy = game.map:posToIdx(self.x, self.y)
    if xx and yy and game.map:isSolid(xx, yy) then
        game.world:addMob(DeathPoof.new(game.assets, self.x, self.y))
        self.is_alive = false
        return nil
    end

    -- destroy when expired
    self.life_time = self.life_time - dt
    if self.life_time <= 0 then
        game.world:addMob(DeathPoof.new(game.assets, self.x, self.y))
        self.is_alive = false
        return nil
    end
end

function DarterDart:hitBack(other, angle)
    if not self.was_hit then
        local speed = Maph.hypot(self.xspd, self.yspd)
        self.xspd = sin(angle) * speed
        self.yspd = -cos(angle) * speed
        self.was_hit = true
    end
end

return DarterDart
