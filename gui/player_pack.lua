local Node = require('gui.node')
local PackSlot = require('gui.pack_slot')
local floor = math.floor

--- Contains all the hotbar slots.
local PlayerPack = {}
PlayerPack.__index = PlayerPack
setmetatable(PlayerPack, {__index = Node})

function PlayerPack.new(player)
    local self = setmetatable(Node.new(), PlayerPack)
    self.cols = 10
    self.rows = 2
    self.w = self.cols * 20
    self.h = self.rows * 20
    self.player = player

    local PACK_INDEX_OFFSET = 10 -- makes sure not to include the hotbar

    for i = 1, (self.cols * self.rows) do
        local child = PackSlot.new(self.player, nil, i + PACK_INDEX_OFFSET)
        child.offset_x = (i - 1) % self.cols * 20
        child.offset_y = floor((i - 1) / self.cols) * 20
        self.children['slot' .. i] = child
    end

    return self
end

function PlayerPack:tick(dt, game)
    for name, child in pairs(self.children) do child.pack = self.player.pack end

    Node.tick(self, dt, game)
end

function PlayerPack:draw(game)
    for name, child in pairs(self.children) do child.pack = self.player.pack end

    Node.draw(self, game)
end

return PlayerPack
