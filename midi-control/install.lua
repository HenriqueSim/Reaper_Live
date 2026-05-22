-- install.lua
-- Run this ONCE from REAPER's action list after placing this folder in your Scripts directory.
-- It will:
--   1. Register the 5 action scripts permanently in REAPER
--   2. Generate realearn-preset.json with the correct command IDs for YOUR installation
--   3. Tell you exactly what to do next

-- ── Locate the scripts/ folder relative to this file ────────────────────────
local this_file = ({reaper.get_action_context()})[2]
local base_dir  = this_file:match("^(.*[/\\])")  -- everything up to the last separator

local scripts_dir = base_dir .. "scripts" .. (package.config:sub(1,1))  -- OS separator

-- ── Scripts to register ─────────────────────────────────────────────────────
local scripts = {
  { file = "loop-region.lua",       label = "Loop Region Toggle"  },
  { file = "goto-region-start.lua", label = "Go To Region Start"  },
  { file = "prev-region.lua",       label = "Previous Region"     },
  { file = "next-region.lua",       label = "Next Region"         },
  { file = "panic.lua",             label = "Panic — Stop All"    },
}

local named_ids = {}  -- { file -> "_RSxxxxxxxx" }

for _, s in ipairs(scripts) do
  local full_path = scripts_dir .. s.file
  local numeric_id = reaper.AddRemoveReaScript(true, 0, full_path, true)
  if numeric_id == 0 then
    reaper.ShowMessageBox(
      "Could not register:\n" .. full_path ..
      "\n\nMake sure the scripts/ folder is in the same directory as install.lua " ..
      "and all five .lua files are present.",
      "Setup Error", 0)
    return
  end
  -- Get the permanent named ID (e.g. "RSa1b2c3d4...")
  local named = reaper.ReverseNamedCommandLookup(numeric_id) or ""
  if named == "" then
    reaper.ShowMessageBox("Could not get named ID for: " .. s.file, "Setup Error", 0)
    return
  end
  named_ids[s.file] = "_" .. named  -- ReaLearn expects the leading underscore
end

-- ── Generate realearn-preset.json ───────────────────────────────────────────
-- Pad notes (MIDI channel 10 = index 9, all decimal):
--   Bottom row: 32(Pad1 Play/Pause)  50(Pad2 Stop)  52(Pad3 Loop)  53(Pad4 GoToStart)
--   Top row:    55(Pad5 PrevRegion)  57(Pad6 NextRegion)  59(Pad7 Panic)  60(Pad8 spare)

local function json_str(s) return '"' .. s .. '"' end

local preset = string.format([[{
  "version": "2.16.0",
  "name": "MPK Mini Play - Live Band Controls",
  "mappings": [
    {
      "id": "m1",
      "name": "Pad 1 — Play / Pause  (LED: on while playing/paused)",
      "source": { "kind": "MidiNoteVelocity", "channel": 9, "key_number": 32 },
      "target": { "kind": "TransportAction", "action": "PlayPause" },
      "feedback_is_enabled": true
    },
    {
      "id": "m2",
      "name": "Pad 2 — Stop",
      "source": { "kind": "MidiNoteVelocity", "channel": 9, "key_number": 50 },
      "target": { "kind": "TransportAction", "action": "Stop" },
      "feedback_is_enabled": false
    },
    {
      "id": "m3-action",
      "name": "Pad 3 — Loop Region (trigger)",
      "source": { "kind": "MidiNoteVelocity", "channel": 9, "key_number": 52 },
      "target": { "kind": "ReaperAction", "command": %s, "invocation_type": "Trigger" },
      "feedback_is_enabled": false
    },
    {
      "id": "m3-led",
      "name": "Pad 3 — Loop LED (reflects Repeat state, input disabled)",
      "is_enabled": false,
      "source": { "kind": "MidiNoteVelocity", "channel": 9, "key_number": 52 },
      "target": { "kind": "ReaperAction", "command": 1068 },
      "feedback_is_enabled": true
    },
    {
      "id": "m4",
      "name": "Pad 4 — Go To Region Start",
      "source": { "kind": "MidiNoteVelocity", "channel": 9, "key_number": 53 },
      "target": { "kind": "ReaperAction", "command": %s, "invocation_type": "Trigger" },
      "feedback_is_enabled": false
    },
    {
      "id": "m5",
      "name": "Pad 5 — Previous Region",
      "source": { "kind": "MidiNoteVelocity", "channel": 9, "key_number": 55 },
      "target": { "kind": "ReaperAction", "command": %s, "invocation_type": "Trigger" },
      "feedback_is_enabled": false
    },
    {
      "id": "m6",
      "name": "Pad 6 — Next Region",
      "source": { "kind": "MidiNoteVelocity", "channel": 9, "key_number": 57 },
      "target": { "kind": "ReaperAction", "command": %s, "invocation_type": "Trigger" },
      "feedback_is_enabled": false
    },
    {
      "id": "m7",
      "name": "Pad 7 — Panic (Stop + All Notes Off)",
      "source": { "kind": "MidiNoteVelocity", "channel": 9, "key_number": 59 },
      "target": { "kind": "ReaperAction", "command": %s, "invocation_type": "Trigger" },
      "feedback_is_enabled": false
    }
  ]
}]],
  json_str(named_ids["loop-region.lua"]),
  json_str(named_ids["goto-region-start.lua"]),
  json_str(named_ids["prev-region.lua"]),
  json_str(named_ids["next-region.lua"]),
  json_str(named_ids["panic.lua"])
)

-- Write the file next to install.lua
local preset_path = base_dir .. "realearn-preset.json"
local f = io.open(preset_path, "w")
if not f then
  reaper.ShowMessageBox("Could not write to:\n" .. preset_path, "Setup Error", 0)
  return
end
f:write(preset)
f:close()

-- ── Done ────────────────────────────────────────────────────────────────────
reaper.ShowMessageBox(
  "Setup complete!\n\n" ..
  "✓ 5 action scripts registered in REAPER\n" ..
  "✓ realearn-preset.json written to:\n  " .. preset_path .. "\n\n" ..
  "─── Next steps ───────────────────────\n\n" ..
  "1. Install ReaLearn:\n" ..
  "   Extensions > ReaPack > Browse packages\n" ..
  "   Search 'ReaLearn' > Install > Apply\n\n" ..
  "2. Create a track named 'MIDI Control'\n" ..
  "   Set its MIDI output to: MPK mini Play\n\n" ..
  "3. Add ReaLearn as FX on that track\n\n" ..
  "4. In ReaLearn: click the import/load button\n" ..
  "   and open realearn-preset.json\n\n" ..
  "That's it. Pads are mapped and LEDs are live.",
  "Install Complete", 0)
