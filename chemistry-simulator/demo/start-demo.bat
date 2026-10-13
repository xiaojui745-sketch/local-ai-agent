@echo off
setlocal
title Chemistry simulator - local YOLO
echo Starting local YOLO inference. Keep this window open while using the demo.
echo When finished, press Ctrl+C here to stop the service.
for /f "usebackq delims=" %%I in (`wsl.exe -d Ubuntu -- wslpath -a "%~dp0.."`) do set "PROJECT_WSL_PATH=%%I"
if not defined PROJECT_WSL_PATH (
  echo Could not resolve this folder inside WSL. Make sure WSL Ubuntu is installed.
  pause
  exit /b 1
)
wsl.exe -d Ubuntu -- bash -lc "cd '%PROJECT_WSL_PATH%' && exec /home/xiaohui/yolo/.venv/bin/python demo/server.py"
pause
