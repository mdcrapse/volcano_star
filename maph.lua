local min, max, sqrt, abs, atan2, pi = math.min, math.max, math.sqrt, math.abs,
                                      math.atan2, math.pi

--- Contains some basic math functions.
--- The reason for the naming is to avoide the standard `math` module from lua.
local Maph = {}

function Maph.moveToward(from, to, delta)
    if abs(to - from) <= delta then return to end
    return from + Maph.sign(to - from) * delta
end

function Maph.clamp(value, min, max) return min(max(value, min), max) end

function Maph.sign(x) return (x > 0 and 1) or (x == 0 and 0) or -1 end

function Maph.normalized(x, y)
    local len = sqrt(x * x + y * y)
    if len == 0 then return 0, 0 end
    return x / len, y / len
end

function Maph.angle(x, y) return atan2(x, -y) end

function Maph.angleTo(x, y, x2, y2) return Maph.angle(x2 - x, y2 - y) end

function Maph.distance(x, y, x2, y2)
    return sqrt((x - x2) * (x - x2) + (y - y2) * (y - y2))
end

--- Returns the hypotenuse (distance) of the two sides of the triangle.
function Maph.hypot(x, y)
    return sqrt(x * x + y * y)
end

return Maph
