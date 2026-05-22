-- goto-region-start.lua
-- Pad 4 action: jump to the start of the region the playhead is currently in.
-- Useful for restarting a section mid-way through.

local pos = reaper.GetPlayPosition()

local i = 0
while true do
  local retval, isrgn, start_pos, end_pos, _, _ = reaper.EnumProjectMarkers(i)
  if retval == 0 then break end
  if isrgn and pos >= start_pos and pos < end_pos then
    reaper.SetEditCurPos(start_pos, true, true)
    return
  end
  i = i + 1
end
