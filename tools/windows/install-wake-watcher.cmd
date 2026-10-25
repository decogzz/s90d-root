@echo off
rem Installs the s90d-root wake watcher:
rem  1) copies the watcher into C:\Users\decog\s90d-root\tools
rem  2) drops a Startup .cmd so it runs at every login (current user, no admin)
rem  3) starts it now for this session
set "dest=C:\Users\decog\s90d-root\tools"
set "startup=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "src=%~dp0"

copy /y "%src%s90d-root-wake-watcher.ps1" "%dest%" >nul

> "%startup%\s90d-wake-watcher.cmd" echo @powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "%dest%\s90d-root-wake-watcher.ps1"

start "s90d-wake-watcher" /min powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "%dest%\s90d-root-wake-watcher.ps1"
echo Installed and started. Log: C:\Users\decog\s90d-root\logs\wake-watcher.log
