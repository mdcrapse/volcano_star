local serpent = require('serpent')
local floor, pi, cos, sin, atan2, max = math.floor, math.pi, math.cos, math.sin,
                                        math.atan2, math.max

--- For grid based pathfinding.
local Path = {}
Path.__index = Path

local UNEXPLORED = -1
local UNREACHABLE = -2

function Path.new(width, height)
    local self = setmetatable({
        --- The center x index.
        x = 0,
        --- The center y index.
        y = 0,
        width = width or 1,
        height = height or 1,
        --- How often the path refreshes (in seconds).
        refresh_frequency = 1,
        refresh_timer = 0,
        --- Each cell contains the distance from the end point or a specific state (-1 == unexplored, -2 == unreachable).
        cells = {}
    }, Path)

    self:clear()

    return self
end

--- Moves the end point to the specified position.
function Path:tick(x, y, map, dt)
    -- do timer
    self.refresh_timer = max(self.refresh_timer - dt, 0)
    if self.refresh_timer > 0 then
        return nil
    else
        self.refresh_timer = self.refresh_frequency
    end

    self.x, self.y = floor(x / 16) + 1, floor(y / 16) + 1
    self:clear()

    -- find path
    -- TODO: implement A* (A Star) pathfinding?
    local center_x = floor(self.width / 2)
    local center_y = floor(self.height / 2)
    local open_x = {center_x}
    local open_y = {center_y}
    self.cells[self:idxToOne(center_x, center_y)] = 0
    while #open_x > 0 do
        local x = open_x[1]
        local y = open_y[1]
        table.remove(open_x, 1)
        table.remove(open_y, 1)

        -- check this cell's distance
        local idx = self:idxToOne(x, y)
        local dist = self.cells[idx]
        if map:isSolid(self:idxToMapIdx(x, y)) then
            self.cells[idx] = UNREACHABLE
            goto continue
        end
        dist = self.cells[idx]

        -- add adjacent cells to the next-to-check list
        -- TODO: simplify into a seperate method?
        -- left
        if x > 1 then
            local idx = self:idxToOne(x - 1, y)
            if self.cells[idx] == UNEXPLORED then
                table.insert(open_x, x - 1)
                table.insert(open_y, y)
                self.cells[idx] = dist + 1
            end
        end
        -- right
        if x < self.width then
            local idx = self:idxToOne(x + 1, y)
            if self.cells[idx] == UNEXPLORED then
                table.insert(open_x, x + 1)
                table.insert(open_y, y)
                self.cells[idx] = dist + 1
            end
        end
        -- up
        if y > 1 then
            local idx = self:idxToOne(x, y - 1)
            if self.cells[idx] == UNEXPLORED then
                table.insert(open_x, x)
                table.insert(open_y, y - 1)
                self.cells[idx] = dist + 1
            end
        end
        -- down
        if y < self.height then
            local idx = self:idxToOne(x, y + 1)
            if self.cells[idx] == UNEXPLORED then
                table.insert(open_x, x)
                table.insert(open_y, y + 1)
                self.cells[idx] = dist + 1
            end
        end

        ::continue::
    end
end

function Path:clear()
    for i = 1, (self.width * self.height) do
        -- elements beyond `self.width * self.height` are not touched, in order to problably increase performance
        self.cells[i] = UNEXPLORED
    end
end

local FIND_DIR_CELLS = {
    {x = -1, y = 0, dir = pi}, {x = 1, y = 0, dir = 0},
    {x = 0, y = -1, dir = pi / 2}, {x = 0, y = 1, dir = pi + pi / 2}
}

--- Returns the direction to go to get to the end of the path.
--- Returns `nil` if the path cannot be reached.
function Path:findDir(x, y)
    local pos_x, pos_y = x, y
    x, y = self:posToIdx(x, y)
    if not self:isInbounds(x, y) then return nil end
    local shortest_path = nil
    local dir = nil
    for i, relative_idx in ipairs(FIND_DIR_CELLS) do
        local idx_x, idx_y = x + relative_idx.x, y + relative_idx.y
        if self:isInbounds(idx_x, idx_y) then
            local cell = self:getCell(idx_x, idx_y)
            if cell >= 0 then
                if shortest_path == nil or cell < shortest_path then
                    shortest_path = cell
                    -- assures the direction is pointing toward the center of the cell
                    dir = atan2(pos_y -
                                    (floor(pos_y / 16 + relative_idx.y) * 16 + 8),
                                -(pos_x -
                                    (floor(pos_x / 16 + relative_idx.x) * 16 + 8)))
                end
            end
        end
    end
    return dir
end

--- Returns the path index converted into a map index.
function Path:idxToMapIdx(x, y)
    return x + self.x - floor(self.width / 2),
           y + self.y - floor(self.height / 2)
end

--- Returns the one dimensional index of the two dimensional index for accessing the one dimensional array.
function Path:idxToOne(x, y) return (x % self.width + 1) + (y - 1) * self.width end

function Path:getCell(x, y) return self.cells[self:idxToOne(x, y)] end

--- Returns true if the specified cell index is within map bounds.
function Path:isInbounds(x, y)
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

--- Returns the cell index at the specified position.
function Path:posToIdx(x, y)
    x = floor(x / 16) + 1 - self.x + floor(self.width / 2)
    y = floor(y / 16) + 1 - self.y + floor(self.height / 2)
    return x, y
    -- if self:isInbounds(x, y) then return x, y end
    -- return nil
end

function Path:debugDraw()
    for x = 1, self.width do
        for y = 1, self.height do
            local idx = self:getCell(x, y)
            love.graphics.print(idx, x * 16 + self.x * 16 -
                                    floor(self.width / 2) * 16,
                                y * 16 + self.y * 16 - floor(self.height / 2) *
                                    16)
        end
    end
end

return Path
