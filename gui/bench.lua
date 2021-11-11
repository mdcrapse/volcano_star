local Node = require('gui.node')
local RecipeTip = require('gui.recipe_tip')
local floor = math.floor

local Recipe = {}
Recipe.__index = Recipe
setmetatable(Recipe, {__index = Node})

function Recipe.new(player, recipe_idx)
    local self = setmetatable(Node.new(), Recipe)
    self.w = 20
    self.h = 20
    self.filter_cursor = true
    self.player = player
    --- The current bench the player is interacting with.
    --- Is guaranteed to be a `Bench` or `nil`.
    self.bench = nil
    self.recipe_idx = recipe_idx

    self.tip = RecipeTip.new(player)

    return self
end

function Recipe:tick(dt, game)
    -- update `self.bench`
    if self.player.interactor and self.player.interactor.tags.bench then
        self.bench = self.player.interactor
    else
        self.bench = nil
    end

    -- update displayed output item
    self.tip.recipe = self:getRecipe()

    -- call parent's update
    Node.tick(self, dt, game)
end

--- Returns the slot's recipe or `nil` if the slot has no recipe
function Recipe:getRecipe()
    if self.bench then return self.bench.item.bench[self.recipe_idx] end
end

--- Returns `true` if the pack has the ingredients for the recipe.
local function hasRecipeItems(recipe, pack)
    for i, slot in ipairs(recipe.input) do
        if pack:itemCount(slot.item) < slot.count then return false end
    end
    return true
end

--- Takes the items from the pack required to craft the recipe.
local function consumeRecipeItems(recipe, pack)
    for i, slot in ipairs(recipe.input) do
        pack:discardItem(slot.item, slot.count)
    end
end

function Recipe:onHover(game)
    if input:isMousePress(1) then
        local pack = self.player.pack
        local recipe = self:getRecipe()
        if self.bench and self.bench.isCrafting and not self.bench:isCrafting() and
            recipe and hasRecipeItems(recipe, pack) then
            consumeRecipeItems(recipe, pack)
            self.bench:beginCraft(recipe)
        end
    end
end

function Recipe:draw(game)
    love.graphics.draw(game.assets.sprites.hotbar_slot, self.x, self.y)
    local recipe = self:getRecipe()

    if recipe and recipe.output then
        local output = recipe.output
        love.graphics.draw(output.item.sprite, self.x + 2, self.y + 2)
        love.graphics.print(tostring(output.count), self.x + 1,
                            self.y + self.h - 6)
    end

    for i, child in pairs(self.children) do child:draw(game) end
end

--- Contains the crafting bench GUI.
local Bench = {}
Bench.__index = Bench
setmetatable(Bench, {__index = Node})

function Bench.new(player)
    local self = setmetatable(Node.new(), Bench)

    local NUM_RECIPES = 16
    local ROWS = 4
    self.w = ROWS * 20
    self.h = NUM_RECIPES / ROWS * 20

    for i = 1, NUM_RECIPES do
        local recipe = Recipe.new(player, i)
        recipe.offset_x = (i - 1) % ROWS * 20
        recipe.offset_y = floor((i - 1) / ROWS) * 20
        self.children['recipe' .. i] = recipe
    end

    self.player = player

    return self
end

Bench.Recipe = Recipe

return Bench
