local Mob = require('mob')
local Maph = require('maph')
local draw = love.graphics.draw
local cos, sin, min = math.cos, math.sin, math.min

--- For displaying what item the player is using.
local HandItem = {}
HandItem.__index = HandItem
setmetatable(HandItem, {__index = Mob})

function HandItem.new(item, owner)
    local self = setmetatable(Mob.new(), HandItem)
    self.tags.player_item = true
    self.item = item
    self.owner = owner
    --- The number of seconds the mob has existed. Mob is destroyed when this passes `item.use_time`.
    self.use_time = 0

    return self
end

function HandItem:tick(dt, game)
    self.angle = self.owner.angle
    self.x = self.owner.x + sin(self.angle) * 16
    self.y = self.owner.y - cos(self.angle) * 16

    self.use_time = min(self.use_time + dt, self.item.use_time)
    if self.use_time >= self.item.use_time then self.is_alive = false end
end

function HandItem:draw(game)
    draw(self.item.sprite, self.x, self.y, self.angle, 1, 1, 8, 8)
end

return HandItem
