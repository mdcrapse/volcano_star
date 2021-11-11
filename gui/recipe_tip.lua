local Node = require('gui.node')
local max = math.max

--- Displays a tip for the the specified recipe.
local RecipeTip = {}
RecipeTip.__index = RecipeTip
setmetatable(RecipeTip, {__index = Node})

--- Returns a new `RecipeTip`. `recipe` should be set in the parent's `tick`.
function RecipeTip.new(player)
    local self = setmetatable(Node.new(), RecipeTip)
    self.w = 20
    self.h = 20
    self.filter_cursor = false
    self.recipe = nil
    self.player = player
    return self
end

function RecipeTip:draw(game)
    if self.recipe then
        local SPACING = 20

        -- draw backdrop
        local pre_color = {love.graphics.getColor()}
        love.graphics.setColor(0, 0, 0, 0.9)
        love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
        love.graphics.setColor(unpack(pre_color))
        -- HACK: use multiple nodes for sizing, positioning, and nine patch drawing
        self.w = 0
        self.h = SPACING * 2

        -- draw output
        love.graphics.print(self.recipe.output.item.name, self.x, self.y)
        love.graphics.print(self.recipe.time .. ' Seconds', self.x, self.y + SPACING)

        -- draw input
        local font = love.graphics.getFont()
        for i, slot in ipairs(self.recipe.input) do
            local input_text = '(' .. self.player.pack:itemCount(slot.item) ..
                                   ')' .. slot.item.name

            self.w = max(self.w, font:getWidth(input_text) + SPACING)
            self.h = self.h + SPACING

            local sprite_x, sprite_y = self.x, self.y + (i + 1) * SPACING - 4
            love.graphics.draw(slot.item.sprite, sprite_x, sprite_y)
            love.graphics.print(tostring(slot.count), sprite_x, sprite_y + 14)
            love.graphics.print(input_text, self.x + SPACING, self.y + (i + 1) * SPACING)
        end
    end

    for i, child in pairs(self.children) do child:draw(game) end
end

return RecipeTip
