local max = math.max

local Light = {}
Light.__index = Light

--- World lighting, includes daytime and shadows.
function Light.new(width, height)
    return setmetatable({
        brightness = 0,
        canvas = love.graphics.newCanvas(width, height),
        night_color = {r = 17 / 255, g = 28 / 255, b = 68 / 255}
    }, Light)
end

function Light:tick(time) self.brightness = time.sunlight end

function Light:drawLighting(draw_shadows, draw_lights, width, height)
    if self.canvas:getWidth() ~= width or self.canvas:getHeight() ~= height then
        self.canvas = love.graphics.newCanvas(width, height)
    end

    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(self.brightness +
                            ((1 - self.brightness) * self.night_color.r),
                        self.brightness +
                            ((1 - self.brightness) * self.night_color.g),
                        self.brightness +
                            ((1 - self.brightness) * self.night_color.b))
    draw_shadows()
    love.graphics.setBlendMode('lighten', 'premultiplied')

    draw_lights()

    love.graphics.setBlendMode('alpha')
    love.graphics.setCanvas()

    love.graphics.setBlendMode('multiply', 'premultiplied')
    love.graphics.draw(self.canvas)
    love.graphics.setBlendMode('alpha')
end

return Light
