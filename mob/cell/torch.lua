local Cell = require('mob.cell')
local Item = require('mob.item')
local Pack = require('pack')

local Torch = {}
Torch.__index = Torch
setmetatable(Torch, {__index = Cell})

function Torch.new(item)
    local self = setmetatable(Cell.new(), Torch)
    self.tags.save = true
    self.tags.torch = true
    self.is_solid = true
    self.item = item
    self.sprite = item.sprite

    return self
end

function Torch:drawLight(game)
    local brightness = 1
    if self.item.torch.night_glow then brightness = 1 - game.time.sunlight end

    local pre_color = {love.graphics.getColor()}
    local color = self.item.torch.color
    love.graphics.setColor(color[1] * brightness, color[2] * brightness,
                           color[3] * brightness, 1)
    love.graphics.circle('fill', self.x, self.y, self.item.torch.radius * 0.8)
    brightness = brightness * 0.5
    love.graphics.setColor(color[1] * brightness, color[2] * brightness,
                           color[3] * brightness, 1)
    love.graphics.circle('fill', self.x, self.y, self.item.torch.radius)
    love.graphics.setColor(unpack(pre_color))
end

function Torch:onMine(miner, game)
    if self.is_alive then
        local item = Item.new(Pack.Slot.new(self.item, 1))
        item.x = self.x
        item.y = self.y
        game.world:addMob(item)

        self.is_alive = false
    end
end

function Torch:save()
    local save = Cell.save(self)
    save.module = 'mob.cell.torch'
    save.item = self.item.id

    return save
end

function Torch.load(save, assets)
    local self = Cell.load(save, assets, Torch.new(assets.items[save.item]))
    return self
end

return Torch
