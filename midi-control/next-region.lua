-- next-region.lua
-- Pad 6 action: jump to the start of the next region.

local pos = reaper.GetPlayPosition()

local regions = {}
local i = 0
while true do
  local retval, isrgn, start_pos, end_pos, name, _ = reaper.EnumProjectMarkers(i)
  if retval == 0 then break end
  if isrgn then
    table.insert(regions, { start_pos = start_pos, end_pos = end_pos })
  end
  i = i + 1
end

table.sort(regions, function(a, b) return a.start_pos < b.start_pos end)

local target = nil
for _, region in ipairs(regions) do
  if region.start_pos > pos + 0.2 then
    target = region
    break
  end
end

if target then
  reaper.SetEditCurPos(target.start_pos, true, true)
end
