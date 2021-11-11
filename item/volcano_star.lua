return {
    name = 'Volcano Star',
    desc = 'The star of the volcano',
    sprite = 'volcano_star',
    usage = 'biome',
    biome = {
        title = 'Volcano',
        radius = 1200,
        is_dark = true,
        spawn_timer_min = 3,
        spawn_timer_max = 8,
        spawn_max_enemies = 15,
        spawns = {
            {weight = 1, mob = 'mob.enemy.shelly', count_min = 1, count_max = 3},
            {weight = 1, mob = 'mob.enemy.slime', count_min = 1, count_max = 3}
        },
        fill_walls = 'stone',
        fill_tiles = 'dirt'
    }
}
