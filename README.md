# VESPA MAIA — REAPER Live Setup

Live performance setup for REAPER: region navigation, loop control, and MIDI pad control.
Built on top of [Reaper Setlist](https://github.com/iKadmium/reaper-setlist).

## What it does

| Feature | How |
|---|---|
| Jump between song sections | Region buttons in the Live Controls page |
| Loop a section on demand | One-tap loop toggle (web + MIDI pad) |
| Play / Pause / Stop | MIDI pads with LED feedback |
| Prev / Next region | MIDI pads |
| Panic stop | Dedicated MIDI pad (stop + all notes off) |
| IEM mixing | Separate — see `moreme.html` |

---

## Repo structure

```
reaper-setlist.lua      Modified Lua script — replaces the one installed by ReaPack
live-controls/
  live-controls.html    Companion web page for region navigation and loop control
midi-control/
  install.lua           Run once in REAPER to register all MIDI action scripts
  PAD-LAYOUT.md         Pad assignment reference
  scripts/              Five Lua action scripts registered by install.lua
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

### 6. Install the Live Controls page
1. **Options → Show REAPER resource path in Explorer**
2. Open `reaper_www_root` → open `reaper-setlist` inside it
3. Copy `live-controls/live-controls.html` from this repo into that folder

### 7. Open the Live Controls page
With REAPER running, go to:
```
http://localhost:8083/reaper-setlist/live-controls.html
```

---

## MIDI Control Setup (Akai MPK Mini Play)

### 8. Copy the MIDI control scripts
Copy the entire `midi-control/` folder from this repo to:
```
C:\Users\<you>\AppData\Roaming\REAPER\Scripts\midi-control\
```

### 9. Register the action scripts
1. In REAPER: **Actions → Show action list → New action → Load ReaScript**
2. Navigate to the `midi-control/` folder and open `install.lua`
3. Click **Run** — a message will confirm success and tell you where `realearn-preset.json` was generated

### 10. Install ReaLearn
1. **Extensions → ReaPack → Browse packages**
2. Search `ReaLearn` → Install → Apply

### 11. Set up the MIDI control track
1. Create a new track in your REAPER project, name it `MIDI Control`
2. Right-click the track's output and set **MIDI output → MPK mini Play**
3. Add **ReaLearn** as an FX on that track (**FX → Add → search ReaLearn**)
4. In ReaLearn: click **Import** and open the `realearn-preset.json` that was generated in step 9

### 12. Pad layout

```
┌──────────┬──────────┬──────────┬──────────┐
│  PREV    │  NEXT    │  PANIC   │  (free)  │  TOP ROW
│ REGION   │ REGION   │          │          │
├──────────┼──────────┼──────────┼──────────┤
│  PLAY /  │  STOP    │  LOOP    │  GO TO   │  BOTTOM ROW
│  PAUSE ● │          │REGION  ● │  START   │
└──────────┴──────────┴──────────┴──────────┘
● = pad LED stays lit while the feature is active
```

---

## How to use

- **Regions** are created in REAPER with **Shift+R** on a time selection — name them clearly
- The Live Controls page shows all regions as buttons; tap any to jump there
- **LOOP**: tap while the playhead is inside a region — pad 3 lights up; tap again to stop looping
- **PLAY/PAUSE**: pad 1 LED stays lit while playing or paused
- **PANIC**: pad 7 — stops transport and sends all-notes-off immediately

---

## Adding a new band member

They need:
1. REAPER + ReaPack installed
2. Follow steps 3–12 above using files from this repo
3. The MPK Mini Play (Bank A pads, standard factory settings)
