local mousePos = love.mouse.getPosition
local mousePress = love.mouse.isDown

local Node = {}
Node.__index = Node

function Node.new()
    return setmetatable({
        x = 0,
        y = 0,
        w = 0, --- Width.
        h = 0, --- Height.
        anchor_x = 0, --- X normalized anchor.
        anchor_y = 0, --- Y normalized anchor.
        offset_x = 0, --- X pixel offset.
        offset_y = 0, --- Y pixel offset.
        filter_cursor = false, --- Whether or not the node takes cursor inputs.
        children = {},
        tip = nil, --- The node's tooltip node.
        is_hovering = false,
        was_pressed = false --- Whether or not the node was pressed the previous frame.
    }, Node)
end

function Node.mouseX(game)
    return love.mouse.getX() / game.player.hud_cam:getScale()
end

function Node.mouseY(game)
    return love.mouse.getY() / game.player.hud_cam:getScale()
end

function Node.mousePos(game) return Node.mouseX(game), Node.mouseY(game) end

function Node:onHover(game) end

function Node:onPress(game) end

function Node:onPressing(game) end

function Node:layout(parent)
    self.x = parent.x + self.offset_x + (parent.w - self.w) * self.anchor_x
    self.y = parent.y + self.offset_y + (parent.h - self.h) * self.anchor_y
end

--- Returns `true` if the position is hovering the node.
function Node:isHovering(x, y)
    return
        x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y +
            self.h
end

function Node:tick(dt, game)
    self.is_hovering = self:isHovering(Node.mousePos(game))
    if self.is_hovering then
        self:onHover(game)
        if mousePress(1) then
            self:onPressing(game)
            if not self.was_pressed then self:onPress() end
            self.was_pressed = true
        else
            self.was_pressed = false
        end
    end
    for i, child in pairs(self.children) do
        child:layout(self)
        child:tick(dt, game)
        child:layout(self)
    end
end

function Node:draw(game)
    love.graphics.draw(game.assets.sprites.null_item, self.x, self.y, 0,
                       1 / 16 * self.w, 1 / 16 * self.h)
    for i, child in pairs(self.children) do child:draw(game) end
end

return Node
