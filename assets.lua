local Assets = {}
Assets.__index = Assets

--- Returns the default item use time based on the usage.
local function itemUsageTime(usage)
    if usage == 'tile' or usage == 'wall' or usage == 'bench' then
        return 0.1
    else
        return 0.25
    end
end

local function validateBench(bench, items)
    for i, recipe in ipairs(bench) do
        if recipe.output then
            local slot = recipe.output
            slot.item = items[slot.item or 'null_item']
            slot.count = slot.count or 1
        end
        if recipe.input then
            for i, slot in ipairs(recipe.input) do
                slot.item = items[slot.item or 'null_item']
                slot.count = slot.count or 1
            end
        end
    end

    return bench
end

local function validateSeed(seed, items)
    seed.grow_time = seed.grow_time or 5
    seed.produce = items[seed.produce or 'null_item']

    return seed
end

local function validateTile(tile)
    tile.friction = tile.friction or 1

    return tile
end

local function validateBiome(biome, items)
    biome.title = biome.title or 'Default Biome Title'
    biome.radius = biome.radius or 256
    biome.is_dark = biome.is_dark or false
    biome.spawn_timer_min = biome.spawn_timer_min or 5
    biome.spawn_timer_max = biome.spawn_timer_max or 10
    biome.spawn_max_enemies = biome.spawn_max_enemies or 10
    biome.spawns = biome.spawns or {}
    for i, spawn in ipairs(biome.spawns) do
        spawn.weight = spawn.weight or 1
        --- What mob to spawn.
        spawn.mob = spawn.mob or 'mob.enemy.slime'
        spawn.count_min = spawn.count_min or 1
        spawn.count_max = spawn.count_max or 1
    end

    -- terrain
    if biome.fill_walls then -- may be `nil`
        biome.fill_walls = items[biome.fill_walls]
    end
    biome.fill_tiles = items[biome.fill_tiles or 'grass']

    return biome
end

local function validateTorch(torch)
    torch.radius = torch.radius or 32
    torch.color = torch.color or {1, 0.8, 0.7}
    torch.night_glow = torch.night_glow or false -- only glow at night
    return torch
end

local function validateFood(food)
    food.heals = food.heals or 100
    return food
end

local function validateItem(item, id, sprites, items)
    item.id = id
    item.name = item.name or 'Default Name'
    item.desc = item.desc or ''
    item.sprite = sprites[item.sprite or 'null_item']
    -- none, tile, wall, sword, pickaxe, bench, seed, spear, chest, torch, tree_seeds, starbit, equipment, bomb, food
    item.usage = item.usage or 'none'
    item.stack_size = item.stack_size or 100
    --- Use time in seconds.
    item.use_time = item.use_time or itemUsageTime(item.usage)
    item.can_upgrade = item.can_upgrade or false
    item.bench = validateBench(item.bench or {}, items)
    item.seed = validateSeed(item.seed or {}, items)
    item.tile = validateTile(item.tile or {})
    item.biome = validateBiome(item.biome or {}, items)
    item.torch = validateTorch(item.torch or {})
    item.equipment = item.equipment or {}
    item.food = validateFood(item.food or {})
end

--- Loads and returns all the game assets. Should be called in `love.load`.
function Assets.new()
    local self = setmetatable({}, Assets)

    self.sprites = Assets.loadGroup('sprite', '.png', function(path)
        return love.graphics.newImage(path)
    end)

    self.songs = Assets.loadGroup('song', '.wav', function(path)
        return love.sound.newDecoder(path)
    end)

    -- items are loaded then validated, so they can reference each other
    self.items = Assets.loadGroup('item', '.lua',
                                  function(path) return dofile(path) end)
    for id, item in pairs(self.items) do
        validateItem(item, id, self.sprites, self.items)
    end

    self.fonts = Assets.loadGroup('font', '.ttf', function(path)
        -- HACK: handle multiple font sizes
        return love.graphics.newFont(path, 6)
    end)

    self.shaders = Assets.loadGroup('shader', '.glsl', function(path)
        return love.graphics.newShader(path)
    end)

    return self
end

--- Returns the result of `load_asset` on all the files in the `path` directory with the specified extension.
function Assets.loadGroup(path, extension, load_asset)
    local group = {}
    local files = love.filesystem.getDirectoryItems(path)
    for _i, file in ipairs(files) do
        if file:sub(-#extension) == extension then
            local name = string.sub(file, 1,
                                    string.len(file) - string.len(extension))
            -- -- debug printing
            -- print((#group + 1) .. ". path: " .. path .. '/' .. file ..
            --           ". name: " .. name)
            local asset = load_asset(path .. '/' .. file)
            group[name] = asset
        end
    end
    return group
end

return Assets
