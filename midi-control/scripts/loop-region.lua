-- loop-region.lua
-- Toggles native REAPER repeat/loop for the region currently under the
-- playhead. Only operates while REAPER is actively PLAYING — if playback
-- is stopped or paused, pressing this pedal does nothing at all, in
-- either direction. This prevents accidentally engaging a loop, or being
-- stuck unable to disable one, while not actually performing.
--
-- On ENABLE:  mutes the "Cues_Master" track (if found) and starts a
--             repeating spoken "looping" cue (see loop-voice-cue.lua).
-- On DISABLE: unmutes "Cues_Master" and plays a single spoken "unlooping"
--             cue once, through the Voice_Cue track (see voice-cue-lib.lua).

local CUES_TRACK_NAME = "Cues_Master"

-- Guard: only act while actually playing.
if reaper.GetPlayState() ~= 1 then
  return
end

local this_path  = ({reaper.get_action_context()})[2]
local script_dir = this_path:match("^(.*[/\\])")
local sep        = package.config:sub(1,1)

local VoiceCue = dofile(script_dir .. "voice-cue-lib.lua")
local UNLOOP_SAMPLE_PATH = script_dir .. ".." .. sep .. "samples" .. sep .. "unlooping.mp3"

local function findTrackByName(name)
  local count = reaper.CountTracks(0)
  for i = 0, count - 1 do
    local track = reaper.GetTrack(0, i)
    local _, track_name = reaper.GetTrackName(track)
    if track_name == name then
      return track
    end
  end
  return nil
end

local function setCuesMuted(muted)
  local track = findTrackByName(CUES_TRACK_NAME)
  if track then
    reaper.SetMediaTrackInfo_Value(track, "B_MUTE", muted and 1 or 0)
  end
end

local function startVoiceCueLoop()
  local voice_script = script_dir .. "loop-voice-cue.lua"
  local cmdID = reaper.AddRemoveReaScript(true, 0, voice_script, true)
  if cmdID ~= 0 then
    reaper.Main_OnCommand(cmdID, 0)
  end
end

local pos = reaper.GetPlayPosition()

if reaper.GetToggleCommandState(1068) == 1 then
  -- Repeat is on → disable it, restore the cues track, announce once
  reaper.Main_OnCommand(1068, 0)
  setCuesMuted(false)
  VoiceCue.playCueSample(UNLOOP_SAMPLE_PATH)
else
  -- Repeat is off → find the region under the playhead and loop it
  local found = false
  local i = 0
  while true do
    local retval, isrgn, start_pos, end_pos, name, _ = reaper.EnumProjectMarkers(i)
    if retval == 0 then break end
    if isrgn and pos >= start_pos and pos < end_pos then
      reaper.GetSet_LoopTimeRange(true, true, start_pos, end_pos, false)
      if reaper.GetToggleCommandState(1068) ~= 1 then
        reaper.Main_OnCommand(1068, 0)
      end
      setCuesMuted(true)
      startVoiceCueLoop()
      found = true
      break
    end
    i = i + 1
  end
  if not found then
    reaper.ShowConsoleMsg("[Live] Loop: playhead is not inside any region.\n")
  end
end