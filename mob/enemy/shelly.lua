local Enemy = require('mob.enemy')
local Maph = require('maph')
local ShellyShell = require('mob.shelly_shell')
local MobDeath = require('mob.particle.mob_death')
local Item = require('mob.item')
local Pack = require('pack')
local atan2, pi, floor, sin, cos, random = math.atan2, math.pi, math.floor,
                                           math.sin, math.cos, love.math.random

local Shelly = {}
Shelly.__index = Shelly
setmetatable(Shelly, {__index = Enemy})

function Shelly.new(assets)
    local self = setmetatable(Enemy.new(), Shelly)
    self.sprite = assets.sprites.shelly_shelled
    self.has_shell = true
    self.shell_speed = 150
    self.hurt_knockback = 200
    --- The number of seconds the Shelly is safe from its own shell.
    self.shell_safe_time = 1.5

    return self
end

function Shelly:hurt(game, damage, attacker)
    if self.has_shell then
        -- drop shell
        self.has_shell = false
        local dir_x, dir_y = Maph.normalized(self.x - attacker.x,
                                             self.y - attacker.y)
        local shell = ShellyShell.new(game.assets, self.x, self.y,
                                      dir_x * self.shell_speed,
                                      dir_y * self.shell_speed)
        shell.mob_hit_cooldowns[self] = self.shell_safe_time
        game.world:addMob(shell)
        self.sprite = game.assets.sprites.shelly

        -- knockback
        self.xspd = self.xspd + dir_x * self.hurt_knockback
        self.yspd = self.yspd + dir_y * self.hurt_knockback
    else
        Enemy.hurt(self, game, damage, attacker)
    end
end

function Shelly:kill(game, attacker)
    Enemy.kill(self, game, attacker)
    game.world:addMob(MobDeath.new(game.assets.sprites.shelly_death, self.x,
                                   self.y, self.angle, self.xspd, self.yspd))

    -- drop loot
    local spawns = random(100)
    if spawns < 50 then
        local item = Item.new(Pack.Slot.new(game.assets.items.copper, 1))
        item.x = self.x
        item.y = self.y
        game.world:addMob(item)
    elseif spawns < 90 then
        local item = Item.new(Pack.Slot.new(game.assets.items.iron, 1))
        item.x = self.x
        item.y = self.y
        game.world:addMob(item)
    else
        local item = Item.new(Pack.Slot.new(game.assets.items.gold, 1))
        item.x = self.x
        item.y = self.y
        game.world:addMob(item)
    end
end

function Shelly:tick(dt, game)
    Enemy.tick(self, dt, game)

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

return Shelly
