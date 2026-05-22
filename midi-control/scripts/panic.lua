-- panic.lua
-- Pad 7 action: immediate stop + all notes off.
-- Use when something goes wrong on stage.

reaper.Main_OnCommand(1016, 0)   -- Transport: Stop
reaper.Main_OnCommand(40345, 0)  -- SWS/BR: Send all notes off to all MIDI outputs
