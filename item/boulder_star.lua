return {
    name = 'Boulder Star',
    desc = 'Very smooth boulder',
    sprite = 'volcano_star',
    usage = 'biome',
    biome = {
        title = 'Boulder',
        radius = 256,
        is_dark = true,
        spawn_timer_min = 2,
        spawn_timer_max = 5,
        spawn_max_enemies = 5,
        spawns = {
            {weight = 1, mob = 'mob.enemy.darter', count_min = 1, count_max = 3},
            {weight = 1, mob = 'mob.enemy.shelly', count_min = 1, count_max = 3},
            {weight = 1, mob = 'mob.enemy.slime', count_min = 1, count_max = 3}
        },
        fill_walls = 'stone',
        fill_tiles = 'dirt'
    }
}
