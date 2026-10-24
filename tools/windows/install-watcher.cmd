@echo off
rem Installs the s90d-root mask watcher:
rem  1) copies watcher files into C:\Users\decog\s90d-root\tools
rem  2) drops a Startup .cmd so it runs at every login (current user, no admin)
rem  3) starts it now for this session
set "dest=C:\Users\decog\s90d-root\tools"
set "startup=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "src=%~dp0"

copy /y "%src%s90d-root-watcher.ps1" "%dest%" >nul
copy /y "%src%run-mask-apply.bat" "%dest%" >nul

> "%startup%\s90d-mask-watcher.cmd" echo @powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "%dest%\s90d-root-watcher.ps1"

start "s90d-mask-watcher" /min powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "%dest%\s90d-root-watcher.ps1"
echo Installed and started. Logs: C:\Users\decog\s90d-root\logs\watcher.log
