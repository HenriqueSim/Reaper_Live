-- loop-region.lua
-- Pad 3 action: if repeat is OFF, sets loop points to current region and enables repeat.
--               if repeat is ON, disables repeat.

local pos = reaper.GetPlayPosition()

if reaper.GetToggleCommandState(1068) == 1 then
  -- Repeat is on → turn it off
  reaper.Main_OnCommand(1068, 0)
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
      found = true
      break
    end
    i = i + 1
  end
  if not found then
    reaper.ShowConsoleMsg("[Live] Loop: playhead is not inside any region.\n")
  end
end
