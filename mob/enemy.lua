local Mob = require('mob')
local Maph = require('maph')
local max, min = math.max, math.min

local Enemy = {}
Enemy.__index = Enemy
setmetatable(Enemy, {__index = Mob})

function Enemy.new()
    local self = Mob.new()
    self.tags.shove = true
    self.tags.enemy = true
    self.hp = 100
    self.hurt_anim_time = 0
    --- The current mob then enemy is pursuing
    self.target = nil
    --- Whether or not the enemy can see its target.
    self.can_see_target = false
    --- Targets every mob with any of the specified tags.
    self.target_tags = {'player'}
    --- How much the enemy is knocked back when hit.
    self.hurt_knockback = 100
    --- The distance from the nearest player for the mob to despawn.
    self.despawn_dist = 480
    --- The amount of time it takes for the mob to check if it can see the target.
    self.can_see_wait = 0.5
    self.can_see_timer = 0

    return self
end

function Enemy:tick(dt, game)
    self:findTarget(game)

    if self.target then
        self.can_see_timer = max(self.can_see_timer - dt, 0)
        if self.can_see_timer <= 0 then
            self.can_see_timer = self.can_see_wait
            self.can_see_target = game.map:isLineClear(self.x, self.y,
                                                       self.target.x,
                                                       self.target.y)
        end
    else
        self.can_see_target = false
    end

    self.hurt_anim_time = max(self.hurt_anim_time - dt, 0)

    -- despawn when away from players
    local is_near_player = false
    for player in pairs(game.world:tagged('player')) do
        if Maph.distance(self.x, self.y, player.x, player.y) < self.despawn_dist then
            is_near_player = true
            break
        end
    end
    if self.is_alive then self.is_alive = is_near_player end
end

function Enemy:hurt(game, damage, attacker)
    -- hurt animation
    self.hurt_anim_time = 0.25

    -- knockback
    local dir_x, dir_y = Maph.normalized(self.x - attacker.x,
                                         self.y - attacker.y)
    self.xspd = self.xspd + dir_x * self.hurt_knockback
    self.yspd = self.yspd + dir_y * self.hurt_knockback

    -- hurt/kill
    self.hp = max(self.hp - damage, 0)
    if self.hp <= 0 then self:kill(game, attacker) end
end

--- Kills the enemy. `attacker` may be `nil`.
function Enemy:kill(game, attacker) self.is_alive = false end

function Enemy:findTarget(game)
    self.target = game.world:nearestTagged('player', self.x, self.y)
    -- if not self.target then
    --     -- find new target
    --     for i, tag in ipairs(self.target_tags) do
    --         for mob, _ in pairs(game.world:tagged(tag)) do
    --             if game.map:isLineClear(self.x, self.y, mob.x, mob.y) then
    --                 self.target = mob
    --                 return nil
    --             end
    --         end
    --     end
    -- else
    --     -- reset target if target is dead
    --     if not self.target.is_alive then
    --         self.target = nil
    --         return nil
    --     end

    --     -- reset target if can't see
    --     if not self.can_see_target then self.target = nil end
    -- end
end

function Enemy:draw(game)
    if self.hurt_anim_time > 0 then
        local pre_shader = love.graphics.getShader()
        love.graphics.setShader(game.assets.shaders.white)
        game.assets.shaders.white:send('white_scale',
                                       min(self.hurt_anim_time * 4, 1))
        Mob.draw(self, game)
        love.graphics.setShader(pre_shader)
    else
        Mob.draw(self, game)
    end
end

return Enemy
