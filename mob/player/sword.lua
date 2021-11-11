local Mob = require('mob')
local Maph = require('maph')
local draw = love.graphics.draw
local cos, sin, pi, min = math.cos, math.sin, math.pi, math.min

--- The current item the player is swinging. May be any item, not just swords.
local Sword = {}
Sword.__index = Sword
setmetatable(Sword, {__index = Mob})

function Sword.new(item, owner, swing_dir)
    local self = setmetatable(Mob.new(), Sword)
    self.tags.player_item = true
    self.item = item
    self.owner = owner
    --- Every mob that was hit. Mobs are only hurt on first hit.
    self.mobs_hit = {}
    self.swing_dir = swing_dir or 1
    self.use_time = 0
    --- How much damage the weapon inflicts.
    self.damage = 100
    self.start_angle = owner.angle

    return self
end

function Sword:tick(dt, game)
    self.angle = self.start_angle + self.swing_dir *
                     (self.use_time / self.item.use_time * pi - pi / 2)
    -- self.angle =
    -- self.owner.angle + self.swing_dir * (self.use_time / self.item.use_time * pi - pi / 2)
    self.x = self.owner.x + sin(self.angle) * 16
    self.y = self.owner.y - cos(self.angle) * 16

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

function Sword:hurtEnemies(game)
    for enemy in pairs(game.world:tagged('enemy')) do
        if not self.mobs_hit[enemy] and self:isTouching(enemy) then
            enemy:hurt(game, self.damage, self)
            self.mobs_hit[enemy] = true
        end
    end
end

function Sword:draw(game)
    draw(self.item.sprite, self.x, self.y, self.angle, 1, 1, 8, 8)
end

return Sword
