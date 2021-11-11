local Cell = require('mob.cell')
local Item = require('mob.item')
local Pack = require('pack')
local Maph = require('maph')

local Door = {}
Door.__index = Door
setmetatable(Door, {__index = Cell})

function Door.new(item)
    local self = setmetatable(Cell.new(), Door)
    self.tags.save = true
    self.tags.interact = true
    self.tags.bench = true
    self.is_solid = true
    self.item = item
    self.sprite = item.sprite
    self.is_open = false
    self.open_dist = 24

    return self
end

function Door:tick(dt, game)
    Cell.tick(self, dt, game)

    -- open and close
    local plr = game.world:nearestTagged('player', self.x, self.y)
    self.is_open = plr and Maph.distance(self.x, self.y, plr.x, plr.y) <
                       self.open_dist
    self.is_solid = not self.is_open
    if self.is_open then
        self.sprite = game.assets.sprites.door_open
    else
        self.sprite = self.item.sprite
    end
end

function Door:onMine(miner, game)
    if self.is_alive then
        local item = Item.new(Pack.Slot.new(self.item, 1))
        item.x = self.x
        item.y = self.y
        game.world:addMob(item)

        self.is_alive = false
    end
end

function Door:save()
    local save = Cell.save(self)
    save.module = 'mob.cell.door'
    save.item = self.item.id

    return save
end

function Door.load(save, assets)
    local self = Cell.load(save, assets, Door.new(assets.items[save.item]))

    return self
end

return Door
