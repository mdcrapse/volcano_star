local Light = require('light')
local Music = require('music')
local Map = require('map')
local Player = require('mob.player')
local Assets = require('assets')
local World = require('world')
local Time = require('time')
local serpent = require('serpent')
local TerrainGeneration = require('terrain_generation')
local max, min, floor = math.max, math.min, math.floor

local Game = {}
Game.__index = Game

--- Returns a newly created game. Should be called in `love.load`.
function Game.new()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local assets = Assets.new()
    love.graphics.setFont(assets.fonts.tic_80_wide)
    local music = Music.new()
    music:play(assets.songs.day_of_a_witch)
    local map = Map.new(assets, 200, 200)
    local world = World.new()
    local player = Player.new(assets)
    player.x = map.width * 16 / 2
    player.y = map.height * 16 / 2
    world:addMob(player)
    world:addMob(player.camera)

    -- TerrainGeneration.generateTerrarin(assets, map, world)

    local self = setmetatable({
        assets = assets,
        time = Time.new(),
        light = Light.new(love.graphics.getDimensions()),
        music = music,
        map = map,
        world = world,
        player = player,
        --- Multithreaded saving.
        save_thread = love.thread.newThread([[
            local serpent = require('serpent')
            local save = ...
            local data = serpent.dump(save, {sortkeys = true})

            local file = love.filesystem.newFile('save.lua')
            file:open('w')
            file:write(data)
            file:close()
        ]]),
        --- How often the game auto saves. (every fifteen minutes)
        save_wait = 15 * 60,
        save_timer = 15 * 60
    }, Game)

    self:loadGameFile()

    return self
end

function Game:tick(dt)
    -- tick cam zoom scales
    local w, h = love.graphics.getDimensions()
    self.player.cam:setScale(max(min(floor(w / 270), floor(h / 270)), 1))
    self.player.hud_cam:setScale(max(min(floor(w / 270), floor(h / 270)), 1))

    self.player.hud.w, self.player.hud.h =
        love.graphics.getWidth() / self.player.hud_cam:getScale(),
        love.graphics.getHeight() / self.player.hud_cam:getScale()
    if self.player.is_alive then self.player.hud:tick(dt, self) end
    self.world:tick(dt, self)
    self.map:resetMobCells(self.world)
    self.music:tick(dt)
    self.light:tick(self.time)
    self.time:tick(dt)

    -- player respawn
    if not self.player.is_alive then
        self.player.respawn_timer = math.max(self.player.respawn_timer - dt, 0)
        if self.player.respawn_timer <= 0 then
            self.player:respawn(self.map.width * 16 / 2,
                                self.map.height * 16 / 2)
            self.world:addMob(self.player) -- player is re-added to the world
        end
    end

    -- toggle fullscreen
    if input:isKeyPress('f1') then
        love.window.setFullscreen(not love.window.getFullscreen())
    end

    -- debug save game
    if input:isKeyPress('p') then self:saveGameFile() end

    -- debug load game
    if input:isKeyPress('o') then self:loadGameFile() end

    -- auto save
    self.save_timer = max(self.save_timer - dt, 0)
    if self.save_timer <= 0 then
        self.save_timer = self.save_wait
        self:saveGameFile()
    end

    -- makes sure saving went okay
    local error = self.save_thread:getError()
    assert(not error, error)
end

function Game:draw()
    -- draw world
    local function camDraw(x, y, w, h)
        self.map:drawTiles(self.assets, x, y, w, h)
        self.world:draw(self)
        self.map:drawWalls(self.assets, x, y, w, h)
        self.world:drawOverWalls(self)
    end
    self.player.cam:draw(camDraw)

    -- draw lighting
    local function shadeDraw() self.world:drawShade(self) end

    local function lightDraw()
        local color = {love.graphics.getColor()}
        love.graphics.setColor(1, 1, 1)
        self.world:drawLight(self)
        love.graphics.setColor(color)
    end

    self.light:drawLighting(function() self.player.cam:draw(shadeDraw) end,
                            function() self.player.cam:draw(lightDraw) end,
                            love.graphics.getDimensions())

    -- self.light:beginDraw(love.graphics.getDimensions())
    -- self.player.cam:draw(lightDraw)
    -- self.light:endDraw()

    -- draw hud

    local function hudDraw()
        if self.player.is_alive then self.player.hud:draw(self) end
        if self.save_thread:isRunning() then
            love.graphics.print('saving',
                                love.graphics.getWidth() /
                                    self.player.hud_cam:getScale() / 2 -
                                    love.graphics.getFont():getWidth('saving'),
                                1)
        end
    end
    self.player.hud_cam:draw(hudDraw)

    if input:isKeyDown('f') then love.graphics.print(love.timer.getFPS()) end
end

function Game:quit()
    self:saveGameFile()
    -- makes sure the game saves before closing
    self.save_thread:wait()
end

--- Returns the game's save state.
function Game:save()
    -- saves player if the player is dead
    local player = nil
    if not self.player.is_alive then player = self.player:save() end
    return {
        time = self.time:save(),
        map = self.map:save(),
        world = self.world:save(),
        player = player
    }
end

--- Loads the save state.
function Game:load(save)
    self.time = Time.load(save.time)
    self.map = Map.load(save.map, self.assets)
    self.world = World.load(save.world, self.assets)

    if save.player then
        self.player = Player.load(save.player, self.assets)
        self.player.camera.x = self.player.x
        self.player.camera.y = self.player.y
        self.world:addMob(self.player)
        self.world:addMob(self.player.camera)
    else
        local player = nil
        for mob in pairs(self.world:tagged('player')) do
            player = mob
            player.camera.x = player.x
            player.camera.y = player.y
            self.world:addMob(player.camera)
            break
        end
        if player then
            self.player = player
        else
            self.player = Player.new(self.assets)
            self.player.x = self.map.width * 16 / 2
            self.player.y = self.map.height * 16 / 2
            self.world:addMob(self.player)
            self.world:addMob(self.player.camera)
        end
    end
end

--- Saves the game to file.
function Game:saveGameFile()
    local save = self:save()
    -- makes sure the previous save is done
    self.save_thread:wait()
    self.save_thread:start(save)
end

--- Loads the game from file.
function Game:loadGameFile()
    self.save_thread:wait() -- makes sure saving is done
    local file = love.filesystem.newFile('save.lua')
    file:open('r')
    local data = file:read()
    file:close()
    local result, save = serpent.load(data)
    self:load(save)
end

return Game
