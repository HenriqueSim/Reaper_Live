-- prev-region.lua (v2)
-- Navigates to the previous region, chaining off seekTarget if set so that
-- rapid presses keep going back rather than returning to the same region.

local SECTION = "ReaperSetlist"

-- Collect and sort all regions
local regions = {}
local i = 0
while true do
  local retval, isrgn, start_pos, end_pos, name, idx = reaper.EnumProjectMarkers(i)
  if retval == 0 then break end
  if isrgn then
    table.insert(regions, { start_pos = start_pos, end_pos = end_pos, id = idx })
  end
  i = i + 1
end
table.sort(regions, function(a, b) return a.start_pos < b.start_pos end)

if #regions == 0 then return end

-- Determine reference: seekTarget region index if queued, otherwise play position
local target = nil
local seek_str = reaper.GetExtState(SECTION, "seekTarget")
local seek_id  = seek_str ~= "" and tonumber(seek_str) or nil

if seek_id then
  -- Find the seekTarget region in the sorted list, then take the one before it
  for j, r in ipairs(regions) do
    if r.id == seek_id then
      if j > 1 then
        target = regions[j - 1]
      end
      break
    end
  end
else
  -- No queue — use play position
  local pos = reaper.GetPlayPosition()
  for j = #regions, 1, -1 do
    if regions[j].start_pos < pos - 0.2 then
      target = regions[j]
      break
    end
  end
end

if target then
  reaper.SetEditCurPos(target.start_pos, true, true)
  reaper.SetExtState(SECTION, "seekTarget", tostring(target.id), false)
end