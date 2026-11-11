-- ReaperVC Toggle
-- Starts or stops the ReaperVC voice control system
-- Author: ReaperVC Project
-- Version: 1.0

-- Shared helpers (ReaperVC_Common.lua must be in the same folder as this script)
local VC = dofile(debug.getinfo(1, "S").source:match("^@?(.*[/\\])") .. "ReaperVC_Common.lua")

-- Configuration
local REAPERVC_PATH = reaper.GetExtState("ReaperVC", "install_path")
if REAPERVC_PATH == "" and VC.HasLauncher(VC.DefaultPath()) then
	-- Not configured, but the scripts were loaded from inside the install folder
	REAPERVC_PATH = VC.DefaultPath()
end
if REAPERVC_PATH == "" then
	-- Path not configured - prompt user
	reaper.ShowMessageBox(
		"ReaperVC installation path not configured.\n\n" ..
		"Please run: Script: ReaperVC_SetPath.lua\n" ..
		"to set the path to your ReaperVC installation.",
		"ReaperVC Configuration Required",
		0
	)
	return
end

-- Helper Functions
function StartReaperVC()
	-- Check if already running
	if VC.IsRunning() then
		reaper.ShowMessageBox("ReaperVC is already running!", "ReaperVC", 0)
		return false
	end

	-- Verify path exists
	if not VC.HasLauncher(REAPERVC_PATH) then
		reaper.ShowMessageBox(
			"ReaperVC not found at:\n" .. REAPERVC_PATH .. "\n\n" ..
			"Please update the path in the script or set it via:\n" ..
			"Extensions → ReaperVC → Set Installation Path",
			"ReaperVC Error",
			0
		)
		return false
	end

	-- Start ReaperVC in background
	VC.Launch(REAPERVC_PATH)

	-- Wait for startup (check after 3 seconds)
	local check_time = reaper.time_precise() + 3.0

	local function check_startup()
		if reaper.time_precise() < check_time then
			-- Keep waiting
			reaper.defer(check_startup)
			return
		end

		if VC.IsRunning() then
			-- Show simple confirmation message
			reaper.ShowMessageBox(
				"ReaperVC is listening!\n\n" ..
				"For a complete list of commands:\n"..
				"Say: \"COMMAND LIST\"\n\n"..
				"To view voice processing telemetry:\n"..
				"Say: \"CONSOLE\"",
				"ReaperVC",
				0  -- OK only
			)
		else
			reaper.ShowMessageBox(
				"Failed to start ReaperVC.\n\n" ..
				"Check the log file:\n" .. VC.LOG_FILE,
				"ReaperVC Error",
				0
			)
		end
	end

	check_startup()

	return true
end

function StopReaperVC()
	if not VC.IsRunning() then
		return false
	end

	-- Write "stop listening" command to trigger file
	-- ReaperVC will process this as a voice command and shut down gracefully with audio
	local f = io.open(VC.TRIGGER_FILE, "w")
	if f then
		f:write("stop listening")
		f:close()
	end

	-- Wait for graceful shutdown (give it 3 seconds)
	local check_time = reaper.time_precise() + 3.0

	local function verify_stopped()
		if reaper.time_precise() < check_time then
			reaper.defer(verify_stopped)
			return
		end

		if VC.IsRunning() then
			-- Graceful shutdown didn't work, force kill
			VC.KillAll()

			-- Final check
			reaper.defer(function()
				if VC.IsRunning() then
					reaper.ShowMessageBox(
						"Failed to stop ReaperVC.\n\n" ..
						"Try manually:\n" .. VC.manual_kill_hint,
						"ReaperVC Error",
						0
					)
				end
			end)
		end
	end

	verify_stopped()

	return true
end

-- Main Logic
function Main()
	if VC.IsRunning() then
		-- Running - stop it
		StopReaperVC()
	else
		-- Not running - start it
		StartReaperVC()
	end
end

-- Run
Main()
