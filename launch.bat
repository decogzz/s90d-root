@echo off
setlocal EnableExtensions
for %%I in ("%~dp0.") do set "ROOT=%%~fI"
cd /d "%ROOT%"

if not exist "C:\Program Files\Git\usr\bin\openssl.exe" (
  echo Install Git for Windows first. The TV calls back to this PC through openssl.
  exit /b 1
)

if not exist "%ROOT%\tools\uv\uv.exe" call :fetch_uv
if errorlevel 1 exit /b 1
if not exist "%ROOT%\tools\tizen-sdb\sdb.exe" call :fetch_sdb
if errorlevel 1 exit /b 1
if not exist "%ROOT%\tools\payloads\common\SamsungTvArchiveRoot.dll" call :fetch_payloads
if errorlevel 1 exit /b 1
if not exist "%ROOT%\config.toml" copy /y "%ROOT%\config\daemon.example.toml" "%ROOT%\config.toml" >nul

set "TV_IP="
for /f "usebackq tokens=1,* delims==" %%A in ("%ROOT%\config\tv.example.env") do (
  if "%%A"=="TV_IP" set "TV_IP=%%B"
)
if not defined TV_IP (
  echo config\tv.example.env is missing TV_IP.
  exit /b 1
)

echo Connecting to the TV at %TV_IP%:26101
"%ROOT%\tools\tizen-sdb\sdb.exe" connect %TV_IP%:26101
if errorlevel 1 goto connect_fail

powershell -NoProfile -Command "if (Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*samsung-tv-root*daemon run*' }) { exit 0 } else { exit 1 }"
if errorlevel 1 (
  echo Starting the daemon. The first run downloads Python. Log: %ROOT%\logs\daemon.log
  start "s90d-root" /min "%ROOT%\tools\windows\start-daemon.bat"
)

echo Waiting for the daemon.
set /a TRIES=0
:wait
set /a TRIES+=1
if %TRIES% GTR 90 goto wait_fail
call "%ROOT%\tools\windows\daemon-cmd.bat" status > "%TEMP%\s90d-status.txt" 2>&1
if not errorlevel 1 goto ready
timeout /t 2 /nobreak >nul
goto wait

:ready
findstr /c:"rooted" "%TEMP%\s90d-status.txt" >nul
if not errorlevel 1 goto show_id
echo Acquiring root. This can take a couple of minutes.
call "%ROOT%\tools\windows\daemon-cmd.bat" root acquire s90d --timeout 180
if errorlevel 1 goto acquire_fail

:show_id
call "%ROOT%\tools\windows\daemon-cmd.bat" execute s90d id
exit /b %ERRORLEVEL%

:fetch_uv
echo Downloading uv.
mkdir "%ROOT%\tools\downloads" 2>nul
mkdir "%ROOT%\tools\uv" 2>nul
curl -fsSL -o "%ROOT%\tools\downloads\uv-windows.zip" https://github.com/astral-sh/uv/releases/latest/download/uv-x86_64-pc-windows-msvc.zip
if errorlevel 1 exit /b 1
%SystemRoot%\System32\tar.exe -xf "%ROOT%\tools\downloads\uv-windows.zip" -C "%ROOT%\tools\uv"
if not exist "%ROOT%\tools\uv\uv.exe" exit /b 1
exit /b 0

:fetch_sdb
echo Downloading sdb.
mkdir "%ROOT%\tools\downloads\sdb-pkg" 2>nul
mkdir "%ROOT%\tools\tizen-sdb" 2>nul
curl -fsSL -o "%ROOT%\tools\downloads\sdb_4.2.36_windows-64.zip" https://download.tizen.org/sdk/tizenstudio/official/binary/sdb_4.2.36_windows-64.zip
if errorlevel 1 exit /b 1
%SystemRoot%\System32\tar.exe -xf "%ROOT%\tools\downloads\sdb_4.2.36_windows-64.zip" -C "%ROOT%\tools\downloads\sdb-pkg"
copy /y "%ROOT%\tools\downloads\sdb-pkg\data\tools\sdb.exe" "%ROOT%\tools\tizen-sdb\sdb.exe" >nul
if not exist "%ROOT%\tools\tizen-sdb\sdb.exe" exit /b 1
exit /b 0

:fetch_payloads
echo Downloading controller payloads.
mkdir "%ROOT%\tools\downloads\root-zip" 2>nul
mkdir "%ROOT%\tools\payloads\common" 2>nul
curl -fsSL -o "%ROOT%\tools\downloads\samsung-tv-root-0.0.12-windows-x86_64.zip" https://github.com/chris-ritsen/samsung-tv-root/releases/download/v0.0.12/samsung-tv-root-0.0.12-windows-x86_64.zip
if errorlevel 1 exit /b 1
%SystemRoot%\System32\tar.exe -xf "%ROOT%\tools\downloads\samsung-tv-root-0.0.12-windows-x86_64.zip" -C "%ROOT%\tools\downloads\root-zip" samsung-tv-root-0.0.12-windows-x86_64/_internal/payloads/common
copy /y "%ROOT%\tools\downloads\root-zip\samsung-tv-root-0.0.12-windows-x86_64\_internal\payloads\common\*" "%ROOT%\tools\payloads\common\" >nul
if not exist "%ROOT%\tools\payloads\common\SamsungTvArchiveRoot.dll" exit /b 1
exit /b 0

:connect_fail
echo.
echo sdb could not connect. On the TV: Smart Hub, Apps, 12345.
echo Turn Developer Mode on, set Host PC IP to this PC, and let the TV reboot.
exit /b 1

:wait_fail
echo The daemon did not come up. See %ROOT%\logs\daemon.log
exit /b 1

:acquire_fail
echo.
echo Root did not come up. If Windows Firewall asked, allow the controller on private networks.
echo Wait about two minutes, then run launch.bat again.
exit /b 1
