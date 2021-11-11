return {
    name = "Compost Bin",
    desc = "Used for creating compost",
    sprite = 'compost_bin',
    usage = 'bench',
    bench = {
        {
            time = 180,
            output = {item = 'compost', count = 1},
            input = {{item = 'pumpkin', count = 1}}
        }, {
            time = 180,
            output = {item = 'compost', count = 1},
            input = {{item = 'corn', count = 3}}
        }, {
            time = 180,
            output = {item = 'compost', count = 1},
            input = {{item = 'beet', count = 5}}
        }
    }
}
