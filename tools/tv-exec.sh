#!/bin/bash
# Execute a command on the TV via the daemon's execute capability.
# Usage: tv-exec.sh "<shell command>"
if [ -f /mnt/c/Users/decog/s90d-root/tools/windows/daemon-cmd.bat ]; then
  bat='C:\Users\decog\s90d-root\tools\windows\daemon-cmd.bat'
else
  bat='C:\Users\decog\s90d-root\tools\daemon-cmd.bat'
fi
exec cmd.exe /c "$bat" execute s90d --timeout 60 --command-timeout 45 "$1"
