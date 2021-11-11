--- Provides methods to check if buttons were pressed or released.
local Input = {}
Input.__index = Input

function Input.new()
    return setmetatable({
        pre_keys = {},
        keys = {},
        keys_up = {},
        pre_ms = {},
        ms = {},
        ms_up = {},
        scroll = 0
    }, Input)
end

--- Updates the `Input` should be called at the end of `love.update`.
function Input:tick()
    for k in pairs(self.pre_keys) do self.pre_keys[k] = nil end
    for k in pairs(self.keys) do self.pre_keys[k] = true end
    for k in pairs(self.keys_up) do
        self.keys[k] = nil
        self.keys_up[k] = nil
    end

    for k in pairs(self.pre_ms) do self.pre_ms[k] = nil end
    for k in pairs(self.ms) do self.pre_ms[k] = true end
    for k in pairs(self.ms_up) do
        self.ms[k] = nil
        self.ms_up[k] = nil
    end

    self.scroll = 0
end

--- Returns `true` if the specified key was just pressed.
function Input:isKeyPress(btn) return not self.pre_keys[btn] and self.keys[btn] end

--- Returns `true` if the specified key is being pressed.
function Input:isKeyDown(btn) return self.keys[btn] end

--- Returns `true` if the specified key was just released.
function Input:isKeyRelease(btn) return
    self.pre_keys[btn] and not self.keys[btn] end

--- Returns `true` if the specified mouse button was just pressed.
function Input:isMousePress(btn) return not self.pre_ms[btn] and self.ms[btn] end

--- Returns `true` if the specified mouse button is being pressed.
function Input:isMouseDown(btn) return self.ms[btn] end

--- Returns `true` if the specified mouse button was just released.
function Input:isMouseRelease(btn) return self.pre_ms[btn] and not self.ms[btn] end

--- Returns the mouse wheel direction (can positive or negative).
function Input:wheel()
    return self.scroll
end

--- Should be called in `love.mousepressed`.
function Input:mousePressed(btn) self.ms[btn] = true end

--- Should be called in `love.mousereleased`.
function Input:mouseReleased(btn) self.ms_up[btn] = true end

--- Should be called in `love.keypressed`.
function Input:keyPressed(btn) self.keys[btn] = true end

--- Should be called in `love.keyreleased`.
function Input:keyReleased(btn) self.keys_up[btn] = true end

--- Should be called in `love.wheelmoved`.
function Input:wheelMoved(_x, y)
    self.scroll = self.scroll + y
end

return Input
