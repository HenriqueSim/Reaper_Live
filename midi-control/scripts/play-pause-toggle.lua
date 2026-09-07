-- play-pause-toggle.lua
-- Starts or resumes playback ONLY. If REAPER is already playing, this does
-- nothing — protects against an accidental second press (e.g. mis-hit
-- pedal) stopping or pausing playback mid-song.

local state = reaper.GetPlayState()
-- 0 = stopped, 1 = playing, 2 = paused, 5 = recording, 6 = record-paused

if state == 0 or state == 2 then
  reaper.Main_OnCommand(40044, 0)   -- Transport: Play/stop — starts or resumes
end
-- If already playing (1) or recording (5/6), do nothing.