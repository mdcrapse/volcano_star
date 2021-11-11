local Node = require('gui.node')
local input = input

local HotbarSlot = {}
HotbarSlot.__index = HotbarSlot
setmetatable(HotbarSlot, {__index = Node})

function HotbarSlot.new(player, hotbar_index)
    local self = setmetatable(Node.new(), HotbarSlot)
    self.w = 20
    self.h = 20
    self.filter_cursor = true
    self.player = player
    self.hotbar_index = hotbar_index
    return self
end

function HotbarSlot:onHover(game)
    if input:isMousePress(1) then
        local slot = self.player.pack.slots[self.hotbar_index]
        local cursor = self.player.cursor_slot
        if slot:canMerge(cursor) then
            slot:merge(cursor)
        else
            cursor:swap(slot)
        end
    end
end

function HotbarSlot:tick(dt, game) Node.tick(self, dt, game) end

function HotbarSlot:draw(game)
    if self.player.cur_slot == self.hotbar_index then
        love.graphics.draw(game.assets.sprites.hotbar_slot_selected, self.x, self.y)
    else
        love.graphics.draw(game.assets.sprites.hotbar_slot, self.x, self.y)
    end
    local slot = self.player.pack.slots[self.hotbar_index]
    if slot.item then
        love.graphics.draw(slot.item.sprite, self.x + 2, self.y + 2)
        love.graphics.print(tostring(slot.count), self.x + 1, self.y + self.h - 6)
    end

    for i, child in pairs(self.children) do child:draw(game) end
end

--- Contains all the hotbar slots.
local Hotbar = {}
Hotbar.__index = Hotbar
setmetatable(Hotbar, {__index = Node})

function Hotbar.new(player)
    local self = setmetatable(Node.new(), Hotbar)

    local NUM_SLOTS = 10

    self.w = NUM_SLOTS * 20
    self.h = 20

    for i = 1, NUM_SLOTS do
        local child = HotbarSlot.new(player, i)
        child.offset_x = (i - 1) * 20
        self.children['slot' .. i] = child
    end

    return self
end

Hotbar.Slot = HotbarSlot

return Hotbar
