Get-CimInstance Win32_Process |
  Where-Object {
    $_.CommandLine -and (
      $_.CommandLine -like '*samsung-tv-root*' -or
      $_.CommandLine -like '*start-daemon*'
    )
  } |
  ForEach-Object {
    Write-Output "Stopping $($_.Name) pid $($_.ProcessId)"
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
  }
