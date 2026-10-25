# s90d-root daemon helper: keeps the stack self-healing on the Windows host.
#
# WHAT IT HEALS (in order, each cycle):
#   1. Daemon down          -> restart it via start-daemon.bat (the CLI
#      discovers the daemon through a token endpoint file in LOCALAPPDATA;
#      if no daemon answers, every daemon-cmd call fails, so the watcher
#      restarts it, then continues).
#   2. TV SDB port unreachable -> nothing to do; TV is off/booting/sleeping.
#      Next cycle catches the wake (standby = the daily case).
#   3. TV reachable but daemon reports no root lease -> "root acquire":
#      resets the daemon's retry state and acquires fresh (~40 s), which
#      re-runs post_root_commands (re-applies /run masks after a cold boot)
#      and re-arms the remote filter with the Home->Free My TV rule.
#
# WHY: the daemon's own retry budget (4 tries over ~5 min) assumes a
# briefly-busy TV, not a sleeping one; SSDP presence is flaky on this LAN.
# This watcher never touches SDB itself — the daemon stays the ONLY SDB
# client (the old run-mask-apply watcher fought the daemon for SDB).
# A sleeping TV costs one cheap TCP poll + one status call per cycle.
#
# Install: tools\windows\install-wake-watcher.cmd (Startup entry, no admin).
# Stop:    tools\windows\stop-wake-watcher.ps1. Log: logs\wake-watcher.log.

$ErrorActionPreference = "Stop"

# --- config -----------------------------------------------------------------
$tv       = "192.168.50.36"
$port     = 26101
$bat      = "C:\Users\decog\s90d-root\tools\daemon-cmd.bat"
$startBat = "C:\Users\decog\s90d-root\tools\start-daemon.bat"
$log      = "C:\Users\decog\s90d-root\logs\wake-watcher.log"
$intervalSeconds = 120

# --- functions ---------------------------------------------------------------
function Write-Log([string]$msg) {
    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $log -Value "$stamp $msg"
}

function Test-DaemonUp {
    # One cheap status call; used both to check liveness and as the
    # daemon-cmd handshake. Returns the raw output (empty on failure).
    try {
        $out = & $bat "status" 2>&1 | Out-String
    } catch { return "" }
    return $out
}

function Test-TvPort {
    param([string]$ip, [int]$portNum, [int]$timeoutMs = 1500)
    $client = New-Object Net.Sockets.TcpClient
    try {
        $task = $client.ConnectAsync($ip, $portNum)
        if ($task.Wait($timeoutMs) -and $client.Connected) { return $true }
        return $false
    } catch { return $false }
    finally { $client.Close() }
}

# --- main loop ---------------------------------------------------------------
New-Item -ItemType Directory -Force -Path (Split-Path $log) | Out-Null
# cmd.exe (used for the bats) cannot inherit a UNC cwd; force a local one.
Set-Location "C:\Users\decog\s90d-root"
Write-Log "wake-watcher started (pid $PID, interval ${intervalSeconds}s, target ${tv}:${port})"

while ($true) {
    try {
        # 1) Daemon liveness: one status call. If it fails to answer,
        #    restart it (a fresh daemon reads config.toml and re-arms
        #    remote rules on its next acquire).
        $status = Test-DaemonUp
        $daemonUp = $status -match "television:"
        if (-not $daemonUp) {
            Write-Log "daemon not answering - restarting via start-daemon.bat"
            Start-Process -FilePath $startBat -WindowStyle Hidden
            Start-Sleep -Seconds 45   # daemon start + TV discovery
            $status = Test-DaemonUp
            $daemonUp = $status -match "television:"
            if (-not $daemonUp) {
                Write-Log "daemon restart not confirmed; retrying next cycle"
                Start-Sleep -Seconds $intervalSeconds
                continue
            }
        }

        # 2) TV reachability: if the SDB port is closed, the TV is
        #    off/booting/sleeping. Nothing to do this cycle.
        if (-not (Test-TvPort -ip $tv -portNum $port)) {
            # TV offline: nothing to do; next poll catches the wake.
            Start-Sleep -Seconds $intervalSeconds
            continue
        }

        # 3) TV reachable: make sure the daemon holds a root lease.
        $rooted = $status -match "state:\s*rooted"
        if (-not $rooted) {
            Write-Log "TV online, daemon not rooted - acquiring"
            $result = & $bat "root" "acquire" "s90d" "--timeout" "180" 2>&1 | Out-String
            if ($result -match "uid:\s*0" -or $result -match "state:\s*rooted") {
                Write-Log "acquire ok"
                Start-Sleep -Seconds 10   # let post_root_commands + remote settle
            } else {
                Write-Log "acquire not confirmed: $($result -replace '\s+', ' ')"
            }
        }
        # Rooted already: nothing to do this cycle.
    } catch {
        Write-Log "cycle threw: $_"
    }
    Start-Sleep -Seconds $intervalSeconds
}
