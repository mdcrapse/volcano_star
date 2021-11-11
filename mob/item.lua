local Mob = require('mob')
local Maph = require('maph')
local Pack = require('pack')
local pi = math.pi

local Item = {}
Item.__index = Item
setmetatable(Item, {__index = Mob})

function Item.new(slot)
    local self = setmetatable(Mob.new(), Item)
    self.tags.save = true
    self.tags.item = true
    self.slot = slot
    if slot.item then self.sprite = slot.item.sprite end

    return self
end

function Item:tick(dt, game)
    self:playerPickup(game)

    local TURN_SPD = 1

    self.angle = self.angle + TURN_SPD * dt
    if self.angle > pi * 2 then self.angle = self.angle - pi * 2 end
end

function Item:draw(game)
    love.graphics.draw(self.sprite or game.assets.sprites.null_item, self.x,
                       self.y, self.angle, 1, 1, 8, 8)
end

--- Checks for nearby players to pickup the item.
function Item:playerPickup(game)
    local PICKUP_DIST = 16

    for player in pairs(game.world:tagged('player')) do
        if Maph.distance(self.x, self.y, player.x, player.y) < PICKUP_DIST then
            player.pack:add(self.slot)
            if not self.slot.item then
                self.is_alive = false
                break
            end
        end
    end
end

function Item:save()
    local save = Mob.save(self)
    save.module = 'mob.item'
    save.slot = self.slot:save()
    return save
end

function Item.load(save, assets, mob)
    local self = Mob.load(save, assets,
                          Item.new(Pack.Slot.load(save.slot, assets)))
    return self
end

return Item
