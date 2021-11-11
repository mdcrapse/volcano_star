local Node = require('gui.node')
local Hotbar = require('gui.hotbar')
local Bench = require('gui.bench')
local Chest = require('gui.chest')
local PlayerPack = require('gui.player_pack')
local BiomeTitle = require('gui.biome_title')
local Hearts = require('gui.hearts')
local Equipment = require('gui.equipment')

local Hud = {}
Hud.__index = Hud
setmetatable(Hud, {__index = Node})

function Hud.new(player)
    local self = setmetatable(Node.new(), Hud)
    self.cur_tip = nil
    self.player = player
    --- Is `true` if a node is taking cursor input.
    self.is_filtering_cursor = false

    self.children.hotbar = Hotbar.new(player)
    self.children.hotbar.anchor_x = 0.5
    self.children.hotbar.anchor_y = 1
    self.children.hotbar.offset_y = -1

    self.children.biome_title = BiomeTitle.new(player)
    self.children.biome_title.anchor_x = 0.5
    self.children.biome_title.anchor_y = 0.25

    self.children.hearts = Hearts.new(player)
    self.children.hearts.anchor_x = 1
    self.children.hearts.anchor_y = 0
    self.children.hearts.offset_x = -1
    self.children.hearts.offset_y = 1

    self.player_pack_node = PlayerPack.new(player)
    self.player_pack_node.anchor_x = 0.5
    self.player_pack_node.anchor_y = 1
    self.player_pack_node.offset_y = -22

    self.bench_node = Bench.new(player)
    self.bench_node.anchor_x = 0
    self.bench_node.anchor_y = 0
    self.bench_node.offset_x = 1
    self.bench_node.offset_y = 1

    self.chest_node = Chest.new(player)
    self.chest_node.anchor_x = 0
    self.chest_node.anchor_y = 0
    self.chest_node.offset_x = 1
    self.chest_node.offset_y = 1

    self.equipment_node = Equipment.new(player)
    self.equipment_node.anchor_x = 1
    self.equipment_node.anchor_y = 0
    self.equipment_node.offset_x = -1
    self.equipment_node.offset_y = 18

    return self
end

function Hud:tick(dt, game)
    Node.tick(self, dt, game)
    -- update current tooltip
    self.cur_tip = self:findTip(self)
    if self.cur_tip then
        self.cur_tip.x = self.mouseX(game)
        self.cur_tip.y = self.mouseY(game)
    end
    -- update interaction display
    self.children.interact_menu = nil
    if self.player.in_menu and self.player.interactor then
        if self.player.interactor.tags.bench then
            self.children.interact_menu = self.bench_node
        elseif self.player.interactor.tags.chest then
            self.children.interact_menu = self.chest_node
        end
    end
    -- update cursor filter
    self.is_filtering_cursor = self:findIsFilteringCursor(self)
    -- update `in_menu` display
    if self.player.in_menu then
        self.children.player_pack = self.player_pack_node
        self.children.equipment = self.equipment_node
    else
        self.children.player_pack = nil
        self.children.equipment = nil
    end
end

--- Returns the current tooltip node or `nil` if there's none.
function Hud:findTip(branch)
    for name, child in pairs(branch.children) do
        local tip = self:findTip(child)
        if tip then return tip end
        if child.is_hovering and child.tip then return child.tip end
    end
end

--- Returns `true` if the cursor is being filtered by a node or its children.
function Hud:findIsFilteringCursor(branch)
    if branch.is_hovering and branch.filter_cursor then return true end
    for name, child in pairs(branch.children) do
        local filter = self:findIsFilteringCursor(child)
        if filter then return true end
    end
    return false
end

function Hud:draw(game)
    for i, child in pairs(self.children) do child:draw(game) end
    local cursor = self.player.cursor_slot
    if cursor.item then
        love.graphics.draw(cursor.item.sprite, Node.mousePos(game))
        love.graphics.print(tostring(cursor.count), Node.mouseX(game) + 1,
                            Node.mouseY(game) + 20 - 6)
    end

    if self.cur_tip then self.cur_tip:draw(game) end
end

return Hud
