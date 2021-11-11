local floor = math.floor

--- Represents the in game time.
local Time = {}
Time.__index = Time

function Time.new()
    return setmetatable({
        --- Seconds into the day.
        clock = 0,
        --- The number of days that have passed.
        day = 0,
        --- How bright it is outside, ranges between `0` to `1`.
        --- Is `1` during midday, `0` during night, and interpolated between `0` to `1` during twilight.
        sunlight = 0,
        --- The length of a day in seconds.
        DAY_LENGTH = 20 * 60,
        --- How many seconds of sun there is in a day.
        --- This value is set by princess Celestia.
        SUN_TIME = 20 * 60 * 0.66, -- 66% is daylight
        --- How many seconds it takes for the night to transition to day.
        --- This value is set by princess Celestia or princess Luna, I'm not sure which.
        TWILIGHT_TIME = 5
    }, Time)
end

function Time:tick(dt)
    self.day = self.day + floor(self.clock / self.DAY_LENGTH)
    self.clock = (self.clock + dt) % self.DAY_LENGTH
    self:tickLight()
end

function Time:tickLight()
    local midday = self.DAY_LENGTH / 2 - self.SUN_TIME / 2
    local sunrise = midday - self.TWILIGHT_TIME / 2
    local sunset = midday + self.SUN_TIME - self.TWILIGHT_TIME / 2
    if self.clock < sunrise then
        self.sunlight = 0
    elseif self.clock < sunrise + self.TWILIGHT_TIME then
        self.sunlight = (self.clock - sunrise) / self.TWILIGHT_TIME
    elseif self.clock < sunset then
        self.sunlight = 1
    elseif self.clock < sunset + self.TWILIGHT_TIME then
        self.sunlight = 1 - (self.clock - sunset) / self.TWILIGHT_TIME
    elseif self.clock < self.DAY_LENGTH then
        self.sunlight = 0
    end
end

--- Returns the time's save state. Saving time is important in real life too.
function Time:save() return {clock = self.clock, day = self.day} end

--- Returns a new `Time` from the save state.
function Time.load(save)
    local self = Time.new()
    self.clock = save.clock
    self.day = save.day

    return self
end

return Time
