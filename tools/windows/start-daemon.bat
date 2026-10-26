@echo off
setlocal EnableExtensions
for %%I in ("%~dp0..\..") do set "ROOT=%%~fI"
if not exist "%ROOT%\controller\pyproject.toml" for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"
set "PATH=%PATH%;C:\Program Files\Git\usr\bin"
set "SAMSUNG_TV_ROOT_CONFIG=%ROOT%\config.toml"
set "SAMSUNG_TV_ROOT_COMMON_PAYLOAD_DIRECTORY=%ROOT%\tools\payloads\common"
set "SDB=%ROOT%\tools\tizen-sdb\sdb.exe"
if not exist "%ROOT%\logs" mkdir "%ROOT%\logs"
cd /d "%ROOT%\controller"
"%ROOT%\tools\uv\uv.exe" run samsung-tv-root --config "%SAMSUNG_TV_ROOT_CONFIG%" --sdb "%SDB%" daemon run >> "%ROOT%\logs\daemon.log" 2>&1
