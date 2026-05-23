-- next-region.lua
-- Jumps to the start of the next region and writes seekTarget for the web UI.

local pos = reaper.GetPlayPosition()

local regions = {}
local i = 0
while true do
  local retval, isrgn, start_pos, end_pos, name, idx = reaper.EnumProjectMarkers(i)
  if retval == 0 then break end
  if isrgn then table.insert(regions, { start_pos = start_pos, id = idx }) end
  i = i + 1
end

table.sort(regions, function(a, b) return a.start_pos < b.start_pos end)

local target = nil
for _, r in ipairs(regions) do
  if r.start_pos > pos + 0.2 then
    target = r
    break
  end
end

if target then
  reaper.SetEditCurPos(target.start_pos, true, true)
  reaper.SetExtState("ReaperSetlist", "seekTarget", tostring(target.id), false)
end
