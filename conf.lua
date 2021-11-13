function love.conf(t)
    t.window.title = "Volcano Star"
    t.identity = 'volcano_star'
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.video = false
    t.window.resizable = true
    t.window.vsync = 1
    -- t.console = true
end
