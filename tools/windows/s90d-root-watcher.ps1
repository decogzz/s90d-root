# s90d-root mask watcher
# Every cycle: if the TV SDB port is reachable, run one idempotent root session
# that re-applies volatile /run masks when a TV reboot cleared them.
# Log: C:\Users\decog\s90d-root\logs\watcher.log

$tv = "192.168.50.36"
$bat = "C:\Users\decog\s90d-root\tools\run-mask-apply.bat"
$log = "C:\Users\decog\s90d-root\logs\watcher.log"
$intervalSeconds = 360

New-Item -ItemType Directory -Force -Path (Split-Path $log) | Out-Null

function Test-TvPort {
    param([string]$ip, [int]$port, [int]$timeoutMs = 1500)
    $client = New-Object Net.Sockets.TcpClient
    try {
        $task = $client.ConnectAsync($ip, $port)
        if ($task.Wait($timeoutMs) -and $client.Connected) { return $true }
        return $false
    } catch { return $false }
    finally { $client.Close() }
}

Add-Content $log "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') watcher started (pid $PID, interval ${intervalSeconds}s)"

while ($true) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if (Test-TvPort -ip $tv -port 26101) {
        Add-Content $log "$ts TV reachable - running mask session"
        try {
            $output = & cmd.exe /c "`"$bat`"" 2>&1 | Out-String
            $marks = ($output -split "`n" | Where-Object { $_ -match "masks-present|REAPPLIED|Mem:|Error|error|failed|Traceback" } | Select-Object -First 5) -join " ;; "
            Add-Content $log "$ts session done: $marks"
        } catch {
            Add-Content $log "$ts session threw: $_"
        }
    } else {
        Add-Content $log "$ts TV unreachable - skipping"
    }
    Start-Sleep -Seconds $intervalSeconds
}
