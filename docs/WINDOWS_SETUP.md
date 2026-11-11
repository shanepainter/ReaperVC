# ReaperVC on Windows - Setup Guide

ReaperVC lets you control REAPER with your voice: say "record", "stop", "try again", "save project" and so on, without putting your instrument down.

This guide takes you from nothing to a working setup. No technical knowledge is needed, just follow the parts in order. Allow about 30 minutes, most of which is waiting for downloads.

> **This Windows version is a test build.** It has not been run on a real Windows computer yet, so something may not work first time. That is exactly what we want to find out. See [What to send back](#what-to-send-back) at the end.

## What you need

- A Windows 10 or Windows 11 PC (64-bit) with an internet connection
- REAPER already installed and working
- A microphone ReaperVC can listen to
- Headphones (with speakers, REAPER's playback would be heard as "voice")
- About 3 GB of free disk space

---

## Part 1 - Install Python

Python is the engine ReaperVC runs on. You install it once and never need to open it.

1. Download this exact installer: **[python-3.13.17-amd64.exe](https://www.python.org/ftp/python/3.13.17/python-3.13.17-amd64.exe)**
2. Double-click the downloaded file.
3. Click **Install Now** and wait for it to finish, then click **Close**.

**Important:** use the link above. Do not install Python from the Microsoft Store, and do not grab the newest version from the Python website - neither works with ReaperVC.

## Part 2 - Download ReaperVC

1. Download the ZIP: **[ReaperVC for Windows](https://github.com/shanepainter/ReaperVC/archive/refs/heads/ADD-windows-support.zip)**
2. Open your **Downloads** folder and find `ReaperVC-ADD-windows-support.zip`.
3. Right-click the ZIP, choose **Properties**, tick **Unblock** at the bottom (if it is there) and click **OK**.
4. Right-click the ZIP again and choose **Extract All...**
5. Change the destination to `C:\` and click **Extract**.

You now have a folder called `C:\ReaperVC-ADD-windows-support`. That is the **ReaperVC folder** referred to in the rest of this guide. Do not move or rename it after setup.

## Part 3 - Run the installer

1. Open the ReaperVC folder.
2. Double-click **install-windows** (it may show as `install-windows.bat`).
3. If a blue "Windows protected your PC" box appears, click **More info**, then **Run anyway**.
4. A black window opens and shows progress. **Leave it alone until it says "Setup finished".** It downloads around 1 GB, so it can take 5 to 15 minutes and may look stuck at times.
5. Press any key to close the window.

If it says **"Setup did NOT finish"**, take a screenshot of the window and send it back (see the end of this guide).

## Part 4 - Install the SWS Extension for REAPER

SWS is a free, widely used add-on for REAPER that ReaperVC depends on.

1. Close REAPER.
2. Go to **[sws-extension.org](https://www.sws-extension.org/)** and download the **Windows 64-bit** installer.
3. Run it and accept the defaults.
4. Open REAPER. You should now see an **Extensions** menu at the top.

## Part 5 - Set up REAPER

### 5a. Turn on OSC (how ReaperVC talks to REAPER)

1. In REAPER, open **Options > Preferences** (or press `Ctrl+P`).
2. In the list on the left, scroll down and click **Control/OSC/web**.
3. Click **Add**.
4. Set **Control surface mode** to **OSC (Open Sound Control)**.
5. Fill in:
   - **Device name:** `ReaperVC`
   - **Mode:** `Local port [receive only]`
   - **Local listen port:** `8000`
   - Leave everything else as it is.
6. Click **OK**, then **OK** again to close Preferences.

If Windows Firewall asks about REAPER, either answer is fine - ReaperVC only talks to REAPER inside this computer.

### 5b. Load the ReaperVC scripts

1. In REAPER, open **Actions > Show action list...** (or press `?`).
2. At the bottom right click **New action...**, then **Load ReaScript...**
3. Browse to the ReaperVC folder, then into the **reascripts** folder.
4. Select these six files (hold `Ctrl` and click each one), then click **Open**:
   - `ReaperVC_Toggle.lua`
   - `ReaperVC_LaunchTelemetry.lua`
   - `ReaperVC_HideTelemetry.lua`
   - `ReaperVC_Status.lua`
   - `ReaperVC_Stop.lua`
   - `ReaperVC_CleanupAndStart.lua`

Leave the other files in that folder where they are; the scripts above use them.

### 5c. Save REAPER's action list for ReaperVC

Do this **after** 5b, not before.

1. Still in the action list window, type `dump action` in the **Filter** box.
2. Double-click **SWS/S&M: Dump action list (all actions)**.
3. A save window appears. Browse to the ReaperVC folder (the main folder, not `reascripts`).
4. Set the file name to `reaper-actions` and click **Save**.

You should now have a file called `reaper-actions` (or `reaper-actions.txt`) in the ReaperVC folder, next to `install-windows`.

### 5d. Give start/stop a keyboard shortcut (recommended)

1. In the action list, type `ReaperVC_Toggle` in the **Filter** box.
2. Click **Script: ReaperVC_Toggle.lua** once to select it.
3. Under **Shortcuts for selected action** click **Add...**
4. Press the key combination you want (for example `Ctrl+Shift+V`) and click **OK**.
5. Close the action list.

## Part 6 - Choose the microphone

ReaperVC listens to whatever Windows uses as its **default recording device**, on its first input.

1. Right-click the speaker icon at the bottom right of the screen and choose **Sound settings**.
2. Under **Input**, pick the microphone you want to talk into.
3. Speak and check the input level bar moves.

**If you record through an audio interface (Focusrite, PreSonus and so on):** REAPER normally takes over the interface while it is open, and some interfaces will not share their inputs with a second program. The reliable setup is to use a **different microphone for voice commands** - a USB mic, a webcam mic or a headset - and set that one as the Windows default input. Your interface stays dedicated to REAPER.

## Part 7 - Use it

1. In REAPER, press your shortcut (or run **Script: ReaperVC_Toggle.lua** from the action list).
2. Wait for the welcome sound - **"ReaperVC is listening"**. This takes roughly 10 to 30 seconds. A message box also appears; click **OK**.
3. Speak a command, clearly and at a normal pace. You will hear a short tone when a command is carried out.

Things to try:

| Say | What happens |
|---|---|
| "new track" | Adds a track |
| "record arm" | Arms the track for recording |
| "record" | Starts recording |
| "stop" | Stops |
| "try again" | Deletes the last take and records again |
| "keep this take" | Disarms the track |
| "playback" | Plays |
| "set tempo to 120" | Sets the tempo |
| "save project" | Saves |
| "command list" | Opens a window listing every command |
| "open console" | Shows what ReaperVC is hearing (useful when something is not recognised) |
| "stop listening" | Shuts ReaperVC down |

To stop ReaperVC, press your shortcut again or say **"stop listening"**.

While REAPER is recording, ReaperVC only reacts to stop-type commands, so singing or talking during a take will not trigger anything else.

---

## If something goes wrong

**"Failed to start ReaperVC" message**
Run the action **Script: ReaperVC_Status.lua** from the action list. It shows the last lines of ReaperVC's log, which usually say what is wrong. Common causes:
- *"reaper-actions.txt not found"* - redo step 5c and make sure the file is saved in the main ReaperVC folder.
- *"Action ... not found in reaper-actions.txt"* - step 5c was done before step 5b. Redo 5c.
- *"Virtual environment not found"* - Part 3 did not finish. Run `install-windows` again.

**It starts, but nothing happens when I speak**
- Say "open console" - if nothing appears, ReaperVC is not hearing you at all. Recheck Part 6: is the right microphone the Windows default input, and does its level bar move?
- If your mic is plugged into the **second** input of an audio interface, ReaperVC is listening to the first one. Use input 1, or use a separate USB mic.
- If the console shows the wrong words, move closer to the mic and reduce background noise.

**It hears me but REAPER does not react**
Recheck step 5a. The mode must be `Local port [receive only]` and the port must be `8000`.

**No welcome sound**
ReaperVC plays its sounds through the Windows default **output** device. Check that device in Sound settings.

**It will not stop, or seems stuck**
Run **Script: ReaperVC_CleanupAndStart.lua** to force a clean restart, or **Script: ReaperVC_Stop.lua** to force it off.

## What to send back

Since this is a test build, please report back whether or not it worked. The most useful things are:

1. **How far you got** - which part and step number.
2. **The log file.** Press `Windows key + R`, type `%TEMP%` and press Enter. In the folder that opens, find `reapervc.log` (and `reapervc_telemetry.log` if it is there) and send them.
3. **Your setup** - Windows 10 or 11, the microphone you used, and your audio interface if you have one.
4. A screenshot of any error message.

## Removing ReaperVC

1. In REAPER's action list, select each `Script: ReaperVC_...` entry and press **Delete**.
2. In **Preferences > Control/OSC/web**, select the ReaperVC entry and click **Remove**.
3. Delete the ReaperVC folder.
