@echo off
rem ReaperVC one-time setup for Windows
rem Double-click this file. It creates a private Python environment in the
rem "venv" folder, installs everything ReaperVC needs and downloads the
rem speech recognition model.

setlocal
title ReaperVC Setup
cd /d "%~dp0"

echo ==========================================
echo   ReaperVC Setup
echo ==========================================
echo.

rem Supported Python versions (all dependencies ship Windows builds for these)
set "PY="
for %%V in (3.13 3.12 3.11) do (
	if not defined PY (
		py -%%V -c "import sys" >nul 2>&1 && set "PY=py -%%V"
	)
)

if not defined PY (
	echo [ERROR] Python 3.13 was not found on this computer.
	echo.
	echo Download and install it from:
	echo   https://www.python.org/ftp/python/3.13.17/python-3.13.17-amd64.exe
	echo Then double-click install-windows.bat again.
	goto :fail
)

rem The Microsoft Store edition of Python keeps its temporary files in a
rem private location, so REAPER could not see whether ReaperVC is running
%PY% -c "import sys; sys.exit('WindowsApps' in sys.executable)"
if errorlevel 1 (
	echo [ERROR] This is the Microsoft Store edition of Python, which does not
	echo work with ReaperVC.
	echo.
	echo Uninstall it ^(Settings - Apps - Installed apps - Python^), then install:
	echo   https://www.python.org/ftp/python/3.13.17/python-3.13.17-amd64.exe
	echo Then double-click install-windows.bat again.
	goto :fail
)

echo [1/3] Creating the Python environment...
if not exist "venv\Scripts\python.exe" (
	%PY% -m venv venv
	if errorlevel 1 goto :fail
)

echo.
echo [2/3] Installing components. This can take 5-15 minutes...
"venv\Scripts\python.exe" -m pip install --upgrade pip
"venv\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 goto :fail

echo.
echo [3/3] Downloading the speech recognition model...
"venv\Scripts\python.exe" -c "import yaml, whisper; whisper.load_model(yaml.safe_load(open('config/voice_config.yaml', encoding='utf-8'))['stt']['whisper_model'])"
if errorlevel 1 goto :fail

echo.
echo ==========================================
echo   Setup finished - you can close this window
echo ==========================================
echo Next: continue with "Part 4" of docs\WINDOWS_SETUP.md
echo.
pause
exit /b 0

:fail
echo.
echo ==========================================
echo   Setup did NOT finish
echo ==========================================
echo Take a photo or screenshot of this window and send it to whoever gave
echo you ReaperVC.
echo.
pause
exit /b 1
