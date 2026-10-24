@echo off
rem Installs the archive-route host daemon:
rem  1) copies launcher bats into C:\Users\decog\s90d-root\tools
rem  2) drops a Startup .cmd so it runs at login
rem  3) starts it now (hidden)
set "dest=C:\Users\decog\s90d-root\tools"
set "startup=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "src=%~dp0"

copy /y "%src%run-daemon.bat" "%dest%" >nul
copy /y "%src%start-daemon.bat" "%dest%" >nul
copy /y "%src%daemon-cmd.bat" "%dest%" >nul
copy /y "%src%stop-daemon.ps1" "%dest%" >nul
copy /y "%src%stop-watcher.ps1" "%dest%" >nul

> "%startup%\s90d-root-daemon.cmd" echo @call "%dest%\start-daemon.bat"

start "s90d-root-daemon" /min "%dest%\start-daemon.bat"
echo Installed and started. Log: C:\Users\decog\s90d-root\logs\daemon.log
echo Commands: %dest%\daemon-cmd.bat status
echo            %dest%\daemon-cmd.bat root acquire s90d --timeout 180
echo            %dest%\daemon-cmd.bat execute s90d id
