local Mob = require('mob')
local Maph = require('maph')
local DeathPoof = require('mob.particle.death_poof')
local TerrainGeneration = require('terrain_generation')
local Item = require('mob.item')
local Pack = require('pack')
local cos, sin, pi, min, max, random, ceil = math.cos, math.sin, math.pi,
                                             math.min, math.max,
                                             love.math.random, math.ceil

local Bomb = {}
Bomb.__index = Bomb
setmetatable(Bomb, {__index = Mob})

function Bomb.new(item, owner)
    local self = setmetatable(Mob.new(), Bomb)
    self.tags.player_item = true
    self.item = item
    self.sprite = item.sprite
    self.owner = owner
    self.explode_radius = 64
    self.explode_wait = 1
    self.explode_timer = self.explode_wait
    --- How much damage the weapon inflicts.
    self.damage = 300
    self.angle = random() * pi * 2

    return self
end

function Bomb:tick(dt, game)
    -- move
    local FRICTION = 300
    self.xspd = Maph.moveToward(self.xspd, 0, FRICTION * dt)
    self.yspd = Maph.moveToward(self.yspd, 0, FRICTION * dt)
    self.xspd, self.yspd = self:move(dt, game, self.xspd, self.yspd)

    -- explode
    self.explode_timer = max(self.explode_timer - dt, 0)
    if self.explode_timer <= 0 then self:explode(game) end
end

function Bomb:explosionIsTouching(mob)
    return Maph.distance(self.x, self.y, mob.x, mob.y) < self.explode_radius +
               mob:getRadius()
end

function Bomb:explode(game)
    self.is_alive = false
    game.world:addMob(DeathPoof.new(game.assets, self.x, self.y))

    -- destroy tiles
    local xx, yy = game.map:posToIdx(self.x, self.y)
    if xx and yy then
        TerrainGeneration.fillGridCircle(xx, yy, ceil(self.explode_radius / 16),
                                         function(ix, iy)
            if game.map:isInbounds(ix, iy) then
                local wall = game.map:getWall(ix, iy)
                local mob = game.map:getMob(ix, iy)
                if wall then
                    -- break wall
                    local drop = Item.new(Pack.Slot.new(wall, 1))
                    drop.x = ix * 16 - 8
                    drop.y = iy * 16 - 8
                    game.world:addMob(drop)
                    game.map:clearWall(ix, iy)
                elseif mob then
                    -- break mob
                    mob:onMine(self, game)
                end
            end
        end)
    end

    -- hurt enemies
    for mob in pairs(game.world:tagged('enemy')) do
        if self:explosionIsTouching(mob) then
            mob:hurt(game, self.damage, self)
        end
    end

    -- hit darts back
    for mob in pairs(game.world:tagged('darter_dart')) do
        if self:explosionIsTouching(mob) then
            mob:hitBack(self, self.angle)
        end
    end

    -- hit shells
    for mob in pairs(game.world:tagged('shelly_shell')) do
        if self:explosionIsTouching(mob) and mob.can_hit_timer <= 0 then
            mob:kill(game, self)
        end
    end
end

function Bomb:draw(game)
    -- draw item
    local pre_shader = love.graphics.getShader()
    love.graphics.setShader(game.assets.shaders.white)
    game.assets.shaders.white:send('white_scale', min(
                                       1 - self.explode_timer /
                                           self.explode_wait, 1))
    Mob.draw(self, game)
    love.graphics.setShader(pre_shader)

    -- draw explode radius
    local pre_color = {love.graphics.getColor()}
    love.graphics.setColor(1, 0, 0, max(
                               1 - self.explode_timer / self.explode_wait - 0.5))
    love.graphics.circle('line', self.x, self.y, self.explode_radius)
    love.graphics.setColor(unpack(pre_color))
end

return Bomb
