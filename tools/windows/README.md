# Windows-side tooling

Runs on the Windows host that shares the TV's LAN (the TV's Developer Mode
"Host PC IP" points at it). The TV→host TCP callbacks require a real Windows
network stack; WSL2 NAT would block them.

## Layout

| Path | Purpose |
| --- | --- |
| `launch.bat` | the one command: download what is missing, apply the debloat, exit |
| `config.toml` | created on first launch from `config\daemon.example.toml` |
| `controller\` | controller source |
| `tools\payloads\common\` | payloads downloaded by `launch.bat` |
| `tools\tizen-sdb\sdb.exe` | Samsung `sdb.exe`, downloaded by `launch.bat` |
| `tools\uv\uv.exe` | runs the controller |
| `tools\windows\daemon-cmd.bat` | `status`, `root acquire`, `execute`, `remote …` |
| `logs\daemon.log` | controller events |

`openssl` comes from Git for Windows (`C:\Program Files\Git\usr\bin`); the
bats prepend it to PATH.

A clean machine follows [From scratch](../../README.md#from-scratch).
Run `launch.bat` from the repo root.

## Daily use

`launch.bat` applies the debloat once and exits. It stops a leftover daemon
first. The Home key opens Smart Hub.

A TV cold boot drops the `/run` masks. Run `launch.bat` again. If an acquire
fails, wait ~2 minutes before retrying: a hung TV-side `/dev/tcp` clogs sdbd.

## Install / update

`launch.bat` is the start command. `install-daemon.cmd` and
`install-wake-watcher.cmd` also add Windows login startup entries. This
setup does not use those.

## Home key

Not remapped. Home opens Smart Hub.
