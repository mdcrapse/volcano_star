local Node = require('gui.node')
local PackSlot = require('gui.pack_slot')
local input = input
local floor = math.floor

--- Pack UI.
local Chest = {}
Chest.__index = Chest
setmetatable(Chest, {__index = Node})

function Chest.new(player)
    local self = setmetatable(Node.new(), Chest)
    self.cols = 4
    self.rows = 4
    self.w = self.cols * 20
    self.h = self.rows * 20
    self.player = player

    for i = 1, (self.cols * self.rows) do
        local child = PackSlot.new(self.player, nil, i)
        child.offset_x = (i - 1) % self.cols * 20
        child.offset_y = floor((i - 1) / self.cols) * 20
        self.children['slot' .. i] = child
    end

    return self
end

function Chest:tick(dt, game)
    if self.player.interactor and self.player.interactor.tags.chest then
        for name, child in pairs(self.children) do
            child.pack = self.player.interactor.pack
        end

        Node.tick(self, dt, game)
    end
end

function Chest:draw(game)
    if self.player.interactor and self.player.interactor.tags.chest then
        for name, child in pairs(self.children) do
            child.pack = self.player.interactor.pack
        end

        Node.draw(self, game)
    end
end

return Chest
