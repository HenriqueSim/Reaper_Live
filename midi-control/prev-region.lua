-- prev-region.lua
-- Pad 5 action: jump to the start of the previous region.
-- "Previous" means the nearest region whose start is more than 0.2s before
-- the current play position (so tapping at the very start of a region goes
-- to the one before it, not the same one).

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
for j = #regions, 1, -1 do
  if regions[j].start_pos < pos - 0.2 then
    target = regions[j]
    break
  end
end

if target then
  reaper.SetEditCurPos(target.start_pos, true, true)
end
