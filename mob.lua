local Pack = require('pack')

local Mob = {}
Mob.__index = Mob
local min, max = math.min, math.max

function Mob.new()
    return setmetatable({
        module = 'mob',
        is_alive = true,
        tags = {},
        id = nil,
        x = 0,
        y = 0,
        angle = 0,
        xspd = 0,
        yspd = 0,
        sprite = nil
    }, Mob)
end

function Mob:tick(dt, game) end

function Mob:draw(game)
    local sprite = self.sprite or game.assets.sprites.null_item
    love.graphics.draw(sprite, self.x, self.y, self.angle + math.pi, 1, 1,
                       sprite:getWidth() / 2, sprite:getHeight() / 2)
end

--- Returns `true` if both mobs are touching.
function Mob:isTouching(other)
    local xdist, ydist = (self.x - other.x), (self.y - other.y)
    local size = self:getRadius()
    local other_size = other:getRadius()
    -- avoids calculating distance to probably improve performance
    return xdist * xdist + ydist * ydist < (size + other_size) * (size + other_size)
end

--- Returns the mob's radius.
function Mob:getRadius()
    if self.sprite then
        return self.sprite:getWidth() / 2
    end
    return 8
end

local function isOutOfMapBounds(map, x, y)
    return x <= 0 or x >= map.width * 16 or y <= 0 or y >= map.height * 16
end

--- Returns `true` if there's a collision at the specified position. (box shape collision)
function Mob:isCollision(map, x, y)
    --- Mob collision radius.
    local SIZE = 6

    -- top left
    local xx, yy = map:posToIdx(x - SIZE, y - SIZE)
    if xx and yy and map:isSolid(xx, yy) then return true end
    if isOutOfMapBounds(map, x - SIZE, y - SIZE) then return true end
    -- top right
    local xx, yy = map:posToIdx(x + SIZE, y - SIZE)
    if xx and yy and map:isSolid(xx, yy) then return true end
    if isOutOfMapBounds(map, x + SIZE, y - SIZE) then return true end
    -- bottom left
    local xx, yy = map:posToIdx(x - SIZE, y + SIZE)
    if xx and yy and map:isSolid(xx, yy) then return true end
    if isOutOfMapBounds(map, x - SIZE, y + SIZE) then return true end
    -- bottom right
    local xx, yy = map:posToIdx(x + SIZE, y + SIZE)
    if xx and yy and map:isSolid(xx, yy) then return true end
    if isOutOfMapBounds(map, x + SIZE, y + SIZE) then return true end

    return false
end

--- Moves the mob around solid objects.
--- Disables collisions if the mob is inside a collision.
--- Returns the new velocity.
function Mob:move(dt, game, x, y)
    local vel_x = x
    local vel_y = y

    if not self:isCollision(game.map, self.x, self.y) then
        if not self:isCollision(game.map, self.x + x * dt, self.y) then
            self.x = self.x + x * dt
        else
            vel_x = 0
        end
        if not self:isCollision(game.map, self.x, self.y + y * dt) then
            self.y = self.y + y * dt
        else
            vel_y = 0
        end
    else
        self.x = self.x + x * dt
        self.y = self.y + y * dt
    end

    -- keep mob inbounds
    self.x = min(max(self.x, 0), game.map.width * 16)
    self.y = min(max(self.y, 0), game.map.height * 16)

    return vel_x, vel_y
end

--- Returns the mob's save state.
function Mob:save()
    local save = {}
    save.module = 'mob'
    save.id = self.id
    save.x = self.x
    save.y = self.y

    return save
end

--- Returns a new `Mob` from the save state.
function Mob.load(save, assets, mob)
    local self = mob or Mob.new()
    self.id = save.id
    self.x = save.x
    self.y = save.y

    return self
end

return Mob
