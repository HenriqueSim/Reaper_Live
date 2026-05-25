-- install.lua (v3 — matches verified Helgobox 2.18 export)
-- Run once from REAPER's action list after copying midi-control/ to your Scripts folder.

local this_file  = ({reaper.get_action_context()})[2]
local base_dir   = this_file:match("^(.*[/\\])")
local sep        = package.config:sub(1,1)
local scripts_dir = base_dir .. "scripts" .. sep

-- ── Register scripts ──────────────────────────────────────────────────────────
-- play-pause-toggle.lua is used for m1 instead of the native TransportAction
-- to avoid the "hold to play, release to pause" gate behaviour.
local scripts = {
  { file = "play-pause-toggle.lua",  label = "Play/Pause Toggle"   },
  { file = "loop-region.lua",        label = "Loop Region Toggle"  },
  { file = "goto-region-start.lua",  label = "Go To Region Start"  },
  { file = "prev-region.lua",        label = "Previous Region"     },
  { file = "next-region.lua",        label = "Next Region"         },
  { file = "panic.lua",              label = "Panic — Stop All"    },
}

local ids = {}  -- { file -> "RSxxxxxxxx" }  NO leading underscore

for _, s in ipairs(scripts) do
  local path = scripts_dir .. s.file
  local num  = reaper.AddRemoveReaScript(true, 0, path, true)
  if num == 0 then
    reaper.ShowMessageBox(
      "Could not register:\n" .. path ..
      "\n\nMake sure scripts/ folder is in the same directory as install.lua.",
      "Setup Error", 0)
    return
  end
  local named = reaper.ReverseNamedCommandLookup(num) or ""
  if named == "" then
    reaper.ShowMessageBox("Could not get ID for: " .. s.file, "Setup Error", 0)
    return
  end
  ids[s.file] = named
end

-- ── JSON helpers ──────────────────────────────────────────────────────────────
local function q(s) return '"' .. tostring(s) .. '"' end

-- Source block — same for all pads
local source_tpl = [[{
          "type":1,"channel":9,"number":%d,
          "isRegistered":false,"is14Bit":false,
          "oscArgIndex":0,"buttonIndex":0,
          "buttonDesign":{
            "background":{"kind":"Color"},
            "foreground":{"kind":"None"},
            "static_text":""
          }
        }]]

-- Default mode block
local mode_default = [[{
          "maxStepSize":0.05,"minStepFactor":1,"maxStepFactor":5
        }]]

-- Mode block with press-only (used for m1 Play/Pause)
local mode_press_only = [[{
          "maxStepSize":0.05,"minStepFactor":1,"maxStepFactor":5,
          "buttonUsage":"press-only"
        }]]

-- Target: native transport action (Stop)
local target_tpl_transport = [[{
          "type":16,"invocationType":0,
          "fxAnchor":"id","useSelectionGanging":false,"useTrackGrouping":false,
          "seekBehavior":"Immediate","transportAction":%s,
          "useProject":true,"moveView":true,"seekPlay":true,"oscArgIndex":0,
          "mouseAction":{"kind":"MoveTo","axis":"X"},
          "takeMappingSnapshot":{"kind":"LastLoaded"}
        }]]

-- Target: ReaScript action (all custom scripts + play-pause-toggle)
local target_tpl_action = [[{
          "type":0,"commandName":%s,"invocationType":0,
          "fxAnchor":"id","useSelectionGanging":false,"useTrackGrouping":false,
          "seekBehavior":"Immediate","useProject":true,
          "moveView":true,"seekPlay":true,"oscArgIndex":0,
          "mouseAction":{"kind":"MoveTo","axis":"X"},
          "takeMappingSnapshot":{"kind":"LastLoaded"}
        }]]

-- Build a mapping JSON object.
-- extra_fields: optional string of comma-prefixed extra JSON fields, e.g. ',"feedbackIsEnabled":false'
local function mapping(id, name, note, target, mode_block, extra_fields)
  mode_block   = mode_block   or mode_default
  extra_fields = extra_fields or ""
  return string.format([[      {
        "id":%s,"name":%s,
        "source":%s,
        "mode":%s,
        "target":%s%s
      }]],
    q(id), q(name),
    string.format(source_tpl, note),
    mode_block,
    target,
    extra_fields)
end

-- ── Pad layout (Bank A, channel 10 = index 9) ─────────────────────────────────
-- Bottom row: Play/Pause(48)  Stop(50)  Loop(52)  GoToStart(53)
-- Top    row: PrevRegion(55)  NextRegion(57)  Panic(59)  [spare](60)

-- Feedback-only mapping for Pad 3: reflects REAPER's repeat state back to pad LED.
-- controlIsEnabled:false means it never fires the action, only reads state for feedback.
-- Note: MPK mini Play mk3 does not support MIDI-controlled LEDs, so this has no
-- visible effect on the hardware, but is kept for completeness and future-proofing.
local loop_led_mapping = string.format([[      {
        "id":"loop-led","name":"Pad 3 — Loop LED (feedback only)",
        "source":%s,
        "mode":%s,
        "target":{
          "type":16,"fxAnchor":"id",
          "useSelectionGanging":false,"useTrackGrouping":false,
          "seekBehavior":"Immediate","transportAction":"repeat",
          "useProject":true,"moveView":true,"seekPlay":true,"oscArgIndex":0,
          "mouseAction":{"kind":"MoveTo","axis":"X"},
          "takeMappingSnapshot":{"kind":"LastLoaded"}
        },
        "controlIsEnabled":false
      }]],
  string.format(source_tpl, 52),
  mode_default)

local mappings = table.concat({

  -- m1: Play/Pause — uses play-pause-toggle.lua to avoid gate behaviour.
  --     press-only mode so release Note-Off doesn't fire a second toggle.
  mapping("m1", "Pad 1 — Play / Pause",
          48,
          string.format(target_tpl_action, q(ids["play-pause-toggle.lua"])),
          mode_press_only),

  -- m2: Stop — native TransportAction is fine here.
  mapping("m2", "Pad 2 — Stop",
          50,
          string.format(target_tpl_transport, q("stop"))),

  -- m3: Loop — custom script. Feedback disabled; loop-led mapping handles state display.
  mapping("m3", "Pad 3 — Loop Region Toggle",
          52,
          string.format(target_tpl_action, q(ids["loop-region.lua"])),
          nil,
          ',"feedbackIsEnabled":false'),

  mapping("m4", "Pad 4 — Go To Region Start",
          53,
          string.format(target_tpl_action, q(ids["goto-region-start.lua"]))),

  mapping("m5", "Pad 5 — Previous Region",
          55,
          string.format(target_tpl_action, q(ids["prev-region.lua"]))),

  mapping("m6", "Pad 6 — Next Region",
          57,
          string.format(target_tpl_action, q(ids["next-region.lua"]))),

  mapping("m7", "Pad 7 — Panic (Stop + All Notes Off)",
          59,
          string.format(target_tpl_action, q(ids["panic.lua"]))),

  loop_led_mapping,

}, ",\n")

local preset = string.format([[{
  "kind": "MainCompartment",
  "version": "2.18.2",
  "value": {
    "defaultGroup": {},
    "mappings": [
%s
    ]
  }
}]], mappings)

-- ── Write file ────────────────────────────────────────────────────────────────
local out = base_dir .. "realearn-preset.json"
local f = io.open(out, "w")
if not f then
  reaper.ShowMessageBox("Cannot write:\n" .. out, "Setup Error", 0)
  return
end
f:write(preset)
f:close()

reaper.ShowMessageBox(
  "Setup complete!\n\n" ..
  "✓ 6 scripts registered (including play-pause-toggle)\n" ..
  "✓ realearn-preset.json written to:\n  " .. out .. "\n\n" ..
  "── Remaining steps ──────────────────\n\n" ..
  "1. Install ReaLearn (Helgobox) via ReaPack if not done\n\n" ..
  "2. Create track 'MIDI Control'\n" ..
  "   Input  → MPK mini Play mk3\n" ..
  "   Output → MPK mini Play mk3\n\n" ..
  "3. Add ReaLearn as FX on that track\n" ..
  "   Set ReaLearn Input  → MIDI: <FX input>\n" ..
  "   Set ReaLearn Output → MPK mini Play mk3\n\n" ..
  "4. Open realearn-preset.json in Notepad\n" ..
  "   Ctrl+A → Ctrl+C\n" ..
  "   In ReaLearn: click 'Import from clipboard'",
  "Install Complete", 0)