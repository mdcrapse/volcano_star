return {
    name = "Upgrade Bench",
    desc = "For upgrading tools",
    sprite = 'upgrade_bench',
    usage = 'bench',
    bench = {
        {
            time = 0,
            output = {item = 'iron', count = 1},
            input = {{item = 'stone', count = 2}}
        }, {
            time = 10,
            output = {item = 'gold', count = 1},
            input = {{item = 'stone', count = 1}, {item = 'grass', count = 10}}
        }
    }
}
