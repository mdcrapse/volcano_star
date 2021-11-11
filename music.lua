--- Plays music and handles song transitions.
local Music = {}
Music.__index = Music

function Music.new()
    return setmetatable({
        data = nil, --- The sound stream.
        source = nil, --- The emitting sound.
        next_song = nil, --- Used for smooth song transitions.
        volume = 1, --- Music volume.
        volume_tween = 1.0, -- Used for changing songs.
        state = 'idle' --- Used for smooth song transitions.
    }, Music)
end

--- Plays the specified song.
--- Pass `nil` to play nothing.
--- @param song love.Decoder # The song to play, must be streamed.
function Music:play(song)
    if self.data == song and self.state ~= 'ending' then return nil end

    self.next_song = song
    self.state = 'ending'
end

function Music:setSong(song)
    if self.source then self.source:stop() end

    if song then
        self.data = song
        self.source = love.audio.newSource(song, "stream")
        self.source:setVolume(self.volume)
        self.source:setLooping(true)
        self.source:play()
    else
        self.data = nil
        self.source = nil
    end
end

function Music:tick(dt)
    if self.state == 'idle' then
        if self.source and self.source:getVolume() ~= self.volume then
            self.source:setVolume(self.volume)
        end
    elseif self.state == 'ending' then
        self.volume_tween = math.max(self.volume_tween - dt, 0)
        if self.source then
            self.source:setVolume(self.volume_tween * self.volume)
        end
        if self.volume_tween <= 0 then
            self.state = 'starting'
            self:setSong(self.next_song)
        end
    elseif self.state == 'starting' then
        self.volume_tween = math.min(self.volume_tween + dt, 1)
        if self.source then
            self.source:setVolume(self.volume_tween * self.volume)
        end
        if self.volume_tween >= 1 then self.state = 'idle' end
    end
end

return Music
