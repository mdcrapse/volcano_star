local Node = require('gui.node')
local SlotTip = require('gui.slot_tip')
local ceil = math.ceil
local input = input

local PackSlot = {}
PackSlot.__index = PackSlot
setmetatable(PackSlot, {__index = Node})

function PackSlot.new(player, pack, pack_idx)
    local self = setmetatable(Node.new(), PackSlot)
    self.w = 20
    self.h = 20
    self.filter_cursor = true
    self.player = player
    self.pack = pack
    self.pack_idx = pack_idx
    self.tip = SlotTip.new()
    return self
end

function PackSlot:onHover(game)
    local slot = self.pack.slots[self.pack_idx]
    local cursor = self.player.cursor_slot
    if input:isMousePress(1) then
        if slot:canMerge(cursor) then
            slot:merge(cursor)
        else
            cursor:swap(slot)
        end
    end
    if input:isMousePress(2) then
        if cursor:isEmpty() then
            cursor:mergeCount(slot, ceil(slot.count / 2))
        elseif slot:canMerge(cursor) then
            slot:mergeCount(cursor, 1)
        end
    end
end

function PackSlot:tick(dt, game)
    self.tip.slot = self.pack.slots[self.pack_idx]
    Node.tick(self, dt, game)
end

function PackSlot:draw(game)
    love.graphics.draw(game.assets.sprites.hotbar_slot, self.x, self.y)
    local slot = self.pack.slots[self.pack_idx]
    if slot.item then
        love.graphics.draw(slot.item.sprite, self.x + 2, self.y + 2)
        love.graphics.print(tostring(slot.count), self.x + 1,
                            self.y + self.h - 6)
    end

    for i, child in pairs(self.children) do child:draw(game) end
end

return PackSlot
