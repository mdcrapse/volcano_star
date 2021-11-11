local Maph = require('maph')
local floor, min, max = math.floor, math.min, math.max

local Map = {}
Map.__index = Map

local function new_array(size, value)
    local arr = {}
    for i = 1, size do arr[i] = value end
    return arr
end

--- Returns a new `Map` with the specified size.
function Map.new(assets, width, height)
    width = width or 1
    height = height or 1
    return setmetatable({
        tiles = new_array(width * height, assets.items.grass),
        walls = new_array(width * height, nil),
        mobs = {}, --- Contains mappings from indices to mobs.
        width = width,
        height = height
    }, Map)
end

--- Returns the tile at the specified indices.
--- Returns `nil` if the indices are out of map bounds.
function Map:getTile(x, y)
    if self:isInbounds(x, y) then return self.tiles[self:idxToOne(x, y)] end
    return nil
end

--- Sets the tile at the specified indices.
--- Does nothing if the indices are out of bounds.
function Map:setTile(tile, x, y)
    if self:isInbounds(x, y) then self.tiles[self:idxToOne(x, y)] = tile end
end

--- Returns the wall at the specified indices.
--- Returns `nil` if the indices are out of map bounds or if there's no wall.
function Map:getWall(x, y)
    if self:isInbounds(x, y) then return self.walls[self:idxToOne(x, y)] end
    return nil
end

--- Sets the wall at the specified indices. Call `clear_wall` to remove a wall.
--- Does nothing if the indices are out of bounds.
function Map:setWall(wall, x, y)
    if self:isInbounds(x, y) then self.walls[self:idxToOne(x, y)] = wall end
end

--- Removes the wall from the specified indices.
function Map:clearWall(x, y)
    if self:isInbounds(x, y) then self.walls[self:idxToOne(x, y)] = nil end
end

--- Returns `true` if there's a wall at the specified index.
function Map:isWall(x, y) return self:getWall(x, y) ~= nil end

--- Returns the mob at the specified indices.
--- Returns `nil` if the indices are out of map bounds or if there's no mob.
--- The returned mob's `is_alive` field may be `false`.
function Map:getMob(x, y)
    if self:isInbounds(x, y) then return self.mobs[self:idxToOne(x, y)] end
    return nil
end

--- Sets the mob at the specified indices.
--- Does nothing if the indices are out of bounds.
function Map:setMob(mob, x, y)
    if self:isInbounds(x, y) then self.mobs[self:idxToOne(x, y)] = mob end
end

--- Clears the mob cells then sets the cells to each mob that has the `'cell'` tag.
--- Sets the mobs' `cellx` and `celly` to their respective positions indices.
function Map:resetMobCells(world)
    for k, mob in pairs(self.mobs) do self.mobs[k] = nil end
    for mob in pairs(world:tagged('cell')) do
        mob.cellx, mob.celly = self:posToIdx(mob.x, mob.y)
        if mob.cellx and mob.celly then
            local idx = self:idxToOne(mob.cellx, mob.celly)
            self.mobs[idx] = self.mobs[idx] or mob
        end
    end
end

--- Returns `true` if there's a solid cell at the specified index.
function Map:isSolid(x, y)
    local mob = self:getMob(x, y)
    return self:isWall(x, y) or (mob and mob.is_solid)
end

--- Returns `true` if there's no cell collisions between the two positions.
function Map:isLineClear(x, y, x2, y2)
    local len = Maph.distance(x, y, x2, y2)
    local dir_x, dir_y = Maph.normalized(x2 - x, y2 - y)
    len = floor(len / 16)
    for i = 0, len do
        x = x + dir_x * 16
        y = y + dir_y * 16
        local xx, yy = self:posToIdx(x, y)
        if not xx or not yy or self:isSolid(xx, yy) then return false end
    end
    return true
end

--- Returns the cell index at the specified position.
--- Returns `nil` if the position is out of map bounds.
function Map:posToIdx(x, y)
    x = math.floor(x / 16) + 1
    y = math.floor(y / 16) + 1
    if self:isInbounds(x, y) then return x, y end
    return nil
end

--- Returns true if the specified position is within map bounds.
function Map:isPosInbounds(x, y)
    x = math.floor(x / 16) + 1
    y = math.floor(y / 16) + 1
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

--- Returns true if the specified cell index is within map bounds.
function Map:isInbounds(x, y)
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

--- Returns the one dimensional index of the two dimensional index for accessing the one dimensional array.
function Map:idxToOne(x, y) return (x % self.width + 1) + (y - 1) * self.width end

function Map:drawTiles(assets, x, y, w, h)
    local draw = love.graphics.draw
    local xx, yy = self:posToIdx(x, y)
    xx = max(xx or 1, 1)
    yy = max(yy or 1, 1)
    local ww, hh = self:posToIdx(x + w, y + h)
    ww = min(ww or self.width, self.width)
    hh = min(hh or self.height, self.height)
    for iy = yy, hh do
        for ix = xx, ww do
            local tile = self.tiles[self:idxToOne(ix, iy)]
            draw(tile.sprite, (ix - 1) * 16, (iy - 1) * 16)
        end
    end
end

function Map:drawWalls(assets, x, y, w, h)
    local draw = love.graphics.draw
    local xx, yy = self:posToIdx(x, y)
    xx = max(xx or 1, 1)
    yy = max(yy or 1, 1)
    local ww, hh = self:posToIdx(x + w, y + h)
    ww = min(ww or self.width, self.width)
    hh = min(hh or self.height, self.height)
    for iy = yy, hh do
        for ix = xx, ww do
            local wall = self.walls[self:idxToOne(ix, iy)]
            if wall then
                draw(wall.sprite, (ix - 1) * 16, (iy - 1) * 16)
            end
        end
    end
end

--- Returns the map's save state.
function Map:save()
    local save = {
        width = self.width,
        height = self.height,
        tiles = {},
        walls = {}
    }

    for i = 1, (self.width * self.height) do
        save.tiles[i] = self.tiles[i].id
        if self.walls[i] then
            save.walls[i] = self.walls[i].id
        else
            save.walls[i] = nil
        end
    end

    return save
end

--- Returns a new `Map` from the save state.
function Map.load(save, assets)
    local self = Map.new(assets, save.width, save.height)

    for i = 1, (self.width * self.height) do
        -- TODO: provide defaults if items don't exist
        self.tiles[i] = assets.items[save.tiles[i]]
        if save.walls[i] then
            self.walls[i] = assets.items[save.walls[i]]
        else
            self.walls[i] = nil
        end
    end

    return self
end

return Map
