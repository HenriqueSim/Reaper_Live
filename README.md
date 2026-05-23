# VESPA MAIA — REAPER Live Setup

Live performance setup for REAPER: song display, region navigation, loop control, and MIDI pad control.
Built on top of [Reaper Setlist](https://github.com/iKadmium/reaper-setlist).

## What it does

| Feature | How |
|---|---|
| Song name display | Reads the REAPER project name automatically |
| Current section display | Shows the active region name below the song title |
| Jump between song sections | Region buttons in the Live Controls page or MIDI pads |
| Loop a section on demand | One-tap loop toggle — web button or MIDI pad |
| Queue a section | Tap any region button to mark it orange as the next target |
| Play / Pause / Stop | MIDI pads + transport display with state colours |
| Prev / Next region | MIDI pads |
| Panic stop | Dedicated MIDI pad — stops transport and sends all-notes-off |
| IEM mixing | Separate — see `moreme.html` |

## Colour code (Live Controls page)

| Colour | Meaning |
|---|---|
| Green | Currently playing region |
| Grey | Currently paused region |
| Red | Currently stopped region |
| Orange | Next region in queue |
| Pulsing (state ↔ orange) | Current region is also the next (looping or same-region tap) |

---

## Repo structure

```
reaper-setlist.lua        Modified Lua script — replaces the one installed by ReaPack
live-controls/
  live-controls.html      Companion web page: song info, region navigation, loop control
midi-control/
  install.lua             Run once in REAPER to register all MIDI action scripts
  PAD-LAYOUT.md           Pad assignment reference
  scripts/
    play-pause-toggle.lua
    loop-region.lua
    goto-region-start.lua
    prev-region.lua
    next-region.lua
    panic.lua
```

---

## Installation (Windows)

### 1. Install REAPER
Download from [reaper.fm](https://reaper.fm) and install.

### 2. Install ReaPack
1. Download from [reapack.com](https://reapack.com)
2. Place the `.dll` file in:
   `C:\Users\<you>\AppData\Roaming\REAPER\UserPlugins\`
3. Restart REAPER — you will see **Extensions → ReaPack** in the menu

### 3. Install Reaper Setlist
1. **Extensions → ReaPack → Manage repositories → Import a repository**
2. Paste this URL:
   ```
   https://raw.githubusercontent.com/iKadmium/reaper-setlist/refs/heads/main/reapack/repo/index.xml
   ```
3. **Extensions → ReaPack → Browse packages** → search `setlist` → right-click → Install → Apply

### 4. Replace the Lua script with the band's version
1. In REAPER: **Actions → Show action list** → search `reaper-setlist`
2. Look at the bottom of the window — it shows the full file path, e.g.:
   `C:\Users\<you>\AppData\Roaming\REAPER\Scripts\...\reaper-setlist.lua`
3. Open that folder and **replace** `reaper-setlist.lua` with the one from this repo
4. Back in REAPER: **Actions → Show action list** → find `reaper-setlist` → click **Run**
5. Check the REAPER console — it should say `Installation completed.`

### 5. Enable the REAPER web server
1. **Options → Preferences → Control/OSC/web** → click **Add**
2. Choose **Web browser interface**
3. Set port to `8083`
4. Make sure **Enable** is checked → OK

### 6. Enable the MPK mini Play MIDI output
1. **Options → Preferences → Audio → MIDI Devices**
2. In the **MIDI Outputs** section, find **MPK mini Play mk3** and enable it (dot in the Enable column)
3. Click OK and restart REAPER

### 7. Install the Live Controls page
1. **Options → Show REAPER resource path in Explorer**
2. Open `reaper_www_root` → open `reaper-setlist` inside it
3. Copy `live-controls/live-controls.html` from this repo into that folder

### 8. Open the Live Controls page
With REAPER running, go to:
```
http://localhost:8083/reaper-setlist/live-controls.html
```

---

## MIDI Control Setup (Akai MPK Mini Play mk3)

### 9. Copy the MIDI control scripts
Copy the entire `midi-control/` folder from this repo to:
```
C:\Users\<you>\AppData\Roaming\REAPER\Scripts\midi-control\
```

### 10. Register the action scripts
1. In REAPER: **Actions → Show action list → New action → Load ReaScript**
2. Navigate to the `midi-control/` folder and open `install.lua`
3. Click **Run** — a message will confirm success and tell you where `realearn-preset.json` was generated

### 11. Install ReaLearn (Helgobox)
1. **Extensions → ReaPack → Browse packages**
2. Search `ReaLearn` → Install → Apply

### 12. Set up the MIDI control track
1. Create a new track in your REAPER project, name it `MIDI Control`
2. Set the track **MIDI input → MPK mini Play mk3**
3. Add **ReaLearn** as an FX on that track (**FX → Add → search ReaLearn**)
4. In ReaLearn: set **Input → MIDI: \<FX input\>** and **Output → MPK mini Play mk3**
5. Open `realearn-preset.json` in Notepad, select all, copy
6. In ReaLearn: click **Import from clipboard**

### 13. Pad layout

```
┌──────────┬──────────┬──────────┬──────────┐
│  PREV    │  NEXT    │  PANIC   │  (free)  │  TOP ROW
│ REGION   │ REGION   │          │          │
├──────────┼──────────┼──────────┼──────────┤
│  PLAY /  │  STOP    │  LOOP    │  GO TO   │  BOTTOM ROW
│  PAUSE   │          │ REGION   │  START   │
└──────────┴──────────┴──────────┴──────────┘
```

> **Note:** The MPK mini Play mk3 does not support MIDI-controlled pad LEDs.
> Pad lights only activate on press and cannot be held on by software.

---

## How to use

### Regions
- Create regions in REAPER with **Shift+R** on a time selection and name them clearly (Intro, Verse 1, Chorus, etc.)
- One project per song — the project filename becomes the song name displayed on screen
- The Live Controls page loads all regions as buttons automatically

### Live Controls page
- **Song name** (top left) — reads the REAPER project filename
- **Section name** — shows the name of the region the playhead is currently in
- **State badge** (top right) — green Playing, grey Paused, red Stopped
- **Region buttons** — tap to jump there; the target turns orange immediately
- **Next in queue** — always orange; shows manual target if set, otherwise the next region in timeline order
- **Loop button** — tap while inside a region to loop it; tap again to stop looping

### MIDI pads (Bank A)
- **Pad 1** — Play / Pause toggle
- **Pad 2** — Stop
- **Pad 3** — Loop current region on/off
- **Pad 4** — Go to start of current region
- **Pad 5** — Previous region
- **Pad 6** — Next region
- **Pad 7** — Panic (stop + all notes off)

---

## Adding a new band member

1. Install REAPER and ReaPack
2. Follow steps 3–13 above using the files from this repo
3. Use the MPK Mini Play mk3 (Bank A, standard factory settings)
4. The `install.lua` script handles all action registration automatically — no manual MIDI learn required

---

## Known limitations

- **MPK mini Play mk3 pad LEDs** cannot be controlled via MIDI. Pad lights only flash on press.
- **ReaLearn version** tested: Helgobox 2.18. The preset JSON format may differ in older versions — if import fails, use **Learn many** in ReaLearn to map pads manually.