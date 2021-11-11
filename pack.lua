local max, min = math.max, math.min

local Slot = {}
Slot.__index = Slot

function Slot.new(item, count)
    return setmetatable({
        --- The item asset. Is `nil` if the slot is empty.
        item = item,
        count = count or 0
    }, Slot)
end

--- Returns `true` if the slot is empty
function Slot:isEmpty() return self.item == nil end

--- Returns `true` if both slots can merge.
function Slot:canMerge(other) return other.item == self.item or self.item == nil end

--- Attempts to merge both slots, adding to `self` and subtracting from `other`.
--- Does nothing if `self:canMerge(other) == false`.
--- `other` contains the excess slot.
function Slot:merge(other)
    if self:canMerge(other) then
        self.item = other.item -- `self.item` may be `nil` (look at `canMerge`)
        local takes = other.count
        if self.item then
            takes = min(self.count + other.count, self.item.stack_size) -
                        self.count
        end
        if takes > 0 then
            self.count = self.count + takes
            other:discard(takes)
        end
    end
end

--- Attempts to merge both slots, adding to `self` and subtracting from `other` with the specified count.
--- Does nothing if `self:canMerge(other) == false`.
--- `other` contains the excess slot.
function Slot:mergeCount(other, count)
    if self:canMerge(other) then
        self.item = other.item -- `self.item` may be `nil` (look at `canMerge`)
        local takes = other.count
        if self.item then
            takes = min(self.count + other.count, self.item.stack_size,
                        self.count + count) - self.count
        end
        if takes > 0 then
            self.count = self.count + takes
            other:discard(takes)
        end
    end
end

function Slot:swap(other)
    self.item, other.item = other.item, self.item
    self.count, other.count = other.count, self.count
end

--- Returns an identical slot then makes this slot empty.
function Slot:take()
    local slot = Slot.new()
    self:swap(slot)
    return slot
end

--- Discards the specified amount from the slot and sets `item` to `nil` if `count` becomes `0`.
function Slot:discard(count)
    self.count = max(0, self.count - count)
    if self.count == 0 then self.item = nil end
end

--- Returns the slot's save state.
function Slot:save()
    local id = nil
    if self.item then id = self.item.id end
    return {item = id, count = self.count}
end

--- Returns a new 'Slot' from the save state.
function Slot.load(save, assets)
    local item = nil
    if save.item then item = assets.items[save.item] end
    return Slot.new(item, save.count)
end

--- Contains in game inventory items.
local Pack = {}
Pack.__index = Pack
Pack.Slot = Slot

function Pack.new(len)
    local slots = {}
    for i = 1, len do slots[i] = Slot.new() end
    return setmetatable({len = len, slots = slots}, Pack)
end

--- Attempts to merge the slot into the pack.
--- `slot` contains the excess slot.
function Pack:add(slot)
    -- merge same items
    for i, pack in ipairs(self.slots) do
        if pack.item == slot.item and pack:canMerge(slot) then
            pack:merge(slot)
        end
    end
    -- merge anywhere
    for i, pack in ipairs(self.slots) do
        if pack:canMerge(slot) then pack:merge(slot) end
    end
end

--- Returns the count sum of each slot that has `item`.
function Pack:itemCount(item)
    local count = 0
    for i, slot in ipairs(self.slots) do
        if slot.item == item then count = count + slot.count end
    end
    return count
end

--- Discards the specified amount of the specified item amongst multiple slots.
function Pack:discardItem(item, count)
    for i, slot in ipairs(self.slots) do
        if slot.item == item then
            local pre_count = slot.count
            slot:discard(count)
            count = count - pre_count
            if count <= 0 then return nil end
        end
    end
end

--- Returns the pack's save state.
function Pack:save()
    local slots = {}
    for i, slot in ipairs(self.slots) do
        if slot.item then slots[i] = slot:save() end
    end

    return {len = self.len, slots = slots}
end

--- Returns a new `Pack` from the save state.
function Pack.load(save, assets)
    local self = Pack.new(save.len)
    for i, slot in pairs(save.slots) do
        self.slots[i]:swap(Slot.load(slot, assets))
    end

    return self
end

return Pack
