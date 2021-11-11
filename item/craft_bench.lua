return {
    name = "Craft Bench",
    desc = "For crafting benches",
    sprite = 'craft_bench',
    usage = 'bench',
    bench = {
        {
            time = 30,
            output = {item = 'craft_bench', count = 1},
            input = {{item = 'wood', count = 20}, {item = 'stone', count = 5}}
            -- }, {
            --     time = 0,
            --     output = {item = 'upgrade_bench', count = 1},
            --     input = {{item = 'stone', count = 2}}
        }, {
            time = 60,
            output = {item = 'furnace', count = 1},
            input = {
                {item = 'stone', count = 15}, {item = 'copper', count = 5},
                {item = 'wood', count = 5}
            }
        }, {
            time = 60,
            output = {item = 'weapon_bench', count = 1},
            input = {
                {item = 'iron_bar', count = 1},
                {item = 'copper_bar', count = 3}, {item = 'wood', count = 10}
            }
        }, {
            time = 60,
            output = {item = 'saw_bench', count = 1},
            input = {
                {item = 'stone', count = 3}, {item = 'iron_bar', count = 1},
                {item = 'wood', count = 5}
            }
        }, {
            time = 60,
            output = {item = 'seed_machine', count = 1},
            input = {
                {item = 'gold_bar', count = 1}, {item = 'copper_bar', count = 3}
            }
        }, {
            time = 60,
            output = {item = 'compost_bin', count = 1},
            input = {
                {item = 'wood', count = 10}, {item = 'iron_bar', count = 1}
            }
        }, {
            time = 30,
            output = {item = 'chest', count = 1},
            input = {
                {item = 'wood', count = 10}, {item = 'iron_bar', count = 1}
            }
        }, {
            time = 15,
            output = {item = 'torch', count = 1},
            input = {{item = 'wood', count = 5}}
        }, {
            time = 120,
            output = {item = 'lantern', count = 1},
            input = {
                {item = 'wood', count = 10}, {item = 'iron_bar', count = 1}
            }
        }
    }
}
