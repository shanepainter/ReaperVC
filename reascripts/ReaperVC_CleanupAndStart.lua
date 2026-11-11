-- ReaperVC Cleanup and Start
-- Kills any stale processes and starts ReaperVC fresh
-- Author: ReaperVC Project
-- Version: 1.0
-- Use this if Toggle/Start scripts are having issues

-- Shared helpers (ReaperVC_Common.lua must be in the same folder as this script)
local VC = dofile(debug.getinfo(1, "S").source:match("^@?(.*[/\\])") .. "ReaperVC_Common.lua")

-- Configuration
local REAPERVC_PATH = reaper.GetExtState("ReaperVC", "install_path")
if REAPERVC_PATH == "" then
	REAPERVC_PATH = VC.DefaultPath()
end

-- Main
function Main()
	reaper.ShowConsoleMsg("[ReaperVC Cleanup] Starting cleanup...\n")

	-- Kill ALL ReaperVC processes
	reaper.ShowConsoleMsg("[ReaperVC Cleanup] Killing all ReaperVC processes...\n")
	VC.KillAll()

	-- Clean up log file
	reaper.ShowConsoleMsg("[ReaperVC Cleanup] Removing old log file...\n")
	os.remove(VC.LOG_FILE)

	-- Verify path exists
	if not VC.HasLauncher(REAPERVC_PATH) then
		reaper.ShowMessageBox(
			"ReaperVC not found at:\n" .. REAPERVC_PATH .. "\n\n" ..
			"Please run ReaperVC_SetPath.lua to configure.",
			"ReaperVC Error",
			0
		)
		return
	end

	-- Start fresh
	reaper.ShowConsoleMsg("[ReaperVC Cleanup] Starting ReaperVC...\n")
	VC.Launch(REAPERVC_PATH)

	-- Show success message (don't check immediately, let it start)
	reaper.ShowConsoleMsg("[ReaperVC Cleanup] Started! Initializing...\n")
	reaper.ShowConsoleMsg("[ReaperVC Cleanup] Check Status script in a few seconds to verify.\n")
	reaper.ShowMessageBox(
		"ReaperVC cleanup complete!\n\n" ..
		"Starting fresh...\n" ..
		"Wait for welcome sound, then ready for voice commands!\n\n" ..
		"Run ReaperVC_Status to check if ready.",
		"Success",
		0
	)
end

Main()
