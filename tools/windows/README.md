# Windows-side tooling

Runs on the Windows host that shares the TV's LAN (the TV's Developer Mode
"Host PC IP" points at it). The TV->host TCP callbacks require a real Windows
network stack; WSL2 NAT would block them.

## Layout (on the Windows host, `C:\Users\decog\s90d-root\`)

| Path | Purpose |
| --- | --- |
| `tools\samsung-tv-root\samsung-tv-root-0.0.12-windows-x86_64\` | upstream release (exe + payloads + source) |
| `tools\tizen-sdb\` | Samsung `sdb.exe` (standalone package `sdb_4.2.36_windows-64.zip` from download.tizen.org) |
| `tools\run-mask-apply.bat` | one idempotent root session; re-applies `/run` masks if a TV reboot cleared them |
| `tools\s90d-root-watcher.ps1` | loop: every 6 min, if TV port 26101 reachable, run `run-mask-apply.bat`; logs to `logs\watcher.log` |
| `logs\watcher.log` | watcher history |

`openssl` comes from Git for Windows (`C:\Program Files\Git\usr\bin`) — the
bats prepend it to PATH.

## Install / update

Run `install-watcher.cmd` (from this directory on the Windows host or via the
repo copy at `tools/windows/`). It copies the watcher + apply bat, drops a
Startup entry (`%APPDATA%\...\Startup\s90d-mask-watcher.cmd`), and starts the
watcher immediately. No admin rights required.

## Notes

- The stock `samsung-tv-root` v0.0.12 daemon supports only qn90b/qn90f
  backends, so the watcher calls `archive-root root ... --command` directly.
- After any callback failure the TV-side sdbd appinstall path can stay clogged
  for ~2 minutes (hung `/dev/tcp` retries); the watcher's next cycle retries
  on its own.
- Everything the session does on the TV is volatile (`/run` masks only);
  a TV reboot fully reverts the masks until the watcher re-applies them.
