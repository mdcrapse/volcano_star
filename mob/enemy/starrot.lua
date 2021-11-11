local Enemy = require('mob.enemy')
local Maph = require('maph')
local MobDeath = require('mob.particle.mob_death')
local Pack = require('pack')
local Item = require('mob.item')
local atan2, pi, floor, sin, cos, max, random = math.atan2, math.pi, math.floor,
                                                math.sin, math.cos, math.max,
                                                love.math.random

local Starrot = {}
Starrot.__index = Starrot
setmetatable(Starrot, {__index = Enemy})

function Starrot.new(assets)
    local self = setmetatable(Enemy.new(), Starrot)
    self.tags.starrot = true
    self.despawn_dist = 6400
    self.sprite = assets.sprites.starrot
    self.hurt_knockback = 200
    self.max_hp = 5000
    self.hp = self.max_hp
    self.attack_damage = 200
    self.acceleration = 100
    self.max_speed = 300
    self.friction = 100
    self.dark_radius = 300
    --- the amount of before the Starrot can attack again
    self.attack_wait = 1
    self.attack_timer = 0

    -- -- The Starrot's state. `idle`, `prep_ram`, `ram`, `prep_shoot`, `shoot`, `explode`.
    -- self.state = 'idle'

    -- self.prep_ram_wait = 2
    -- self.prep_ram_timer = 0

    -- self.ram_wait = 4
    -- self.ram_timer = 0
    -- self.ram_speed = 200

    return self
end

function Starrot:tick(dt, game)
    Enemy.tick(self, dt, game)

    -- self:tickState(dt, game)
    self.attack_timer = max(self.attack_timer - dt, 0)

    -- chase and hurt target
    if self.target then
        local in_x = 0
        local in_y = 0

        in_x, in_y = Maph.normalized(self.target.x - self.x,
                                     self.target.y - self.y)

        -- if self.can_see_target then
        --     -- walk toward target
        --     in_x, in_y = Maph.normalized(self.target.x - self.x,
        --                                  self.target.y - self.y)
        -- else
        --     -- follow target path
        --     local dir = self.target.path:findDir(self.x, self.y)
        --     if dir then
        --         in_x = cos(dir)
        --         in_y = -sin(dir)
        --     end
        -- end

        if in_x == 0 and in_y == 0 then
            self.xspd = Maph.moveToward(self.xspd, 0, self.friction * dt)
            self.yspd = Maph.moveToward(self.yspd, 0, self.friction * dt)
        else
            self.xspd = Maph.moveToward(self.xspd, self.max_speed * in_x,
                                        self.acceleration * dt)
            self.yspd = Maph.moveToward(self.yspd, self.max_speed * in_y,
                                        self.acceleration * dt)
        end

        self.angle = Maph.angle(in_x, in_y)

        self:tickHurtTarget(game)
    end

    self.x = self.x + self.xspd * dt
    self.y = self.y + self.yspd * dt
    -- self.xspd, self.yspd = self:move(dt, game, self.xspd, self.yspd)
end

function Starrot:hurt(game, damage, attacker)
    Enemy.hurt(self, game, damage, attacker)

    if not self.is_angry and self.hp < self.max_hp / 2 then
        self:becomeAngry(game)
    end
end

function Starrot:kill(game, attacker)
    Enemy.kill(self, game, attacker)
    print('You have saved the star fairy from decay!')
    print('Starfairy: "My hero."')
    print("Happy B'day Aaron!")
    print("Enjoy your presents left by the star fairy (under your pillow)")

    -- turn day
    game.time.clock = game.time.DAY_LENGTH / 2 - game.time.SUN_TIME / 2

    -- drop volcano biome star
    for mob in pairs(game.world:tagged('biome')) do
        if mob.item.id == 'volcano_star' then
            local item = Item.new(Pack.Slot.new(mob.item, 1))
            item.x = mob.x
            item.y = mob.y
            game.world:addMob(item)

            mob.is_alive = false
        end
    end

    -- drop loot
    local item = Item.new(Pack.Slot.new(game.assets.items.copper, 60))
    item.x = self.x
    item.y = self.y
    game.world:addMob(item)

    local item = Item.new(Pack.Slot.new(game.assets.items.iron, 45))
    item.x = self.x
    item.y = self.y
    game.world:addMob(item)

    local item = Item.new(Pack.Slot.new(game.assets.items.gold, 30))
    item.x = self.x
    item.y = self.y
    game.world:addMob(item)

    local item = Item.new(Pack.Slot.new(game.assets.items.starbit, 1))
    item.x = self.x
    item.y = self.y
    game.world:addMob(item)

    local item = Item.new(Pack.Slot.new(game.assets.items.glowstone, 1))
    item.x = self.x
    item.y = self.y
    game.world:addMob(item)

    local item = Item.new(Pack.Slot.new(game.assets.items.pumpkin, 5))
    item.x = self.x
    item.y = self.y
    game.world:addMob(item)

    local item = Item.new(Pack.Slot.new(game.assets.items.corn, 8))
    item.x = self.x
    item.y = self.y
    game.world:addMob(item)

    local item = Item.new(Pack.Slot.new(game.assets.items.beet, 10))
    item.x = self.x
    item.y = self.y
    game.world:addMob(item)
end

function Starrot:becomeAngry(game)
    self.is_angry = true
    self.sprite = game.assets.sprites.starrot_angry
    self.hurt_knockback = 10

    self.acceleration = 150
    self.max_speed = 350
    self.friction = 100

    -- turn night
    game.time.clock = 0
end

-- function Starrot:tickState(dt, game)
--     if self.state == 'idle' then

--     elseif self.state == 'prep_ram' then
--         self.prep_ram_timer = max(self.prep_ram_timer - dt, 0)
--         if self.prep_ram_timer <= 0 then self:gotoStateRam() end
--     elseif self.state == 'ram' then
--         self:tickHurtTarget(game)

--         self.ram_timer = max(self.ram_timer - dt, 0)
--         if self.ram_timer <= 0 then self:gotoStateIdle() end
--     end
-- end

-- function Starrot:gotoStateIdle() self.state = 'idle' end

-- function Starrot:gotoStatePrepRam()
--     self.state = 'prep_ram'
--     self.prep_ram_timer = self.prep_ram_wait
-- end

-- function Starrot:gotoStateRam(norm_x, norm_y)
--     self.state = 'ram'
--     self.ram_timer = self.ram_wait
--     self.xspd = norm_x * self.ram_speed
--     self.yspd = norm_y * self.ram_speed
-- end

--- Hurts the target when touching the target.
function Starrot:tickHurtTarget(game)
    if self.attack_timer <= 0 and self:isTouching(self.target) then
        self.attack_timer = self.attack_wait
        self.target:hurt(game, self.attack_damage, self)
    end
end

function Starrot:drawShade(game)
    if self.is_angry then
        local color = {love.graphics.getColor()}
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle('fill', self.x, self.y, self.dark_radius)
        love.graphics.setColor(unpack(color))
    end
end

return Starrot
