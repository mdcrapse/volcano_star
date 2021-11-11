local Cell = require('mob.cell')
local Item = require('mob.item')
local Pack = require('pack')
local max, ceil = math.max, math.ceil

local Bench = {}
Bench.__index = Bench
setmetatable(Bench, {__index = Cell})

function Bench.new(bench_item)
    local self = setmetatable(Cell.new(), Bench)
    self.tags.save = true
    self.tags.interact = true
    self.tags.bench = true
    self.is_solid = true
    self.item = bench_item
    self.sprite = bench_item.sprite

    self.craft_time = 0
    --- The item slot the bench is going to create when `craft_time` becomes `0`.
    self.output_slot = nil

    return self
end

function Bench:beginCraft(recipe)
    self.craft_time = recipe.time
    self.output_slot = Pack.Slot.new(recipe.output.item, recipe.output.count)
end

function Bench:tick(dt, game)
    Cell.tick(self, dt, game)

    -- crafting
    self.craft_time = max(self.craft_time - dt, 0)
    if self.craft_time == 0 and self.output_slot then
        local item = Item.new(self.output_slot)
        item.x = self.x
        item.y = self.y
        game.world:addMob(item)
        self.output_slot = nil
    end
end

--- Returns `true` if the bench is currently crafting a recipe.
function Bench:isCrafting() return self.output_slot ~= nil end

function Bench:draw(game)
    Cell.draw(self, game)
    if self.craft_time > 0 and self.output_slot then
        love.graphics.draw(self.output_slot.item.sprite, self.x - 4, self.y - 4,
                           0, 0.5, 0.5)
        love.graphics.print(tostring(ceil(self.craft_time)), self.x - 8,
                            self.y - 8)
    end
end

function Bench:onMine(miner, game)
    if self.is_alive then
        local item = Item.new(Pack.Slot.new(self.item, 1))
        item.x = self.x
        item.y = self.y
        game.world:addMob(item)

        self.is_alive = false
    end
end

function Bench:save()
    local save = Cell.save(self)
    save.module = 'mob.cell.bench'
    save.item = self.item.id
    save.craft_time = self.craft_time
    if self.output_slot then save.output_slot = self.output_slot:save() end

    return save
end

function Bench.load(save, assets)
    local self = Cell.load(save, assets, Bench.new(assets.items[save.item]))
    self.craft_time = save.craft_time
    if save.output_slot then
        self.output_slot = Pack.Slot.load(save.output_slot, assets)
    end

    return self
end

return Bench
