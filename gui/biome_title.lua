local Node = require('gui.node')

--- For displaying what biome the player is in.
local BiomeTitle = {}
BiomeTitle.__index = BiomeTitle
setmetatable(BiomeTitle, {__index = Node})

function BiomeTitle.new(player)
    local self = setmetatable(Node.new(), BiomeTitle)
    self.h = 1
    self.player = player
    self.show_fade_wait = 0.5
    self.show_wait = 2.5
    self.show_timer = 0
    self.item = nil

    return self
end

function BiomeTitle:tick(dt, game)
    self.show_timer = math.max(self.show_timer - dt, 0)

    -- show new biome name when entering a new biome
    if self.show_timer <= 0 and self.item ~= self.player.biome.item then
        self.show_timer = self.show_wait
        self.item = self.player.biome.item
    end

    Node.tick(self, dt, game)
end

function BiomeTitle:draw(game)
    local item = self.item
    if item and self.show_timer >= 0 then
        local font = love.graphics.getFont()
        self.w = font:getWidth(item.biome.title)
        local pre_color = {love.graphics.getColor()}
        -- show fading
        local alpha = 1
        if self.show_timer < self.show_fade_wait then
            alpha = self.show_timer / self.show_fade_wait
        elseif self.show_timer > self.show_wait - self.show_fade_wait then
            alpha = 1 -
                        (self.show_timer -
                            (self.show_wait - self.show_fade_wait)) /
                        self.show_fade_wait
        else
            alpha = 1
        end
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.print(item.biome.title, self.x + 1, self.y + 1)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print(item.biome.title, self.x, self.y)
        love.graphics.setColor(unpack(pre_color))
    end

    for i, child in pairs(self.children) do child:draw(game) end
end

return BiomeTitle
