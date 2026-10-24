Get-CimInstance Win32_Process -Filter "name='powershell.exe'" |
  Where-Object { $_.CommandLine -like '*s90d-root-watcher*' } |
  ForEach-Object {
    Write-Output "Stopping watcher pid $($_.ProcessId)"
    Stop-Process -Id $_.ProcessId -Force
  }
# Also remove the Startup entry so it does not fight the daemon after login
$startup = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\s90d-mask-watcher.cmd'
if (Test-Path $startup) {
  Remove-Item $startup -Force
  Write-Output "Removed $startup"
}
