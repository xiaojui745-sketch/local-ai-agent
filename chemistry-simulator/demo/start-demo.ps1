$ErrorActionPreference = 'Stop'
$projectWindowsPath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$projectWslPath = (& wsl.exe -d Ubuntu -- wslpath -a $projectWindowsPath).Trim()
if (-not $projectWslPath) { throw 'Could not resolve the project directory inside WSL.' }
$pythonWslPath = '/home/xiaohui/yolo/.venv/bin/python'
Write-Host 'Starting the local chemistry demo and loading the trained YOLO model...' -ForegroundColor Cyan
Write-Host 'Keep this window open while using the demo. Press Ctrl+C here to stop it.' -ForegroundColor Yellow
Write-Host ''
wsl.exe -d Ubuntu -- bash -lc "cd '$projectWslPath' && exec '$pythonWslPath' demo/server.py"
