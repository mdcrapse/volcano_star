return {
    name = 'Forest Star',
    desc = "The most powerful biome star, this shouldn't be in your pack",
    sprite = 'null_item',
    usage = 'biome',
    biome = {
        title = 'Forest',
        radius = 256,
        spawn_timer_min = 60,
        spawn_timer_max = 120,
        spawn_max_enemies = 3,
        spawns = {
            {weight = 1, mob = 'mob.enemy.slime', count_min = 1, count_max = 2}
        },
        fill_walls = nil,
        fill_tiles = 'grass'
    }
}
