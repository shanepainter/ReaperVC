@echo off
rem Launch ReaperVC
rem Voice control for REAPER DAW (Windows)

cd /d "%~dp0"

echo ==========================================
echo   ReaperVC - Voice Control for REAPER
echo ==========================================
echo.

rem Check if virtual environment exists
if not exist "venv\Scripts\python.exe" (
	echo [ERROR] Virtual environment not found
	echo Please double-click install-windows.bat first
	exit /b 1
)

rem UTF-8 output and unbuffered so the log file fills in real time
set PYTHONUTF8=1
set PYTHONUNBUFFERED=1

rem Run ReaperVC
"venv\Scripts\python.exe" src\reapervc.py
