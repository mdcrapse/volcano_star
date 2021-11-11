local Mob = require('mob')
local Maph = require('maph')
local draw = love.graphics.draw
local cos, sin, pi, min = math.cos, math.sin, math.pi, math.min

local Spear = {}
Spear.__index = Spear
setmetatable(Spear, {__index = Mob})

function Spear.new(item, owner)
    local self = setmetatable(Mob.new(), Spear)
    self.tags.player_item = true
    self.item = item
    self.owner = owner
    --- Every mob that was hit. Mobs are only hurt on first hit.
    self.mobs_hit = {}
    self.use_time = 0
    --- The distance the spear can reach from the player.
    self.reach = 32
    --- The current distance from the player.
    self.dist = 0
    --- How much damage the weapon inflicts.
    self.damage = 100

    return self
end

function Spear:tick(dt, game)
    self.angle = self.owner.angle
    self.x = self.owner.x + sin(self.angle) * self.dist
    self.y = self.owner.y - cos(self.angle) * self.dist
    self.dist = self.reach *
                    ((cos(self.use_time / self.item.use_time * pi * 2 - pi) + 1) /
                        2)

    self.use_time = min(self.use_time + dt, self.item.use_time)
    if self.use_time >= self.item.use_time then self.is_alive = false end

    self:hurtEnemies(game)

    -- hit darts back
    for mob in pairs(game.world:tagged('darter_dart')) do
        if self:isTouching(mob) then mob:hitBack(self, self.angle) end
    end

    -- hit shells
    for mob in pairs(game.world:tagged('shelly_shell')) do
        if self:isTouching(mob) and mob.can_hit_timer <= 0 then
            mob:kill(game, self)
        end
    end
end

function Spear:hurtEnemies(game)
    for enemy in pairs(game.world:tagged('enemy')) do
        if not self.mobs_hit[enemy] and self:isTouching(enemy) then
            enemy:hurt(game, self.damage, self)
            self.mobs_hit[enemy] = true
        end
    end
end

function Spear:draw(game)
    draw(self.item.sprite, self.x, self.y, self.angle, 1, 1, 8, 8)
end

return Spear
