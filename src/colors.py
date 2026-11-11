"""
ANSI Color Codes for Terminal Output
"""

import os
import sys

if sys.platform == "win32":
	# Switches the Windows console into ANSI escape (VT) mode
	os.system("")


class Colors:
	"""ANSI color codes for terminal output"""

	@staticmethod
	def green(text):
		return f"\033[92m{text}\033[0m"

	@staticmethod
	def red(text):
		return f"\033[91m{text}\033[0m"

	@staticmethod
	def yellow(text):
		return f"\033[93m{text}\033[0m"

	@staticmethod
	def blue(text):
		return f"\033[94m{text}\033[0m"

	@staticmethod
	def cyan(text):
		return f"\033[96m{text}\033[0m"

	@staticmethod
	def magenta(text):
		return f"\033[95m{text}\033[0m"

	@staticmethod
	def bold(text):
		return f"\033[1m{text}\033[0m"
