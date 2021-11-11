local Cell = require('mob.cell')
local Item = require('mob.item')
local Maph = require('maph')
local Pack = require('pack')
local max, min, random = math.max, math.min, love.math.random

local Tree = {}
Tree.__index = Tree
setmetatable(Tree, {__index = Cell})

function Tree.new(assets)
    local self = setmetatable(Cell.new(), Tree)
    self.tags.save = true
    self.tags.tree = true
    self.is_solid = true
    --- The amount of time before the leaves of the tree regrows.
    self.leaf_wait = 60 * 30
    --- Seconds left for the leaves to regrow.
    self.leaf_timer = 0
    --- How see-through the leaves are. Is modified when the player is near
    self.alpha = 0
    self.sprite = assets.sprites.tree_stump

    return self
end

function Tree:tick(dt, game)
    Cell.tick(self, dt, game)

    -- grow
    local COMPOST_MULTIPLIER = 2
    local grow_multi = 1
    if self.cellx and self.celly and game.map:getTile(self.cellx, self.celly).id ==
        'compost' then grow_multi = COMPOST_MULTIPLIER end
    self.leaf_timer = max(self.leaf_timer - dt * grow_multi, 0)

    -- see through leaves
    if self:hasLeaves() then
        local near_player = false
        for mob in pairs(game.world:tagged('player')) do
            if Maph.distance(mob.x, mob.y, self.x, self.y) < 24 then
                near_player = true
                break
            end
        end
        if near_player then
            self.alpha = max(self.alpha - dt, 0.25)
        else
            self.alpha = min(self.alpha + dt, 1)
        end
    else
        self.alpha = 0
    end
end

function Tree:draw(game) Cell.draw(self, game) end

function Tree:drawLeaves(game)
    if self:hasLeaves() then
        -- draw see through leaves
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(r, g, b, self.alpha * a)
        love.graphics.draw(game.assets.sprites.tree_leaves, self.x, self.y,
                           self.angle + math.pi, 1, 1, 16, 16)
        love.graphics.setColor(r, g, b, a)
    end
end

function Tree:onMine(miner, game)
    if self.is_alive then
        if self:hasLeaves() then
            -- drop wood
            local wood = Item.new(Pack.Slot.new(game.assets.items.wood, 3))
            wood.x = self.x
            wood.y = self.y
            game.world:addMob(wood)
            -- drop seeds
            if random(5) == 1 then
                local seeds = Item.new(Pack.Slot.new(game.assets.items
                                                         .tree_seeds, 1))
                seeds.x = self.x
                seeds.y = self.y
                game.world:addMob(seeds)
            end

            self.leaf_timer = self.leaf_wait
        else
            -- drop stump
            self.is_alive = false
            local item = Item.new(Pack.Slot.new(game.assets.items.wood, 1))
            item.x = self.x
            item.y = self.y
            game.world:addMob(item)
        end
    end
end

--- Returns `true` if the tree's leaves are grown.
function Tree:hasLeaves() return self.leaf_timer <= 0 end

function Tree:save()
    local save = Cell.save(self)
    save.module = 'mob.cell.tree'
    save.leaf_timer = self.leaf_timer

    return save
end

function Tree.load(save, assets, mob)
    local self = Cell.load(save, assets, Tree.new(assets))
    self.leaf_timer = save.leaf_timer

    return self
end

return Tree
