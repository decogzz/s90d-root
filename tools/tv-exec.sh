#!/bin/bash
# Execute a command on the TV via the daemon's execute capability.
# Usage: tv-exec.sh "<shell command>"
exec cmd.exe /c 'C:\Users\decog\s90d-root\tools\daemon-cmd.bat' execute s90d --timeout 60 --command-timeout 45 "$1"
