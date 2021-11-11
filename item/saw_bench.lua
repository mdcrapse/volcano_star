return {
    name = "Saw Bench",
    desc = "For making tiles and walls",
    sprite = 'saw_bench',
    usage = 'bench',
    bench = {
        {
            time = 30,
            output = {item = 'door', count = 1},
            input = {{item = 'wood', count = 10}}
        },
        {
            time = 10,
            output = {item = 'stone_bricks', count = 10},
            input = {{item = 'stone', count = 10}}
        }, {
            time = 10,
            output = {item = 'stone_slab', count = 10},
            input = {{item = 'stone', count = 10}}
        }, {
            time = 10,
            output = {item = 'wood_planks', count = 10},
            input = {{item = 'wood', count = 10}}
        }
    }
}
