local Mob = require('mob')

--- A mob contained in a map cell.
--- Auto sets `self` in `game.map.mobs`.
--- Is basically a wall that is a mob.
local Cell = {}
Cell.__index = Cell
setmetatable(Cell, {__index = Mob})

function Cell.new()
    local self = setmetatable(Mob.new(), Cell)
    self.tags.cell = true
    --- The mob's map x index. Auto set by `Map`.
    self.cellx = nil
    --- The mob's map y index. Auto set by `Map`.
    self.celly = nil
    self.angle = math.pi
    self.is_solid = false

    return self
end

--- Is called when a mob mines the cell.
function Cell:onMine(miner, game) end

return Cell
