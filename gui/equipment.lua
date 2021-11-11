local Node = require('gui.node')
local SlotTip = require('gui.slot_tip')
local input = input
local floor, ceil = math.floor, math.ceil

local EquipmentSlot = {}
EquipmentSlot.__index = EquipmentSlot
setmetatable(EquipmentSlot, {__index = Node})

function EquipmentSlot.new(player, equip_idx)
    local self = setmetatable(Node.new(), EquipmentSlot)
    self.w = 20
    self.h = 20
    self.filter_cursor = true
    self.player = player
    self.equip_idx = equip_idx
    self.tip = SlotTip.new()
    return self
end

--- Returns the player's slot that this node represents.
function EquipmentSlot:playerSlot() return self.player.equipment[self.equip_idx] end

function EquipmentSlot:onHover(game)
    local slot = self:playerSlot()
    local cursor = self.player.cursor_slot
    if input:isMousePress(1) then
        if slot:isEmpty() and not cursor:isEmpty() then
            slot:mergeCount(cursor, 1)
        elseif cursor:canMerge(slot) then
            cursor:merge(slot)
        end
    end
end

function EquipmentSlot:tick(dt, game)
    self.tip.slot = self:playerSlot()
    Node.tick(self, dt, game)
end

function EquipmentSlot:draw(game)
    love.graphics.draw(game.assets.sprites.hotbar_slot, self.x, self.y)
    local slot = self:playerSlot()
    if slot.item then
        love.graphics.draw(slot.item.sprite, self.x + 2, self.y + 2)
        love.graphics.print(tostring(slot.count), self.x + 1,
                            self.y + self.h - 6)
    end

    for i, child in pairs(self.children) do child:draw(game) end
end

--- Player equipment UI.
local Equipment = {}
Equipment.__index = Equipment
setmetatable(Equipment, {__index = Node})

function Equipment.new(player)
    local self = setmetatable(Node.new(), Equipment)
    self.cols = 1
    self.rows = 6
    self.w = self.cols * 20
    self.h = self.rows * 20
    self.player = player

    for i = 1, (self.cols * self.rows) do
        local child = EquipmentSlot.new(self.player, i)
        child.offset_x = (i - 1) % self.cols * 20
        child.offset_y = floor((i - 1) / self.cols) * 20
        self.children['slot' .. i] = child
    end

    return self
end

function Equipment:tick(dt, game) Node.tick(self, dt, game) end

function Equipment:draw(game) Node.draw(self, game) end

return Equipment
