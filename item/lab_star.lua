return {
    name = 'Lab Star',
    desc = 'Looks highly experimental',
    sprite = 'lab_star',
    usage = 'biome',
    biome = {
        title = 'Lab',
        radius = 256,
        is_dark = true,
        spawn_timer_min = 10,
        spawn_timer_max = 20,
        spawn_max_enemies = 5,
        spawns = {
            -- {weight = 1, mob = 'mob.enemy.shelly', count_min = 1, count_max = 3},
            -- {weight = 1, mob = 'mob.enemy.slime', count_min = 1, count_max = 3}
        },
        fill_walls = 'stone_bricks',
        fill_tiles = 'stone_slab'
    }
}
