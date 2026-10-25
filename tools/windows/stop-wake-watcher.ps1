# Stops the s90d-root wake watcher and removes its Startup entry.
Get-CimInstance Win32_Process -Filter "name='powershell.exe'" |
  Where-Object { $_.CommandLine -like '*s90d-root-wake-watcher*' } |
  ForEach-Object {
    Write-Output "Stopping watcher pid $($_.ProcessId)"
    Stop-Process -Id $_.ProcessId -Force
  }

$startup = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\s90d-wake-watcher.cmd'
if (Test-Path $startup) {
    Remove-Item $startup -Force
    Write-Output "Removed $startup"
}
