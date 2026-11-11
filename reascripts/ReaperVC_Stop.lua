-- ReaperVC Stop
-- Stops the ReaperVC voice control system
-- Author: ReaperVC Project
-- Version: 1.0

-- Shared helpers (ReaperVC_Common.lua must be in the same folder as this script)
local VC = dofile(debug.getinfo(1, "S").source:match("^@?(.*[/\\])") .. "ReaperVC_Common.lua")

-- Main
function Main()
	-- Signal telemetry script to stop
	reaper.SetExtState("ReaperVC", "telemetry_stop", "1", false)

	-- Kill all processes (SIGKILL to ensure they stop)
	VC.KillAll()

	-- Clean up log files
	os.remove(VC.LOG_FILE)
	os.remove(VC.TELEMETRY_FILE)

	-- Wait a moment and verify
	reaper.defer(function()
		if VC.IsRunning() then
			reaper.ShowMessageBox(
				"Warning: Some processes may still be running.\n\n" ..
				"Try manually:\n" .. VC.manual_kill_hint,
				"ReaperVC",
				0
			)
		end
	end)
end

Main()
