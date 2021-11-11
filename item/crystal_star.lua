return {
    name = 'Crystal Star',
    desc = '',
    sprite = 'crystal_star',
    usage = 'biome',
    biome = {
        title = 'Crystal Cave',
        radius = 512,
        is_dark = true,
        spawn_timer_min = 10,
        spawn_timer_max = 20,
        spawn_max_enemies = 5,
        spawns = {
            -- {weight = 1, mob = 'mob.enemy.shelly', count_min = 1, count_max = 3},
            -- {weight = 1, mob = 'mob.enemy.slime', count_min = 1, count_max = 3}
        },
        fill_walls = 'stone',
        fill_tiles = 'grass'
    }
}
