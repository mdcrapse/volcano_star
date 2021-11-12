local Enemy = require('mob.enemy')
local Maph = require('maph')
local DarterDart = require('mob.darter_dart')
local MobDeath = require('mob.particle.mob_death')
local Item = require('mob.item')
local Pack = require('pack')
local atan2, pi, floor, max, cos, sin, random = math.atan2, math.pi, math.floor,
                                                math.max, math.cos, math.sin,
                                                love.math.random

local Darter = {}
Darter.__index = Darter
setmetatable(Darter, {__index = Enemy})

function Darter.new(assets)
    local self = setmetatable(Enemy.new(), Darter)
    self.sprite = assets.sprites.darter
    self.hurt_knockback = 200
    self.hp = 100
    self.dart_speed = 150
    self.shoot_wait = 3
    self.shoot_timer = 0
    self.shoot_dist = 128

    return self
end

function Darter:kill(game, attacker)
    Enemy.kill(self, game, attacker)
    game.world:addMob(MobDeath.new(game.assets.sprites.darter_death, self.x,
                                   self.y, self.angle, self.xspd, self.yspd))

    -- drop loot
    local item = Item.new(Pack.Slot.new(game.assets.items.arrow, random(2)))
    item.x = self.x
    item.y = self.y
    game.world:addMob(item)

    if random(3) == 1 then
        local item = Item.new(Pack.Slot.new(game.assets.items.bomb, 1))
        item.x = self.x
        item.y = self.y
        game.world:addMob(item)
    end
end

function Darter:tick(dt, game)
    Enemy.tick(self, dt, game)

    if self.target then
        local target_dist = Maph.distance(self.x, self.y, self.target.x,
                                          self.target.y)

        -- chase target
        local ACCEL = 600
        local MAX_SPD = 50
        local FRICTION = 300

        local in_x = 0
        local in_y = 0

        if target_dist > self.shoot_dist / 2 then
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
        end

        if in_x == 0 and in_y == 0 then
            self.xspd = Maph.moveToward(self.xspd, 0, FRICTION * dt)
            self.yspd = Maph.moveToward(self.yspd, 0, FRICTION * dt)
        else
            self.xspd = Maph.moveToward(self.xspd, MAX_SPD * in_x, ACCEL * dt)
            self.yspd = Maph.moveToward(self.yspd, MAX_SPD * in_y, ACCEL * dt)
        end

        if self.can_see_target then
            self.angle = Maph.angle(self.target.x - self.x,
                                    self.target.y - self.y)

            -- shoot target
            if target_dist < self.shoot_dist then
                self.shoot_timer = max(self.shoot_timer - dt, 0)
                if self.can_see_target and self.shoot_timer <= 0 then
                    self.shoot_timer = self.shoot_wait
                    local dartdirx, dartdiry = sin(self.angle), -cos(self.angle)
                    local dart = DarterDart.new(game.assets.sprites.darter_dart)
                    dart.x = self.x
                    dart.y = self.y
                    dart.xspd = dartdirx * self.dart_speed
                    dart.yspd = dartdiry * self.dart_speed
                    game.world:addMob(dart)
                end
            end
        else
            self.angle = Maph.angle(in_x, in_y)
        end
    end

    self.xspd, self.yspd = self:move(dt, game, self.xspd, self.yspd)
end

return Darter
