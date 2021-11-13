local Mob = require('mob')
local Cam = require('cam')
local Maph = require('maph')
local Pack = require('pack')
local Hud = require('gui.hud')
local Sword = require('mob.player.sword')
local Spear = require('mob.player.spear')
local HandItem = require('mob.player.hand_item')
local Item = require('mob.item')
local Bench = require('mob.cell.bench')
local Crop = require('mob.cell.crop')
local Arrow = require('mob.arrow')
local Chest = require('mob.cell.chest')
local Biome = require('biome')
local BiomeStar = require('mob.cell.biome_star')
local MobDeath = require('mob.particle.mob_death')
local Tree = require('mob.cell.tree')
local Path = require('path')
local Camera = require('mob.camera')
local Starrot = require('mob.enemy.starrot')
local Torch = require('mob.cell.torch')
local Bomb = require('mob.player.bomb')
local TerrainGeneration = require('terrain_generation')
local Door = require('mob.cell.door')
local isKeyDown = love.keyboard.isDown
local mousePosition = love.mouse.getPosition
local atan2, min, max, sin, cos, floor = math.atan2, math.min, math.max,
                                         math.sin, math.cos, math.floor
local input = input

local Player = {}
Player.__index = Player
setmetatable(Player, {__index = Mob})

function Player.new(assets)
    local self = setmetatable(Mob.new(), Player)
    self.tags.save = true
    self.tags.shove = true
    self.tags.player = true

    self.hurt_invincible_time = 1
    self.hurt_cooldown = 0
    self.hurt_knockback = 300

    self.camera = Camera.new(self)
    self.cam = self.camera.cam
    self.hud_cam = Cam.new(0, 0, love.graphics.getDimensions())
    self.hud_cam:setScale(4)

    -- equipment
    self.equipment = {}
    for i = 1, 6 do self.equipment[i] = Pack.Slot.new() end
    self.equip_glow_range = 0

    -- pack
    self.cursor_slot = Pack.Slot.new()
    self.pack = Pack.new(30)
    -- self.pack = Pack.new(70)
    self.cur_slot = 1

    self.pack:add(Pack.Slot.new(assets.items.sword, 1))
    self.pack:add(Pack.Slot.new(assets.items.pickaxe, 1))
    self.pack:add(Pack.Slot.new(assets.items.shovel, 1))
    self.pack:add(Pack.Slot.new(assets.items.craft_bench, 1))

    -- -- add all items to inventory
    -- for name, item in pairs(assets.items) do
    --     self.pack:add(Pack.Slot.new(item, 900))
    -- end

    -- -- self.pack:add(Pack.Slot.new(assets.items.stone, 10))

    self.biome = Biome.new(assets)

    --- The current mob the player is interacting with.
    self.interactor = nil

    --- The amount of time in seconds that any hotbar slot may be used by the player.
    self.slot_use_time = 0

    --- Swing direction positive and negative one. Changes each time the player attacks.
    self.swing_dir = -1

    self.max_hp_base = 100
    self.max_hp = self.max_hp_base
    self.hp = self.max_hp

    self.sprite = assets.sprites.player

    self.path = Path.new(35, 35)

    self.respawn_wait = 3
    self.respawn_timer = 3

    self.in_menu = false
    self.hud = Hud.new(self)

    return self
end

function Player:respawn(x, y)
    self.is_alive = true
    self.respawn_timer = self.respawn_wait
    self.hp = self.max_hp
    self.x = x
    self.y = y
end

function Player:tick(dt, game)

    self.path:tick(self.x, self.y, game.map, dt)

    -- tick menu
    if input:isKeyPress('e') then self.in_menu = not self.in_menu end

    -- debug testing

    -- if input:isKeyPress('q') then
    --     local msx, msy = self.cam:toWorld(mousePosition())

    --     -- -- fills radius
    --     -- local slot = self.pack.slots[self.cur_slot]
    --     -- local item = slot.item
    --     -- local xx, yy = game.map:posToIdx(msx, msy)
    --     -- if item and xx and yy then
    --     --     if item.usage == 'wall' then
    --     --         TerrainGeneration.fillCircleWalls(xx, yy, game.map, item, 2)
    --     --     elseif item.usage == 'tile' then
    --     --         TerrainGeneration.fillCircleTiles(xx, yy, game.map, item, 2)
    --     --     end
    --     -- else
    --     --     TerrainGeneration.clearCircleWalls(xx, yy, game.map, 2)
    --     -- end

    --     -- -- summon boss
    --     -- local starrot = Starrot.new(game.assets)
    --     -- starrot.x = msx
    --     -- starrot.y = msy
    --     -- game.world:addMob(starrot)

    --     -- give items
    --     self.pack:add(Pack.Slot.new(game.assets.items.boulder_star, 1))
    --     self.pack:add(Pack.Slot.new(game.assets.items.starbit, 1))
    --     self.pack:add(Pack.Slot.new(game.assets.items.stone, 300))
    --     self.pack:add(Pack.Slot.new(game.assets.items.copper, 100))
    --     self.pack:add(Pack.Slot.new(game.assets.items.iron, 100))
    --     self.pack:add(Pack.Slot.new(game.assets.items.gold, 100))
    --     self.pack:add(Pack.Slot.new(game.assets.items.gold_shovel,  1))
    --     self.pack:add(Pack.Slot.new(game.assets.items.gold_pickaxe, 1))
    --     self.pack:add(Pack.Slot.new(game.assets.items.chest, 1))
    --     self.pack:add(Pack.Slot.new(game.assets.items.beet, 10))
    -- end

    -- if input:isKeyPress('t') then
    --     self.pack = Pack.new(30)
    --     self.cur_slot = 1

    --     self.pack:add(Pack.Slot.new(game.assets.items.sword, 1))
    --     self.pack:add(Pack.Slot.new(game.assets.items.pickaxe, 1))
    --     self.pack:add(Pack.Slot.new(game.assets.items.shovel, 1))
    --     self.pack:add(Pack.Slot.new(game.assets.items.craft_bench, 1))
    -- end

    -- movement

    local ACCEL = 600
    local MAX_SPD = 100
    local FRICTION = 800

    local in_x = 0
    local in_y = 0

    if isKeyDown('a') then in_x = in_x - 1 end
    if isKeyDown('d') then in_x = in_x + 1 end
    if isKeyDown('w') then in_y = in_y - 1 end
    if isKeyDown('s') then in_y = in_y + 1 end

    in_x, in_y = Maph.normalized(in_x, in_y)

    -- find tile friction
    -- TODO: simplify
    local tile_friction = 1
    local xx, yy = game.map:posToIdx(self.x, self.y)
    if xx and yy then
        local item = game.map:getTile(xx, yy)
        if item then tile_friction = item.tile.friction end
    end

    if in_x == 0 and in_y == 0 then
        -- friction
        self.xspd = Maph.moveToward(self.xspd, 0, FRICTION * tile_friction * dt)
        self.yspd = Maph.moveToward(self.yspd, 0, FRICTION * tile_friction * dt)
    else
        -- acceleration
        self.xspd = Maph.moveToward(self.xspd, MAX_SPD * in_x,
                                    ACCEL * tile_friction * dt)
        self.yspd = Maph.moveToward(self.yspd, MAX_SPD * in_y,
                                    ACCEL * tile_friction * dt)
    end

    self.xspd, self.yspd = self:move(dt, game, self.xspd, self.yspd)

    local msx, msy = self.cam:toWorld(mousePosition())
    self.angle = atan2(msx - self.x, -(msy - self.y))

    self:tickCurSlot()
    if not self.hud.is_filtering_cursor then
        self:tickItemUse(dt, game)
        if not self.cursor_slot:isEmpty() then
            -- drop cursor slot
            if input:isMousePress(2) then
                local item = Item.new(self.cursor_slot:take())
                item.x = msx
                item.y = msy
                game.world:addMob(item)
            end
        end
    end
    self:tickMobInteractions(game)
    self.biome:tick(dt, game, self)
    self:tickEquipment(game)

    self:tickHudCam(game)

    -- update hurt cooldown
    self.hurt_cooldown = max(self.hurt_cooldown - dt, 0)
end

--- Updates the currently selected pack slot.
function Player:tickCurSlot()
    local hotbar_len = min(10, self.pack.len)

    for i = 1, hotbar_len do
        if i <= 9 and input:isKeyPress(tostring(i)) then
            self.cur_slot = i
        elseif i == 10 and input:isKeyPress('0') then
            self.cur_slot = 10
        end
    end

    local change = -input:wheel()
    if change ~= 0 then
        self.cur_slot = self.cur_slot + change
        if self.cur_slot > hotbar_len then
            self.cur_slot = 1
        elseif self.cur_slot < 1 then
            self.cur_slot = hotbar_len
        end
    end
end

function Player:hurt(game, damage, attacker)
    if self.hurt_cooldown <= 0 then
        self.hurt_cooldown = self.hurt_invincible_time

        -- knockback
        local dir_x, dir_y = Maph.normalized(self.x - attacker.x,
                                             self.y - attacker.y)
        self.xspd = self.xspd + dir_x * self.hurt_knockback
        self.yspd = self.yspd + dir_y * self.hurt_knockback

        -- hurt/kill
        self.hp = max(self.hp - damage, 0)
        if self.hp <= 0 then self:kill(game, attacker) end
    end
end

function Player:heal(game, amount) self.hp = min(self.hp + amount, self.max_hp) end

--- Kills the player. `attacker` may be `nil`.
function Player:kill(game, attacker)
    self.is_alive = false
    game.world:addMob(MobDeath.new(self.sprite, self.x, self.y, self.angle,
                                   self.xspd, self.yspd))
end

function Player:tickItemUse(dt, game)
    -- TODO: remove item use logic from player?
    -- TODO: simplify into multiple functions

    self.slot_use_time = max(self.slot_use_time - dt, 0)
    local TOOL_REACH = 64

    if self.slot_use_time <= 0 and input:isMouseDown(1) then
        local slot = self.pack.slots[self.cur_slot]
        if not self.cursor_slot:isEmpty() then slot = self.cursor_slot end
        local item = slot.item
        if item then
            if item.usage == 'none' then
                -- do nothing
            elseif item.usage == 'tile' then
                local msx, msy = self.cam:toWorld(mousePosition())
                local xx, yy = game.map:posToIdx(msx, msy)
                if xx and yy and game.map:getTile(xx, yy) ==
                    game.assets.items.dirt and
                    Maph.distance(self.x, self.y, msx, msy) < TOOL_REACH then
                    self.slot_use_time = item.use_time
                    self:swingAttack(game, item)
                    game.map:setTile(item, xx, yy)
                    slot:discard(1)
                end
            elseif item.usage == 'wall' then
                local msx, msy = self.cam:toWorld(mousePosition())
                local xx, yy = game.map:posToIdx(msx, msy)
                if xx and yy and not game.map:isWall(xx, yy) and
                    not game.map:getMob(xx, yy) and
                    Maph.distance(self.x, self.y, msx, msy) < TOOL_REACH then
                    self.slot_use_time = item.use_time
                    self:swingAttack(game, item)
                    game.map:setWall(item, xx, yy)
                    slot:discard(1)
                end
            elseif item.usage == 'bench' then
                local msx, msy = self.cam:toWorld(mousePosition())
                local xx, yy = game.map:posToIdx(msx, msy)
                if xx and yy and not game.map:isWall(xx, yy) and
                    Maph.distance(self.x, self.y, msx, msy) < TOOL_REACH and
                    not game.map:getMob(xx, yy) then
                    self.slot_use_time = item.use_time
                    self:swingAttack(game, item)
                    local bench = Bench.new(item)
                    bench.x = xx * 16 - 8
                    bench.y = yy * 16 - 8
                    game.world:addMob(bench)
                    slot:discard(1)
                end
            elseif item.usage == 'door' then
                local msx, msy = self.cam:toWorld(mousePosition())
                local xx, yy = game.map:posToIdx(msx, msy)
                if xx and yy and not game.map:isWall(xx, yy) and
                    Maph.distance(self.x, self.y, msx, msy) < TOOL_REACH and
                    not game.map:getMob(xx, yy) then
                    self.slot_use_time = item.use_time
                    self:swingAttack(game, item)
                    local door = Door.new(item)
                    door.x = xx * 16 - 8
                    door.y = yy * 16 - 8
                    game.world:addMob(door)
                    slot:discard(1)
                end
            elseif item.usage == 'torch' then
                local msx, msy = self.cam:toWorld(mousePosition())
                local xx, yy = game.map:posToIdx(msx, msy)
                if xx and yy and not game.map:isWall(xx, yy) and
                    Maph.distance(self.x, self.y, msx, msy) < TOOL_REACH and
                    not game.map:getMob(xx, yy) then
                    self.slot_use_time = item.use_time
                    self:swingAttack(game, item)
                    local torch = Torch.new(item)
                    torch.x = xx * 16 - 8
                    torch.y = yy * 16 - 8
                    game.world:addMob(torch)
                    slot:discard(1)
                end
            elseif item.usage == 'biome' then
                local msx, msy = self.cam:toWorld(mousePosition())
                local xx, yy = game.map:posToIdx(msx, msy)
                if xx and yy and not game.map:isWall(xx, yy) and
                    Maph.distance(self.x, self.y, msx, msy) < TOOL_REACH and
                    not game.map:getMob(xx, yy) then
                    self.slot_use_time = item.use_time
                    self:swingAttack(game, item)
                    local biome = BiomeStar.new(item)
                    biome.x = xx * 16 - 8
                    biome.y = yy * 16 - 8
                    game.world:addMob(biome)
                    slot:discard(1)
                end
            elseif item.usage == 'tree_seeds' then
                local msx, msy = self.cam:toWorld(mousePosition())
                local xx, yy = game.map:posToIdx(msx, msy)
                if xx and yy and not game.map:isWall(xx, yy) and
                    Maph.distance(self.x, self.y, msx, msy) < TOOL_REACH and
                    not game.map:getMob(xx, yy) then
                    self.slot_use_time = item.use_time
                    self:swingAttack(game, item)
                    local tree = Tree.new(game.assets)
                    tree.leaf_timer = tree.leaf_wait
                    tree.x = xx * 16 - 8
                    tree.y = yy * 16 - 8
                    game.world:addMob(tree)
                    slot:discard(1)
                end
            elseif item.usage == 'chest' then
                local msx, msy = self.cam:toWorld(mousePosition())
                local xx, yy = game.map:posToIdx(msx, msy)
                if xx and yy and not game.map:isWall(xx, yy) and
                    Maph.distance(self.x, self.y, msx, msy) < TOOL_REACH and
                    not game.map:getMob(xx, yy) then
                    self.slot_use_time = item.use_time
                    self:swingAttack(game, item)
                    local chest = Chest.new(item)
                    chest.x = xx * 16 - 8
                    chest.y = yy * 16 - 8
                    game.world:addMob(chest)
                    slot:discard(1)
                end
            elseif item.usage == 'starbit' then
                self.slot_use_time = item.use_time
                self:swingAttack(game, item)
                self.max_hp = self.max_hp + 100
                self.hp = self.hp + 100
                slot:discard(1)
            elseif item.usage == 'sword' then
                self.slot_use_time = item.use_time
                self:swingAttack(game, item)
            elseif item.usage == 'spear' then
                self.slot_use_time = item.use_time
                game.world:addMob(Spear.new(item, self))
            elseif item.usage == 'bomb' then
                self.slot_use_time = item.use_time
                local bomb = Bomb.new(item, self)
                bomb.x = self.x
                bomb.y = self.y
                -- TODO: don't hardcode bomb speed
                local BOMB_SPEED = 175
                bomb.xspd = sin(self.angle) * BOMB_SPEED
                bomb.yspd = -cos(self.angle) * BOMB_SPEED
                game.world:addMob(bomb)
                slot:discard(1)
            elseif item.usage == 'food' then
                if self.hp < self.max_hp then
                    self.slot_use_time = item.use_time
                    self:swingAttack(game, item)
                    self:heal(game, item.food.heals)
                    slot:discard(1)
                end
            elseif item.usage == 'bow' then
                self.slot_use_time = item.use_time
                game.world:addMob(HandItem.new(item, self))
                if self.pack:itemCount(game.assets.items.arrow) > 0 then
                    self.pack:discardItem(game.assets.items.arrow, 1)
                    local arrow = Arrow.new(game.assets.sprites.arrow)
                    arrow.x = self.x
                    arrow.y = self.y
                    -- TODO: don't hardcode arrow speed
                    local ARROW_SPEED = 250
                    arrow.xspd = sin(self.angle) * ARROW_SPEED
                    arrow.yspd = -cos(self.angle) * ARROW_SPEED
                    game.world:addMob(arrow)
                end
            elseif item.usage == 'pickaxe' then
                local make_sword = false
                if input:isMousePress(1) then make_sword = true end

                local msx, msy = self.cam:toWorld(mousePosition())
                local xx, yy = game.map:posToIdx(msx, msy)
                if xx and yy and Maph.distance(self.x, self.y, msx, msy) <
                    TOOL_REACH then
                    local wall = game.map:getWall(xx, yy)
                    local mob = game.map:getMob(xx, yy)
                    if wall then
                        -- break wall
                        make_sword = true
                        local drop = Item.new(Pack.Slot.new(wall, 1))
                        drop.x = xx * 16 - 8
                        drop.y = yy * 16 - 8
                        game.world:addMob(drop)
                        game.map:clearWall(xx, yy)
                    elseif mob then
                        -- break mob
                        make_sword = true
                        mob:onMine(self, game)
                    end
                end

                if make_sword then
                    self.slot_use_time = item.use_time
                    self:swingAttack(game, item)
                end
            elseif item.usage == 'shovel' then
                local make_sword = false
                if input:isMousePress(1) then make_sword = true end

                local msx, msy = self.cam:toWorld(mousePosition())
                local xx, yy = game.map:posToIdx(msx, msy)
                if xx and yy and Maph.distance(self.x, self.y, msx, msy) <
                    TOOL_REACH then
                    local tile = game.map:getTile(xx, yy)
                    if tile and tile ~= game.assets.items.dirt then
                        make_sword = true
                        local mob = Item.new(Pack.Slot.new(tile, 1))
                        mob.x = xx * 16 - 8
                        mob.y = yy * 16 - 8
                        game.world:addMob(mob)
                        game.map:setTile(game.assets.items.dirt, xx, yy)
                    end
                end

                if make_sword then
                    self.slot_use_time = item.use_time
                    local shovel = Spear.new(item, self)
                    shovel.reach = 16
                    game.world:addMob(shovel)
                    -- self:swingAttack(game, item)
                end
            elseif item.usage == 'seed' then
                local msx, msy = self.cam:toWorld(mousePosition())
                local xx, yy = game.map:posToIdx(msx, msy)
                if xx and yy and not game.map:isWall(xx, yy) and
                    Maph.distance(self.x, self.y, msx, msy) < TOOL_REACH and
                    not game.map:getMob(xx, yy) then
                    self.slot_use_time = item.use_time
                    self:swingAttack(game, item)
                    local crop = Crop.new(item)
                    crop.x = xx * 16 - 8
                    crop.y = yy * 16 - 8
                    game.world:addMob(crop)
                    slot:discard(1)
                end
            end
        end
    end
end

function Player:swingAttack(game, item)
    game.world:addMob(Sword.new(item, self, self.swing_dir))
    self.swing_dir = -self.swing_dir
end

function Player:tickMobInteractions(game)
    local INTERACTION_DIST = 32

    local bench = game.world:nearestTagged('interact', self.x, self.y)
    if bench and Maph.distance(self.x, self.y, bench.x, bench.y) <
        INTERACTION_DIST then
        self.interactor = bench
    else
        self.interactor = nil
    end
end

function Player:tickEquipment(game)
    self.equip_glow_range = 0
    self.max_hp = self.max_hp_base
    for i, slot in ipairs(self.equipment) do
        if slot.item then
            -- glowing
            if slot.item.equipment.light then
                self.equip_glow_range = self.equip_glow_range +
                                            slot.item.equipment.light.radius
            end
            -- max health
            if slot.item.equipment.max_hp_increase then
                self.max_hp = self.max_hp + slot.item.equipment.max_hp_increase
            end
        end
    end
    self.hp = min(self.hp, self.max_hp)
end

function Player:tickHudCam(game)
    self.hud_cam:setPosition(-love.graphics.getWidth() / 2,
                             -love.graphics.getHeight() / 2)
    self.hud_cam:setWorld(0, 0, love.graphics.getDimensions())
    self.hud_cam:setWindow(0, 0, love.graphics.getDimensions())
end

function Player:draw(game)
    if self.hurt_cooldown > 0 then
        local pre_shader = love.graphics.getShader()
        love.graphics.setShader(game.assets.shaders.white)
        game.assets.shaders.white:send('white_scale', min(
                                           self.hurt_cooldown /
                                               self.hurt_invincible_time, 1))
        Mob.draw(self, game)
        love.graphics.setShader(pre_shader)
    else
        Mob.draw(self, game)
    end

    -- draw path
    -- self.path:debugDraw()
end

function Player:drawLight(game)
    if self.equip_glow_range ~= 0 then
        local pre_color = {love.graphics.getColor()}
        love.graphics.setColor(0.75, 0.75, 0.75, 1)
        love.graphics
            .circle('fill', self.x, self.y, self.equip_glow_range * 0.8)
        love.graphics.setColor(0.37, 0.37, 0.37, 1)
        love.graphics.circle('fill', self.x, self.y, self.equip_glow_range)
        love.graphics.setColor(unpack(pre_color))
    end
end

--- Returns the player's save state.
function Player:save()
    local save = Mob.save(self)
    save.module = 'mob.player'
    save.hp = self.hp
    save.equipment = {}
    for i, slot in ipairs(self.equipment) do save.equipment[i] = slot:save() end
    save.pack = self.pack:save()

    return save
end

--- Returns a new 'Player' from the save state.
function Player.load(save, assets)
    local self = Mob.load(save, assets, Player.new(assets))
    self.hp = save.hp or self.max_hp
    for i, slot in ipairs(save.equipment) do
        self.equipment[i]:swap(Pack.Slot.load(slot, assets))
    end
    if save.pack then self.pack = Pack.load(save.pack, assets) end

    return self
end

return Player
