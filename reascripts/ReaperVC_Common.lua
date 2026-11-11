-- ReaperVC Common
-- Shared, platform-aware helpers for the ReaperVC ReaScripts.
-- Not an action: the other ReaperVC_*.lua scripts load this file from their
-- own folder, so keep it next to them.
-- Author: ReaperVC Project

local VC = {}

VC.is_windows = reaper.GetOS():match("^Win") ~= nil
VC.sep = VC.is_windows and "\\" or "/"
VC.launcher = VC.is_windows and "reaper-vc.bat" or "reaper-vc.sh"

-- Runtime files shared with the Python side (must match src/runtime_paths.py)
local tmp_dir = "/tmp"
if VC.is_windows then
	tmp_dir = os.getenv("TEMP") or os.getenv("TMP") or "C:\\Windows\\Temp"
end
VC.LOG_FILE = tmp_dir .. VC.sep .. "reapervc.log"
VC.TELEMETRY_FILE = tmp_dir .. VC.sep .. "reapervc_telemetry.log"
VC.STOP_TELEMETRY_FLAG = tmp_dir .. VC.sep .. "reapervc_stop_telemetry"
VC.TRIGGER_FILE = tmp_dir .. VC.sep .. "reapervc_external_command"
VC.PID_FILE = tmp_dir .. VC.sep .. "reapervc.pid"

VC.manual_kill_hint = VC.is_windows
	and "End the python.exe process in Task Manager"
	or "pkill -9 -f reapervc"

local function file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

-- Tidy a user-entered install path (Windows: forward slashes, trailing slash)
function VC.NormalizePath(path)
	path = path:gsub("^%s*(.-)%s*$", "%1")
	if VC.is_windows then
		path = path:gsub("/", "\\")
	end
	if #path > 1 then
		path = path:gsub("[/\\]+$", "")
	end
	return path
end

function VC.HasLauncher(path)
	return file_exists(path .. VC.sep .. VC.launcher)
end

-- Install path to assume when none has been saved with ReaperVC_SetPath
function VC.DefaultPath()
	-- These scripts normally live in <install>/reascripts
	local script_dir = debug.getinfo(1, "S").source:match("^@?(.*)[/\\][^/\\]*$")
	local parent = script_dir and script_dir:match("^(.*)[/\\][^/\\]*$")
	if parent and VC.HasLauncher(parent) then
		return parent
	end
	if VC.is_windows then
		return (os.getenv("USERPROFILE") or "C:") .. "\\ReaperVC"
	end
	return os.getenv("HOME") .. "/Apps/Audio/ReaperVC"
end

-- Windows: PID written by the running Python process (there is no pgrep)
local function read_pid()
	local f = io.open(VC.PID_FILE, "r")
	if not f then
		return nil
	end
	local pid = f:read("*a"):match("%d+")
	f:close()
	return pid
end

-- Windows: tasklist row for the recorded PID, or nil if it is not a live Python process
local function windows_process_row()
	local pid = read_pid()
	if not pid then
		return nil
	end
	-- ExecProcess runs the command without flashing a console window
	local out = reaper.ExecProcess('tasklist /FI "PID eq ' .. pid .. '" /FO CSV /NH', 5000)
	if not out then
		return nil
	end
	for line in out:gmatch("[^\r\n]+") do
		-- The PID may have been reused by another program after a crash
		if line:lower():match('^"python[^"]*","' .. pid .. '"') then
			return line
		end
	end
	return nil
end

function VC.IsRunning()
	if VC.is_windows then
		return windows_process_row() ~= nil
	end

	-- Very specific check - look ONLY for Python process (not bash shells)
	local handle = io.popen("pgrep -f '^python.*src/reapervc' 2>/dev/null")
	if not handle then
		return false
	end
	local result = handle:read("*a")
	handle:close()

	-- Additional verification - check if result contains actual PID
	if result and result ~= "" then
		-- Trim whitespace and check if it's a valid number
		result = result:gsub("^%s*(.-)%s*$", "%1")
		if tonumber(result) then
			return true
		end
	end

	return false
end

-- Kill all ReaperVC processes (including stale ones)
function VC.KillAll()
	if not VC.is_windows then
		os.execute("pkill -9 -f 'python.*reapervc' 2>/dev/null")
		return
	end

	local pid = read_pid()
	if pid and windows_process_row() then
		reaper.ExecProcess("taskkill /F /T /PID " .. pid, 5000)
	end
	-- Sweep for instances the PID file does not know about
	reaper.ExecProcess(
		[[powershell -NoProfile -NonInteractive -Command "Get-CimInstance Win32_Process | Where-Object { $_.Name -like 'python*' -and $_.CommandLine -like '*reapervc.py*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"]],
		15000
	)
	os.remove(VC.PID_FILE)
end

-- Start ReaperVC in the background, logging to VC.LOG_FILE
function VC.Launch(install_path)
	if VC.is_windows then
		-- cmd.exe is needed for the redirect; -2 = don't wait, start minimized
		local cmd = string.format(
			'cmd.exe /C ""%s\\%s" > "%s" 2>&1"',
			install_path, VC.launcher, VC.LOG_FILE
		)
		reaper.ExecProcess(cmd, -2)
		return
	end

	local cmd = string.format(
		"cd '%s' && nohup ./reaper-vc.sh > /tmp/reapervc.log 2>&1 &",
		install_path
	)
	os.execute(cmd)
end

function VC.ProcessInfo()
	if VC.is_windows then
		return windows_process_row() or ""
	end

	local handle = io.popen("ps aux | grep 'python.*reapervc.py' | grep -v grep 2>/dev/null")
	if not handle then
		return "Unable to get process info"
	end
	local result = handle:read("*a")
	handle:close()
	return result
end

return VC
