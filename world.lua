local Mob = require('mob')
local Maph = require('maph')

--- Contains all of the `Mob`s.
local World = {}
World.__index = World

function World.new()
    return setmetatable({mobs = {}, tags = {}, next_id = 1}, World)
end

function World:tick(dt, game)
    for mob in pairs(self.mobs) do mob:tick(dt, game) end
    self:clean()
    -- entity shoving
    local shovers = self:tagged('shove')
    for mob in pairs(shovers) do
        for other in pairs(shovers) do
            if other ~= mob then
                local dist = Maph.distance(mob.x, mob.y, other.x, other.y)
                if Maph.distance(mob.x, mob.y, other.x, other.y) <
                    mob:getRadius() + other:getRadius() - 4 then
                    -- TODO: don't use magic numbers for push distance
                    local push_dist = 16 -- (16 - dist) / 2
                    mob:move(dt, game, (mob.x - other.x) / dist * push_dist,
                             (mob.y - other.y) / dist * push_dist)
                    other:move(dt, game, (other.x - mob.x) / dist * push_dist,
                               (other.y - mob.y) / dist * push_dist)
                end
            end
        end
    end
end

function World:draw(game)
    for mob in pairs(self:tagged('biome')) do
        love.graphics.circle('line', mob.x, mob.y, mob.item.biome.radius)
    end
    for mob in pairs(self:tagged('cell')) do mob:draw(game) end
    for mob in pairs(self:tagged('item')) do mob:draw(game) end
    for mob in pairs(self:tagged('particle')) do mob:draw(game) end
    for mob in pairs(self.mobs) do
        -- HACK: don't check every mob for tags
        if not mob.tags.cell and not mob.tags.enemy and not mob.tags.player and
            not mob.tags.player_item and not mob.tags.item and
            not mob.tags.particle and not mob.tags.shelly_shell and
            not mob.tags.tree and not mob.tags.starrot then
            mob:draw(game)
        end
    end
    for mob in pairs(self:tagged('enemy')) do mob:draw(game) end
    for mob in pairs(self:tagged('shelly_shell')) do mob:draw(game) end
    for mob in pairs(self:tagged('player_item')) do mob:draw(game) end
    for mob in pairs(self:tagged('player')) do mob:draw(game) end
    for mob in pairs(self:tagged('starrot')) do mob:draw(game) end
end

function World:drawOverWalls(game)
    for mob in pairs(self:tagged('tree')) do mob:drawLeaves(game) end
    -- for mob in pairs(self:tagged('player')) do mob:draw(game) end
end

function World:drawLight(game)
    for mob in pairs(self:tagged('torch')) do mob:drawLight(game) end
    for mob in pairs(self:tagged('biome')) do
        love.graphics.circle('fill', mob.x, mob.y, mob.item.biome.radius / 10)
    end
    for mob in pairs(self:tagged('player')) do mob:drawLight(game) end
end

function World:drawShade(game)
    local color = {love.graphics.getColor()}
    love.graphics.setColor(0, 0, 0)
    for mob in pairs(self:tagged('biome')) do
        if mob.item.biome.is_dark then
            love.graphics.circle('fill', mob.x, mob.y, mob.item.biome.radius)
        end
    end
    for mob in pairs(self:tagged('starrot')) do mob:drawShade(game) end
    love.graphics.setColor(unpack(color))
end

--- Removes all dead mobs.
function World:clean()
    for mob in pairs(self.mobs) do
        if mob.is_alive == false then self:removeMob(mob) end
    end
end

function World:addMob(mob)
    self.mobs[mob] = mob.id or self.next_id
    mob.id = mob.id or self.next_id
    self.next_id = self.next_id + 1

    for tag in pairs(mob.tags) do
        if not self.tags[tag] then self.tags[tag] = {} end
        self.tags[tag][mob] = true
    end
end

--- Removes the mob from the world.
--- Prefer to use `is_alive = false` instead.
function World:removeMob(mob)
    for tag in pairs(mob.tags) do
        if not self.tags[tag] then self.tags[tag] = {} end
        self.tags[tag][mob] = nil
    end
    self.mobs[mob] = nil
end

--- Returns the mobs with the specified tag.
function World:tagged(tag) return self.tags[tag] or {} end

--- Returns the nearest mob at the specified position with `tag`.
--- Returns `nil` if no such mob exists.
function World:nearestTagged(tag, x, y)
    if not self.tags[tag] then return nil end

    local nearest = nil
    local near_dist = nil -- nearest distance squared
    for mob in pairs(self.tags[tag]) do
        local dist = (mob.x - x) * (mob.x - x) + (mob.y - y) * (mob.y - y) -- distance squared
        if not near_dist or dist < near_dist then
            nearest = mob
            near_dist = dist
        end
    end
    return nearest
end

--- Returns the world's save state.
function World:save()
    local save = {}
    save.next_id = self.next_id

    save.mobs = {}
    for mob in pairs(self:tagged('save')) do
        table.insert(save.mobs, mob:save())
    end

    return save
end

--- Returns a new `World` from the save state.
function World.load(save, assets)
    local self = World.new()
    self.next_id = save.next_id
    for i, mob in ipairs(save.mobs) do
        local module = require(mob.module) or Mob
        self:addMob(module.load(mob, assets))
    end

    return self
end

return World
