return {
    name = "Furnace",
    desc = "For smelting materials",
    sprite = 'furnace',
    usage = 'bench',
    bench = {
        {
            time = 30,
            output = {item = 'copper_bar', count = 1},
            input = {{item = 'copper', count = 3}}
        }, {
            time = 60,
            output = {item = 'iron_bar', count = 1},
            input = {{item = 'iron', count = 3}}
        }, {
            time = 120,
            output = {item = 'gold_bar', count = 1},
            input = {{item = 'gold', count = 3}}
        }
    }
}
