@echo off
chcp 65001 >nul
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"
set "PATH=%PATH%;C:\Program Files\Git\usr\bin"
set "SAMSUNG_TV_ROOT_CONFIG=C:\Users\decog\s90d-root\config.toml"
set "SAMSUNG_TV_ROOT_COMMON_PAYLOAD_DIRECTORY=C:\Users\decog\s90d-root\tools\samsung-tv-root\samsung-tv-root-0.0.12-windows-x86_64\_internal\payloads\common"
set "SDB=C:\Users\decog\s90d-root\tools\tizen-sdb\sdb.exe"
cd /d C:\Users\decog\s90d-root\tools\samsung-tv-root-src
C:\Users\decog\s90d-root\tools\uv\uv.exe run samsung-tv-root --config "%SAMSUNG_TV_ROOT_CONFIG%" --sdb "%SDB%" %*
