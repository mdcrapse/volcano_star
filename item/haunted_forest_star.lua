return {
    name = 'Haunted Forest Star',
    desc = 'Has an eerie glow',
    sprite = 'haunted_forest_star',
    usage = 'biome',
    biome = {
        title = 'Haunted Forest',
        radius = 512,
        is_dark = false,
        spawn_timer_min = 10,
        spawn_timer_max = 20,
        spawn_max_enemies = 5,
        spawns = {
            -- {weight = 1, mob = 'mob.enemy.shelly', count_min = 1, count_max = 3},
            -- {weight = 1, mob = 'mob.enemy.slime', count_min = 1, count_max = 3}
        },
        fill_walls = nil,
        fill_tiles = 'smoggy_water'
    }
}
