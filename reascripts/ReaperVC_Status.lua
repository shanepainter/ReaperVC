-- ReaperVC Status
-- Check if ReaperVC is running and show status
-- Author: ReaperVC Project
-- Version: 1.0

-- Shared helpers (ReaperVC_Common.lua must be in the same folder as this script)
local VC = dofile(debug.getinfo(1, "S").source:match("^@?(.*[/\\])") .. "ReaperVC_Common.lua")

-- Configuration
local REAPERVC_PATH = reaper.GetExtState("ReaperVC", "install_path")
if REAPERVC_PATH == "" then
	REAPERVC_PATH = VC.DefaultPath()
end

-- Helper Functions
function ReadLastLog()
	local f = io.open(VC.LOG_FILE, "r")
	if not f then
		return "No log file found"
	end

	-- Read last 10 lines
	local lines = {}
	for line in f:lines() do
		table.insert(lines, line)
		if #lines > 10 then
			table.remove(lines, 1)
		end
	end
	f:close()

	return table.concat(lines, "\n")
end

-- Main
function Main()
	local status_msg = "ReaperVC Status\n" .. string.rep("=", 50) .. "\n\n"

	if VC.IsRunning() then
		status_msg = status_msg .. "Status: RUNNING ✓\n\n"

		-- Show process info
		local proc_info = VC.ProcessInfo()
		if proc_info ~= "" then
			status_msg = status_msg .. "Process Info:\n" .. proc_info .. "\n"
		end

		-- Show recent log
		status_msg = status_msg .. "\nRecent Log:\n" .. ReadLastLog()
	else
		status_msg = status_msg .. "Status: NOT RUNNING ✗\n\n"
		status_msg = status_msg .. "Start ReaperVC with:\n"
		status_msg = status_msg .. "  Actions → ReaperVC Start\n"
		status_msg = status_msg .. "\nOr run manually:\n"
		status_msg = status_msg .. "  cd " .. REAPERVC_PATH .. "\n"
		status_msg = status_msg .. "  " .. (VC.is_windows and "" or "./") .. VC.launcher
	end

	-- Output to console and message box
	reaper.ShowConsoleMsg("\n" .. status_msg .. "\n\n")
	reaper.ShowMessageBox(status_msg, "ReaperVC Status", 0)
end

Main()
