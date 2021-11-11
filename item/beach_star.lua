return {
    name = 'Beach Star',
    desc = 'Contains the essence of a beach',
    sprite = 'beach_star',
    usage = 'biome',
    biome = {
        title = 'Beach',
        radius = 256,
        spawn_timer_min = 30,
        spawn_timer_max = 60,
        spawn_max_enemies = 5,
        spawns = {
            {weight = 1, mob = 'mob.enemy.darter', count_min = 1, count_max = 3},
            {weight = 1, mob = 'mob.enemy.slime', count_min = 1, count_max = 3}
        },
        fill_walls = nil,
        fill_tiles = 'sand'
    }
}
