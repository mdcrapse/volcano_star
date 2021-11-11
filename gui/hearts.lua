local Node = require('gui.node')
local ceil = math.ceil

--- For displaying what biome the player is in.
local Hearts = {}
Hearts.__index = Hearts
setmetatable(Hearts, {__index = Node})

function Hearts.new(player)
    local self = setmetatable(Node.new(), Hearts)
    self.w = 16
    self.h = 16
    self.player = player

    return self
end

function Hearts:tick(dt, game)
    self.w = ceil(self.player.max_hp / 100) * 17
    self.h = 16

    Node.tick(self, dt, game)
end

function Hearts:draw(game)
    local num_hearts = ceil(self.player.max_hp / 100)
    love.graphics.draw(game.assets.sprites.heart_empty, self.x, self.y)
    for i = 1, num_hearts do
        if i * 100 > self.player.hp then
            love.graphics.draw(game.assets.sprites.heart_empty,
                               self.x + (i - 1) * 17, self.y)
        else
            love.graphics.draw(game.assets.sprites.heart_full,
                               self.x + (i - 1) * 17, self.y)
        end
    end

    for i, child in pairs(self.children) do child:draw(game) end
end

return Hearts
