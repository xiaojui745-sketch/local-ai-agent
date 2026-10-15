@echo off
title Chemistry simulator - local YOLO
echo Starting local YOLO inference. Keep this window open while using the demo.
echo When finished, press Ctrl+C here to stop the service.
wsl.exe -d Ubuntu -- bash -lc "cd /mnt/d/YOLO/chemistry_sim && exec /home/xiaohui/yolo/.venv/bin/python demo/server.py"
pause
