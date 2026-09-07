-- loop-voice-cue.lua
-- Started automatically by loop-region.lua the moment a loop is engaged.
-- Plays a spoken "looping" cue sample every INTERVAL_SECONDS while REAPER's
-- native repeat/loop remains ON. Stops itself automatically the instant
-- loop is turned off — no manual cleanup, no cost while no loop is active.

-- ── Configure this ────────────────────────────────────────────────────────
-- 4 bars at 120 BPM in 4/4 = 4 * 4 beats * (60/120) sec/beat = 8 seconds.
local INTERVAL_SECONDS = 8.0

local this_path  = ({reaper.get_action_context()})[2]
local script_dir = this_path:match("^(.*[/\\])")
local sep        = package.config:sub(1,1)

local VoiceCue = dofile(script_dir .. "voice-cue-lib.lua")
local SAMPLE_PATH = script_dir .. ".." .. sep .. "samples" .. sep .. "looping.mp3"

local last_play = -math.huge  -- forces an immediate first play

local function tick()
  if reaper.GetToggleCommandState(1068) ~= 1 then
    return  -- loop has been turned off — stop rescheduling, script ends here
  end

  local now = reaper.time_precise()
  if now - last_play >= INTERVAL_SECONDS then
    last_play = now
    VoiceCue.playCueSample(SAMPLE_PATH)
  end

  reaper.defer(tick)
end

tick()