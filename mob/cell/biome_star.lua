local Cell = require('mob.cell')
local Item = require('mob.item')
local Pack = require('pack')
local Starrot = require('mob.enemy.starrot')

local BiomeStar = {}
BiomeStar.__index = BiomeStar
setmetatable(BiomeStar, {__index = Cell})

function BiomeStar.new(item)
    local self = setmetatable(Cell.new(), BiomeStar)
    self.tags.save = true
    self.tags.biome = true
    self.is_solid = true
    self.item = item
    self.sprite = item.sprite

    return self
end

function BiomeStar:tick(dt, game) Cell.tick(self, dt, game) end

function BiomeStar:onMine(miner, game)
    if self.is_alive then
        if self.item.id == 'volcano_star' then
            -- summon Starrot
            -- the Starrot will make the biome star drop when the Starrot is destroyed
            local boss_exists = false
            for mob in pairs(game.world:tagged('starrot')) do
                boss_exists = true
                break
            end
            if not boss_exists then
                local boss = Starrot.new(game.assets)
                boss.x = self.x
                boss.y = self.y
                game.world:addMob(boss)
            end
        else
            -- drop item
            local item = Item.new(Pack.Slot.new(self.item, 1))
            item.x = self.x
            item.y = self.y
            game.world:addMob(item)

            self.is_alive = false
        end
    end
end

function BiomeStar:save()
    local save = Cell.save(self)
    save.module = 'mob.cell.biome_star'
    save.item = self.item.id

    return save
end

function BiomeStar.load(save, assets, mob)
    local self = Cell.load(save, assets, BiomeStar.new(assets.items[save.item]))

    return self
end

return BiomeStar
