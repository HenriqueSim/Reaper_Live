-- voice-cue-lib.lua
-- Shared helper — NOT a standalone action. Loaded via dofile() by
-- loop-region.lua and loop-voice-cue.lua. Running this file directly from
-- the action list does nothing visible; it's a library, not a trigger.

local M = {}

local OUTPUT_TRACK_NAME = "Voice_Cue"

function M.findTrackByName(name)
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

-- Plays a sample (absolute path) through the Voice_Cue track's own routing.
-- Refuses to play — logging to console instead — if that track can't be
-- found, to avoid ever falling back to a default output that might reach FOH.
function M.playCueSample(sample_path)
  local source = reaper.PCM_Source_CreateFromFile(sample_path)
  if not source then
    reaper.ShowConsoleMsg("[Live] Voice cue: could not load " .. sample_path .. "\n")
    return
  end

  local out_track = M.findTrackByName(OUTPUT_TRACK_NAME)
  if not out_track then
    reaper.PCM_Source_Destroy(source)
    reaper.ShowConsoleMsg(
      "[Live] Voice cue: track '" .. OUTPUT_TRACK_NAME ..
      "' not found — sample NOT played to avoid risk of it reaching FOH.\n")
    return
  end

  local preview = reaper.CF_CreatePreview(source)
  reaper.PCM_Source_Destroy(source)  -- preview keeps its own reference
  reaper.CF_Preview_SetValue(preview, "D_VOLUME", 1.0)
  reaper.CF_Preview_SetOutputTrack(preview, 0, out_track)
  reaper.CF_Preview_Play(preview)
end

return M