"""
Runtime file locations shared with the ReaScripts.

The Lua scripts in reascripts/ (see ReaperVC_Common.lua) read and write the
same files, so both sides must resolve the same directory:
  Linux/macOS: /tmp
  Windows:     %TEMP%
"""

import atexit
import os
import subprocess
import sys
import tempfile

IS_WINDOWS = sys.platform == "win32"


def runtime_dir():
	"""Directory for the log, telemetry, trigger, flag and PID files"""
	if IS_WINDOWS:
		return os.environ.get("TEMP") or tempfile.gettempdir()
	return "/tmp"


TELEMETRY_LOG = os.path.join(runtime_dir(), "reapervc_telemetry.log")
STOP_TELEMETRY_FLAG = os.path.join(runtime_dir(), "reapervc_stop_telemetry")
EXTERNAL_COMMAND_FILE = os.path.join(runtime_dir(), "reapervc_external_command")
# Windows has no pgrep, so the running instance is tracked with a PID file
PID_FILE = os.path.join(runtime_dir(), "reapervc.pid")


def find_other_instances():
	"""Return PIDs of other running ReaperVC instances"""
	if not IS_WINDOWS:
		result = subprocess.run(
			["pgrep", "-f", "reapervc.py"],
			capture_output=True,
			text=True
		)
		pids = result.stdout.split()
		return [pid for pid in pids if pid != str(os.getpid())]

	# Windows: no pgrep, so check the PID recorded by the last instance
	try:
		with open(PID_FILE, 'r') as f:
			pid = f.read().strip()
	except OSError:
		return []
	if not pid.isdigit() or pid == str(os.getpid()):
		return []
	result = subprocess.run(
		["tasklist", "/FI", f"PID eq {pid}", "/FO", "CSV", "/NH"],
		capture_output=True,
		text=True,
		creationflags=subprocess.CREATE_NO_WINDOW
	)
	# The PID may have been reused by an unrelated program since a crash
	if f'"{pid}"' in result.stdout and "python" in result.stdout.lower():
		return [pid]
	return []


def write_pid_file():
	"""Record our PID so the ReaScripts can find and stop us (Windows)"""
	def _remove():
		try:
			with open(PID_FILE, 'r') as f:
				if f.read().strip() == str(os.getpid()):
					os.remove(PID_FILE)
		except OSError:
			pass

	with open(PID_FILE, 'w') as f:
		f.write(str(os.getpid()))
	atexit.register(_remove)
