Input = require('input')
input = Input.new()
local Game = require('game')
local game

function love.load() game = Game.new() end
function love.update(dt)
    game:tick(dt)
    input:tick()
end
function love.draw() game:draw() end
function love.quit() game:quit() end
function love.keypressed(btn) input:keyPressed(btn) end
function love.keyreleased(btn) input:keyReleased(btn) end
function love.mousepressed(x, y, btn) input:mousePressed(btn) end
function love.mousereleased(x, y, btn) input:mouseReleased(btn) end
function love.wheelmoved(x, y) input:wheelMoved(x, y) end
