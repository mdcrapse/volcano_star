local Enemy = require('mob.enemy')
local Maph = require('maph')
local MobDeath = require('mob.particle.mob_death')
local Item = require('mob.item')
local Pack = require('pack')
local atan2, pi, floor, sin, cos, random = math.atan2, math.pi, math.floor,
                                           math.sin, math.cos, math.random

local Slime = {}
Slime.__index = Slime
setmetatable(Slime, {__index = Enemy})

function Slime.new(assets)
    local self = setmetatable(Enemy.new(), Slime)
    self.sprite = assets.sprites.slime
    --- The speed at which the slime will die by touching walls.
    self.splat_speed = 60
    self.hurt_knockback = 300
    self.hp = 200

    return self
end

function Slime:kill(game, attacker)
    Enemy.kill(self, game, attacker)
    game.world:addMob(MobDeath.new(game.assets.sprites.slime_death, self.x,
                                   self.y, self.angle, self.xspd, self.yspd))

    -- drop loot
    local spawns = random(300)
    if spawns < 50 then
        local item = Item.new(Pack.Slot.new(game.assets.items.beet, 1))
        item.x = self.x
        item.y = self.y
        game.world:addMob(item)
    elseif spawns < 90 then
        local item = Item.new(Pack.Slot.new(game.assets.items.corn, 1))
        item.x = self.x
        item.y = self.y
        game.world:addMob(item)
    elseif spawns < 100 then
        local item = Item.new(Pack.Slot.new(game.assets.items.pumpkin, 1))
        item.x = self.x
        item.y = self.y
        game.world:addMob(item)
    end
end

function Slime:tick(dt, game)
    Enemy.tick(self, dt, game)

    -- splat into walls
    if Maph.hypot(self.xspd, self.yspd) >= self.splat_speed and
        self:isCollision(game.map, self.x + self.xspd * dt,
                         self.y + self.yspd * dt) then self:kill(game) end

    -- chase and hurt target
    if self.target then
        local ACCEL = 300
        local MAX_SPD = 50
        local FRICTION = 300

        local in_x = 0
        local in_y = 0

        if self.can_see_target then
            -- walk toward target
            in_x, in_y = Maph.normalized(self.target.x - self.x,
                                         self.target.y - self.y)
        else
            -- follow target path
            local dir = self.target.path:findDir(self.x, self.y)
            if dir then
                in_x = cos(dir)
                in_y = -sin(dir)
            end
        end

        if in_x == 0 and in_y == 0 then
            self.xspd = Maph.moveToward(self.xspd, 0, FRICTION * dt)
            self.yspd = Maph.moveToward(self.yspd, 0, FRICTION * dt)
        else
            self.xspd = Maph.moveToward(self.xspd, MAX_SPD * in_x, ACCEL * dt)
            self.yspd = Maph.moveToward(self.yspd, MAX_SPD * in_y, ACCEL * dt)
        end

        self.angle = Maph.angle(in_x, in_y)

        -- hit player
        if self:isTouching(self.target) then
            self.target:hurt(game, 100, self)
        end
    end

    self.xspd, self.yspd = self:move(dt, game, self.xspd, self.yspd)
end

return Slime
