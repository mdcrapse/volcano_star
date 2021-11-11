local Maph = require('maph')
local pi, max, random, sin, cos, floor, min = math.pi, math.max,
                                              love.math.random, math.sin,
                                              math.cos, math.floor, math.min

--- Handles biome mob spawning and biome item detecting.
--- To be used per a player.
local Biome = {}
Biome.__index = Biome

function Biome.new(assets)
    return setmetatable({
        --- The current biome the mob is in. Is an item asset.
        item = assets.items.forest_star,
        --- A list of all the mobs the biome has spawned.
        --- 'dead' mobs are auto cleared.
        spawned_mobs = {},
        --- The amount of timer before the next spawn.
        spawn_timer = 0
    }, Biome)
end

function Biome:tick(dt, game, player)
    self:tickItem(game, player)
    self:tickSpawn(dt, game, player)
end

--- Sets `item` to the current biome, defaults to `forest_star`.
function Biome:tickItem(game, player)
    self.item = game.assets.items.forest_star -- default to forest
    local biome_dist = nil -- the distance to the current biome
    for biome in pairs(game.world:tagged('biome')) do
        local dist = Maph.distance(player.x, player.y, biome.x, biome.y)
        if dist < biome.item.biome.radius then
            if biome_dist == nil or dist < biome_dist then
                self.item = biome.item
                biome_dist = dist
            end
        end
    end
end

--- Spawns the biome's mobs.
function Biome:tickSpawn(dt, game, player)
    self.spawn_timer = min(max(self.spawn_timer - dt, 0),
                           self.item.biome.spawn_timer_max)
    if self.spawn_timer <= 0 and #self.item.biome.spawns > 0 then
        local spawn = self.item.biome.spawns[random(#self.item.biome.spawns)]
        local mob_type = require(spawn.mob)

        local num_mobs = random(spawn.count_min, spawn.count_max)
        local SPAWN_DIST = 240
        local dir = random(pi * 2)
        local x = floor((player.x + sin(dir) * SPAWN_DIST) / 16) * 16 + 8
        local y = floor((player.y - cos(dir) * SPAWN_DIST) / 16) * 16 + 8
        local xx, yy = game.map:posToIdx(x, y)
        -- assures not spawning in solid cell
        if xx and yy and not game.map:isSolid(xx, yy) then
            for i = 1, num_mobs do
                local mob = mob_type.new(game.assets)
                mob.x = x
                mob.y = y
                game.world:addMob(mob)
            end
            -- timer will not reset if the mob could not be spawned
            self:resetSpawnTimer()
        end
    end
end

function Biome:resetSpawnTimer()
    self.spawn_timer = random(self.item.biome.spawn_timer_min,
                              self.item.biome.spawn_timer_max)
end

return Biome
