local Cell = require('mob.cell')
local Item = require('mob.item')
local Pack = require('pack')
local min = math.min

local Crop = {}
Crop.__index = Crop
setmetatable(Crop, {__index = Cell})

function Crop.new(item)
    local self = setmetatable(Cell.new(), Crop)
    self.tags.save = true
    self.tags.crop = true
    self.is_solid = false
    self.item = item
    --- The number of seconds the crop has grown. Clamped by the item's max grow time.
    self.grow_time = 0

    return self
end

function Crop:tick(dt, game)
    Cell.tick(self, dt, game)

    local COMPOST_MULTIPLIER = 2
    local grow_multi = 1
    if self.cellx and self.celly and game.map:getTile(self.cellx, self.celly).id == 'compost' then
        grow_multi = COMPOST_MULTIPLIER
    end
    self.grow_time = min(self.grow_time + dt * grow_multi, self.item.seed.grow_time)
end

function Crop:draw(game)
    if self:isMature() then
        self.sprite = self.item.seed.produce.sprite
    else
        self.sprite = game.assets.sprites.crop_growth
    end

    Cell.draw(self, game)
end

function Crop:onMine(miner, game)
    if self.is_alive then
        -- drop produce if mature
        if self:isMature() then
            local item = Item.new(Pack.Slot.new(self.item.seed.produce, 1))
            item.x = self.x
            item.y = self.y
            game.world:addMob(item)
        end

        self.is_alive = false
    end
end

--- Returns `true` if the crop is fully grown physically and mentally.
function Crop:isMature() return self.grow_time >= self.item.seed.grow_time end

function Crop:save()
    local save = Cell.save(self)
    save.module = 'mob.cell.crop'
    save.grow_time = self.grow_time
    save.item = self.item.id

    return save
end

function Crop.load(save, assets, mob)
    local self = Cell.load(save, assets, Crop.new(assets.items[save.item]))
    self.grow_time = save.grow_time

    return self
end

return Crop
