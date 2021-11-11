return {
    name = "Seed Machine",
    desc = "Creates seeds from crops",
    sprite = 'seed_machine',
    usage = 'bench',
    bench = {
        {
            time = 120,
            output = {item = 'pumpkin_seeds', count = 5},
            input = {{item = 'pumpkin', count = 1}}
        },
        {
            time = 120,
            output = {item = 'corn_seeds', count = 4},
            input = {{item = 'corn', count = 1}}
        },
        {
            time = 120,
            output = {item = 'beet_seeds', count = 3},
            input = {{item = 'beet', count = 1}}
        }
    }
}
