local BiomeStar = require('mob.cell.biome_star')
local Tree = require('mob.cell.tree')
local Maph = require('maph')
local random, floor, min, max = love.math.random, math.floor, math.min, math.max

local TerrainGeneration = {}
TerrainGeneration.__index = TerrainGeneration

--- Generates the save file's terrains.
function TerrainGeneration.generateTerrarin(assets, map, world)
    TerrainGeneration.spawnBiomes(assets, map, world)
    TerrainGeneration.generateBeach(assets, map)
    for mob in pairs(world:tagged('biome')) do
        TerrainGeneration.generateBiome(mob, map, world)
    end
    -- make roads
    -- make rivers
    TerrainGeneration.spawnRocks(assets, map, world)
    TerrainGeneration.spawnTrees(assets, map, world)
end

--- Generates the beach at the bottom of the map.
function TerrainGeneration.generateBeach(assets, map)
    local WATER_HEIGHT = 5
    local SAND_HEIGHT = 10

    --- Current relative height.
    local cur_height = 0

    for i = 1, map.width do
        local water_height = WATER_HEIGHT + cur_height
        TerrainGeneration.fillRectTiles(i, map.height - water_height, 1,
                                        water_height, map, assets.items.water)
        TerrainGeneration.fillRectTiles(i, map.height - water_height -
                                            SAND_HEIGHT, 1, SAND_HEIGHT, map,
                                        assets.items.sand)
        --- water level changing
        if random(10) == 1 then
            if cur_height > 0 then
                cur_height = cur_height - 1
            else
                cur_height = cur_height + 1
            end
        end
    end
end

function TerrainGeneration.spawnRocks(assets, map, world)
    local num_rocks = map.width * map.height / 500
    for i = 1, num_rocks do
        local xx, yy = random(map.width), random(map.height)
        local radius = random(2, 5)
        if TerrainGeneration.isValidRockPos(xx, yy, map, world) then
            TerrainGeneration.fillCircleWalls(xx, yy, map, assets.items.stone,
                                              radius)
            TerrainGeneration.fillCircleTiles(xx, yy, map, assets.items.dirt,
                                              radius)
            TerrainGeneration.fillCircleWalls(xx + random(-3, 3),
                                              yy + random(-3, 3), map,
                                              assets.items.stone, radius)
        end
    end
end

function TerrainGeneration.spawnTrees(assets, map, world)
    local num_trees = map.width * map.height / 20
    for i = 1, num_trees do
        local xx, yy = random(map.width), random(map.height)
        if TerrainGeneration.isValidTreePos(xx, yy, map) then
            local tree = Tree.new(assets)
            tree.x = xx * 16 - 8
            tree.y = yy * 16 - 8
            world:addMob(tree)
            map:setMob(tree, xx, yy)
        end
    end
end

--- Spawn and randomly places biome stars.
function TerrainGeneration.spawnBiomes(assets, map, world)
    local volcano = BiomeStar.new(assets.items.volcano_star)
    volcano.x = floor(map.width / 2) * 16 - 8
    volcano.y = 8 * 16 - 8
    world:addMob(volcano)
    -- map:setMob(volcano, xx, yy)

    -- -- place randomly
    -- local ATTEMPTS_PER_BIOME = 100

    -- for name, item in pairs(assets.items) do
    --     if item.id ~= 'forest_star' and item.id ~= 'volcano_star' and item.usage ==
    --         'biome' then
    --         local star = BiomeStar.new(item)
    --         -- attempts to makes sure the biome is not touching another biome
    --         for i = 1, ATTEMPTS_PER_BIOME do
    --             local xx, yy = random(map.width), random(map.height)
    --             star.x = xx * 16 - 8
    --             star.y = yy * 16 - 8
    --             if not TerrainGeneration.isValidBiomePosition(star, world) then
    --                 map:setMob(star, xx, yy)
    --                 break
    --             end
    --         end
    --         world:addMob(star)
    --     end
    -- end
end

function TerrainGeneration.isValidRockPos(xx, yy, map, world)
    return map:getWall(xx, yy) == nil and map:getMob(xx, yy) == nil and
               map:getTile(xx, yy).id == 'grass' and
               TerrainGeneration.biomeAt(world, xx * 16 - 8, yy * 16 - 8) == nil
end

function TerrainGeneration.isValidTreePos(xx, yy, map)
    return map:getWall(xx, yy) == nil and map:getMob(xx, yy) == nil and
               map:getTile(xx, yy).id == 'grass'
end

--- Returns `true` if the specified position is valid for the biome.
function TerrainGeneration.isValidBiomePosition(biome, world)
    for other in pairs(world:tagged('biome')) do
        if Maph.distance(other.x, other.y, biome.x, biome.y) <
            other.item.biome.radius + biome.item.biome.radius then
            return true
        end
    end
    return false
end

--- Returns the biome at the specified position.
--- Returns `nil` if there's no biome at the specified position.
function TerrainGeneration.biomeAt(world, x, y)
    local biome = nil
    local biome_dist = nil -- the distance to the current biome
    for mob in pairs(world:tagged('biome')) do
        local dist = Maph.distance(x, y, mob.x, mob.y)
        if dist < mob.item.biome.radius then
            if biome_dist == nil or dist < biome_dist then
                biome = mob
                biome_dist = dist
            end
        end
    end
    return biome
end

function TerrainGeneration.generateBiome(biome, map, world)
    local xx, yy = map:posToIdx(biome.x, biome.y)
    if biome.item.biome.fill_walls then
        TerrainGeneration.fillCircleWalls(xx, yy, map,
                                          biome.item.biome.fill_walls,
                                          biome.item.biome.radius / 16 + 1)
    end
    TerrainGeneration.fillCircleTiles(xx, yy, map, biome.item.biome.fill_tiles,
                                      biome.item.biome.radius / 16 + 1)
end

--- Fills the map with a circle of wall of the specified item.
--- Does not replace existing walls or cell mobs.
function TerrainGeneration.fillCircleWalls(center_x, center_y, map, item, radius)
    TerrainGeneration.fillGridCircle(center_x, center_y, radius,
                                     function(ix, iy)
        if map:isInbounds(ix, iy) and map:getWall(ix, iy) == nil and
            map:getMob(ix, iy) == nil then map:setWall(item, ix, iy) end
    end)
end

function TerrainGeneration.clearCircleWalls(center_x, center_y, map, radius)
    TerrainGeneration.fillGridCircle(center_x, center_y, radius,
                                     function(ix, iy)
        if map:isInbounds(ix, iy) then map:clearWall(ix, iy) end
    end)
end

function TerrainGeneration.fillCircleTiles(center_x, center_y, map, item, radius)
    TerrainGeneration.fillGridCircle(center_x, center_y, radius,
                                     function(ix, iy)
        if map:isInbounds(ix, iy) then map:setTile(item, ix, iy) end
    end)
end

function TerrainGeneration.fillRectTiles(x, y, width, height, map, item)
    for ix = x, x + width do
        for iy = y, y + height do map:setTile(item, ix, iy) end
    end
end

function TerrainGeneration.fillGridCircle(center_x, center_y, radius, fill_cell)
    local diameter = radius * 2
    local x = center_x - radius
    local y = center_y - radius
    for ix = x, (x + diameter) do
        for iy = y, (y + diameter) do
            local xdist = center_x - ix
            local ydist = center_y - iy
            -- distance squared
            if xdist * xdist + ydist * ydist < radius * radius then
                fill_cell(ix, iy)
            end
        end
    end
end

return TerrainGeneration
