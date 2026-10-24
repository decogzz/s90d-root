# Windows-side tooling

Runs on the Windows host that shares the TV's LAN (the TV's Developer Mode
"Host PC IP" points at it). The TV→host TCP callbacks require a real Windows
network stack; WSL2 NAT would block them.

## Layout (`C:\Users\decog\s90d-root\`)

| Path | Purpose |
| --- | --- |
| `config.toml` | daemon profile (`model = "archive"`, host, `post_root_commands`) |
| `tools\samsung-tv-root-src\` | patched source (`decogzz/samsung-tv-root` branch `archive-daemon`) |
| `tools\samsung-tv-root\samsung-tv-root-0.0.12-windows-x86_64\_internal\payloads\common\` | built payloads used by the source checkout |
| `tools\tizen-sdb\` | Samsung `sdb.exe` (`sdb_4.2.36_windows-64.zip`) |
| `tools\uv\uv.exe` | runs the patched source (downloads CPython 3.12 on first use) |
| `tools\start-daemon.bat` | foreground `daemon run`, log appended to `logs\daemon.log` |
| `tools\daemon-cmd.bat` | pass-through for `status`, `root acquire`, `execute`, `remote …` |
| `tools\stop-daemon.ps1` | kill the daemon process tree |
| `logs\daemon.log` | controller events (acquire / retry / rooted) |

`openssl` comes from Git for Windows (`C:\Program Files\Git\usr\bin`); the
bats prepend it to PATH.

## Daily use

```
C:\Users\decog\s90d-root\tools\daemon-cmd.bat status
C:\Users\decog\s90d-root\tools\daemon-cmd.bat root acquire s90d --timeout 180
C:\Users\decog\s90d-root\tools\daemon-cmd.bat execute s90d id
C:\Users\decog\s90d-root\tools\daemon-cmd.bat remote devices s90d
```

A TV cold boot drops `/run` masks and the root agent. The daemon sees the
new boot (SSDP, or a manual `root acquire`) and re-runs `post_root_commands`.
If an acquire fails, wait ~2 minutes before retrying: a hung TV-side
`/dev/tcp` clogs sdbd.

## Install / update

`install-daemon.cmd` copies the bats, writes
`%APPDATA%\...\Startup\s90d-root-daemon.cmd`, and starts the daemon. No
admin rights. Do not run the old `install-watcher.cmd` at the same time —
two clients fighting for SDB will clog the TV.

## Home-key remap (next)

1. Set `[televisions.s90d.remote] enabled = true` with
   `{ name = "Smart Control", transport = "bluetooth", model = "VG" }`.
2. Restart the daemon, then `daemon-cmd.bat remote events s90d`.
3. Press Home on the remote; note the `key` field.
4. Add
   `{ device = "Smart Control", key = "<that key>", action = "app.launch", app = "FreeMyTVio.FreeMyTV" }`
   and restart again.
