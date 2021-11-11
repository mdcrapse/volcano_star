return {
    name = "Tool Bench",
    desc = "For crafting tools",
    sprite = 'weapon_bench',
    usage = 'bench',
    bench = {
        {
            time = 180,
            output = {item = 'iron_pickaxe', count = 1},
            input = {
                {item = 'pickaxe', count = 1}, {item = 'iron_bar', count = 5}
            }
        }, {
            time = 300,
            output = {item = 'gold_pickaxe', count = 1},
            input = {
                {item = 'iron_pickaxe', count = 1},
                {item = 'gold_bar', count = 5}
            }
        }, {
            time = 60,
            output = {item = 'iron_shovel', count = 1},
            input = {
                {item = 'shovel', count = 1}, {item = 'iron_bar', count = 3}
            }
        }, {
            time = 120,
            output = {item = 'gold_shovel', count = 1},
            input = {
                {item = 'iron_shovel', count = 1},
                {item = 'gold_bar', count = 3}
            }
        }, {
            time = 60,
            output = {item = 'bomb', count = 1},
            input = {
                {item = 'wood', count = 1}, {item = 'copper_bar', count = 1}
            }
        }, {
            time = 60,
            output = {item = 'arrow', count = 10},
            input = {
                {item = 'wood', count = 5}, {item = 'copper_bar', count = 3}
            }
        }
    }
}
