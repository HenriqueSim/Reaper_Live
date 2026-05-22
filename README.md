# [Band Name] — REAPER Live Setup

Region navigation and loop control for live shows, built on top of
[Reaper Setlist](https://github.com/iKadmium/reaper-setlist).

## What it does
- Companion page with region buttons for jumping between song sections
- One-tap loop toggle for any region
- Shows current position, play state, and active region

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
2. Paste this URL: https://raw.githubusercontent.com/iKadmium/reaper-setlist/refs/heads/main/reapack/repo/index.xml
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
2. Open the `reaper_www_root` folder, then open `reaper-setlist` inside it
3. Copy `live-controls.html` from this repo into that folder

### 7. Open
With REAPER running, go to: http://localhost:8083/reaper-setlist/live-controls.html

---

## How to use
- **Regions** are created in REAPER using **Shift+R** on a time selection
- Tap any region button to jump there
- Tap **LOOP CURRENT REGION** while the playhead is inside a region to loop it
- Tap the loop button again to stop looping and continue
- Use the existing Reaper Setlist interface at `http://localhost:8083/reaper-setlist/` for setlist management







