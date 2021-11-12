local Node = require('gui.node')
local input, max = input, math.max

--- Displays a tip for the the specified slot.
local SlotTip = {}
SlotTip.__index = SlotTip
setmetatable(SlotTip, {__index = Node})

--- Returns a new `SlotTip`. `slot` should be set in the parent's `tick`.
function SlotTip.new()
    local self = setmetatable(Node.new(), SlotTip)
    self.w = 20
    self.h = 20
    self.filter_cursor = false
    self.slot = nil
    return self
end

function SlotTip:tick(dt, game)
    Node.tick(self, dt, game)

    if self.slot and self.slot.item then
        local font = game.assets.fonts.tic_80_wide
        self.w = max(font:getWidth(self.slot.item.name) + 1,
                     font:getWidth(self.slot.item.desc) + 1)
    end
end

function SlotTip:draw(game)
    if self.slot and self.slot.item then
        local pre_color = {love.graphics.getColor()}
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(self.slot.item.name, self.x + 1, self.y + 1)
        love.graphics.print(self.slot.item.desc, self.x + 1, self.y + 1 + 8)
        love.graphics.setColor(unpack(pre_color))

        love.graphics.print(self.slot.item.name, self.x, self.y)
        love.graphics.print(self.slot.item.desc, self.x, self.y + 8)
    end

    for i, child in pairs(self.children) do child:draw(game) end
end

return SlotTip
