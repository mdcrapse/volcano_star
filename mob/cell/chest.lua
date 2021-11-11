local Cell = require('mob.cell')
local Item = require('mob.item')
local Pack = require('pack')

local Chest = {}
Chest.__index = Chest
setmetatable(Chest, {__index = Cell})

Chest.NUM_SLOTS = 16

function Chest.new(item, pack)
    local self = setmetatable(Cell.new(), Chest)
    self.tags.save = true
    self.tags.interact = true
    self.tags.chest = true
    self.is_solid = true
    self.item = item
    self.sprite = item.sprite
    self.pack = pack or Pack.new(Chest.NUM_SLOTS)

    return self
end

function Chest:tick(dt, game) Cell.tick(self, dt, game) end

function Chest:onMine(miner, game)
    if self.is_alive then
        -- drop chest
        local item = Item.new(Pack.Slot.new(self.item, 1))
        item.x = self.x
        item.y = self.y
        game.world:addMob(item)

        -- drop items
        for i, slot in ipairs(self.pack.slots) do
            if not slot:isEmpty() then
                local item = Item.new(slot)
                item.x = self.x
                item.y = self.y
                game.world:addMob(item)
            end
        end

        self.is_alive = false
    end
end

function Chest:save()
    local save = Cell.save(self)
    save.module = 'mob.cell.chest'
    save.item = self.item.id
    save.pack = self.pack:save()

    return save
end

function Chest.load(save, assets, mob)
    local self = Cell.load(save, assets, Chest.new(assets.items[save.item],
                                                   Pack.load(save.pack, assets)))

    return self
end

return Chest
