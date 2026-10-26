# S90D root work

Work files for rooting and debloating a Samsung QN77S90DAEXZX (S90D family,
Tizen platform 9.0) over network SDB, and remapping the remote's Home key to
launch [Free My TV](https://github.com/decogzz/free-my-tv) (my fork).

A clean Windows machine starts at [From scratch](#from-scratch).

Base tooling and reference:

- [chris-ritsen/samsung-tv-root](https://github.com/chris-ritsen/samsung-tv-root) — the
  toolchain: SDB foothold (`SVE-2025-50109`), model-independent archive-launcher
  root route, host controller daemon, remote observation/remapping.
- [samsung-q70t-tizen-root](https://github.com/chris-ritsen/samsung-q70t-tizen-root) —
  methodology reference: foothold doc, capability scanning, debloat playbook.

## Status

- **Rooted (volatile)** — stock `samsung-tv-root` v0.0.12 `archive-root` route
  works on this S90D; uid 0 with full caps, verified 2026-10-24.
- **Debloat applied** — ads/telemetry/ACR, Discover recommendations,
  auto-update and voice services runtime-masked in `/run`.
  The exact list lives in [`config/debloat.services`](config/debloat.services)
  (single source) — see the [Debloat list](#debloat-list) table below.
  Everything systemd still reports as running is in
  [Services still running](#services-still-running).
- **Daemon running** from [`controller/`](controller) (the
  [archive-daemon](https://github.com/decogzz/samsung-tv-root/tree/archive-daemon)
  controller, vendored here). `launch.bat` starts it. It holds a live uid-0
  session and re-applies `/run` masks via `post_root_commands` after every
  TV reboot / reacquire. Log: `logs\daemon.log`.
- **Home-key remap: DONE, verified end to end.** The remote's Home key
  (`XF86Home` on the `wt61p807 rc device` input node) launches
  `FreeMyTVio.FreeMyTV`; all other keys forward natively. The rule lives in
  the host daemon config, nothing on the TV (see journal).

See [docs/journal.md](docs/journal.md) for the running log and
[docs/plan.md](docs/plan.md) for the confirmed plan.

## Guardrail (binding for all work in this repo)

**No persistent TV-side changes.** A reboot returns the TV to fully stock.

Forbidden: raw block writes, `profile.d`/boot-hook patching, TV-side boot
services, package uninstalls, persistent UEP disables, firmware modification.
All debloat masks live in `/run`; remote remaps live on the host PC; both are
re-applied by the host controller daemon, never stored on the TV.

Only persistent artifacts allowed: ordinary user-level items (Developer Mode
setting, installed apps, normal TV settings).

## From scratch

On the TV, once: Smart Hub, Apps, `12345`. Turn Developer Mode on, set Host
PC IP to this PC (`192.168.50.129` on this set), and let the TV reboot.

On Windows, in Command Prompt. Git for Windows has to be installed. The TV
calls back to the PC, so this does not work from WSL.

```
git clone https://github.com/decogzz/s90d-root.git
cd s90d-root
launch.bat
```

`launch.bat` downloads `sdb`, uv, and the controller payloads on first run,
starts the daemon, and takes root. It prints `id`. That should show
`uid=0`. The debloat list and the Home key are applied by that acquire.
The log is `logs\daemon.log`.

Free My TV has to already be installed for Home to open it. The app id is
`FreeMyTVio.FreeMyTV` ([decogzz/free-my-tv](https://github.com/decogzz/free-my-tv)).

The controller source is in [`controller/`](controller). `config.toml` is
created from [`config/daemon.example.toml`](config/daemon.example.toml) the
first time, with this TV's address and the Home rule already filled in.

If Windows Firewall asks, allow the controller on private networks. If root
does not come up, wait about two minutes and run `launch.bat` again.

A cold boot of the TV drops root and the masks. Run `launch.bat` again.
Standby does not. To stop the daemon:

```
powershell -ExecutionPolicy Bypass -File tools\windows\stop-daemon.ps1
```

## Debloat list

The services disabled on the TV are defined in one place:
[`config/debloat.services`](config/debloat.services) — one service per line,
`group | unit | what it does`, grouped by the chosen debloat groups
(`ads-telemetry`, `recommendations`, `auto-update`, `voice`).

**To change what gets disabled:** edit `config/debloat.services`, then run

```
scripts/debloat.py sync              # regenerate example toml, mask bat, this table
scripts/debloat.py sync --win-config # ALSO refresh the LIVE C:\...\s90d-root\config.toml
scripts/debloat.py list [group]      # just show the list
```

The `sync` regenerates `config/daemon.example.toml` (`post_root_commands`),
`tools/windows/run-mask-apply.bat` (standalone mask session) and the table
below — never edit those by hand. Every consumer runs the same mask loop:
`systemctl mask --runtime --now` per unit — volatile `/run` masks only, so a
TV reboot returns everything to stock, and the host daemon re-applies the
list after each successful root acquire. Two Discover tile apps restart
themselves anyway; the same reapply freezes those processes and deletes the
Recommended rows from their database. That is volatile too: a reboot restores
the real programs and the rows, and the next root acquire clears them again.

<!-- debloat-table:begin (generated by scripts/debloat.py sync) -->
| Group | Unit | What it does |
| --- | --- | --- |
| `ads-telemetry` | `adagent-service.service` | ad agent daemon (ads backend) |
| `ads-telemetry` | `contents-recognition-service.service` | ACR content analysis |
| `ads-telemetry` | `contents-cognition-service-manager.service` | ACR content cognition manager |
| `ads-telemetry` | `contents-ui-detector-service.service` | on-screen content UI detection |
| `ads-telemetry` | `screen-analysis-service-manager.service` | screen content analysis |
| `ads-telemetry` | `abnormal_user_behavior.service` | "abnormal user behavior" monitor |
| `ads-telemetry` | `org.tizen.remotepc.service` | RemotePC client (remote support) |
| `ads-telemetry` | `slive-provider-daemon.service` | TV Plus slive ad provider |
| `ads-telemetry` | `reporterCA.service` | SCS reporter CA (telemetry upload) |
| `ads-telemetry` | `scs-agent.service` | Samsung Collect Service agent (telemetry) |
| `ads-telemetry` | `pushd.service` | marketing / push message daemon |
| `ads-telemetry` | `register-device.service` | device registration telemetry |
| `ads-telemetry` | `registertv-service.service` | TV registration telemetry |
| `ads-telemetry` | `registerav-service.service` | AV registration telemetry |
| `ads-telemetry` | `org.tizen.tv.tagpro-service-tv.service` | usage tagging (Tag Pro) |
| `ads-telemetry` | `mirroring-recognition-manager.service` | screen mirroring recognition |
| `ads-telemetry` | `aifw-msf-service.service` | AI framework MSF service |
| `ads-telemetry` | `canalysis-service.service` | content analysis daemon |
| `ads-telemetry` | `org.tizen.tv.sp-kpi.service` | performance metrics (KPI) |
| `ads-telemetry` | `emergency-log-transmitter.service` | sends logs after a fault |
| `ads-telemetry` | `sesd.service` | Samsung Experience Service |
| `ads-telemetry` | `user-presence.service` | detects whether someone is in front of the TV |
| `ads-telemetry` | `wifi-presence.service` | senses presence over Wi-Fi |
| `ads-telemetry` | `wifi-presence.path` | starts Wi-Fi presence when its path triggers |
| `recommendations` | `ContentServiceManager.service` | Smart Hub content manager that starts the Discover feeds |
| `recommendations` | `content-tiles-provider.service` | Discover tile rows, including Recommended for you |
| `recommendations` | `content-grab-service.service` | downloads the Discover tile payloads |
| `recommendations` | `content-grab-service.path` | starts the tile download when its path triggers |
| `recommendations` | `content-db-provider.service` | local database the Discover rails read |
| `recommendations` | `csf-content-engine.service` | Smart Hub content engine |
| `recommendations` | `com.samsung.tv.preview-updater.service` | preview images on recommended tiles |
| `recommendations` | `pisa-service.service` | personalization service that picks the recommendations |
| `recommendations` | `pisa-service.path` | activates personalization when its path triggers |
| `recommendations` | `pisa-service.socket` | socket activation for the personalization service |
| `auto-update` | `swu-auto-upgrade.service` | firmware auto-upgrade daemon |
| `auto-update` | `was-background-update.service` | background updates for web apps |
| `auto-update` | `was-background-update.path` | starts that web-app update when its path triggers |
| `factory` | `org.tizen.tv.automation-service.service` | factory test automation |
| `factory` | `org.tizen.tv.automation-service.path` | starts factory automation when its path triggers |
| `factory` | `vddebugmenu.service` | debug menu |
| `voice` | `muse-server.service` | voice assistant server (Bixby backend) |
| `voice` | `org.tizen.aitech_daemon_service.service` | AI tech daemon (org.tizen) |
| `voice` | `org.tizen.NPUManager.service` | NPU manager for on-device AI (org.tizen) |
| `voice` | `aifw-data-manager.service` | AI framework data store |
| `voice` | `com.samsung.tv.ai-interpreter-service.service` | AI interpreter service (com.samsung.tv) |
| `voice` | `com.samsung.tv.context-aware-agent.service` | context-aware agent (com.samsung.tv) |
| `voice` | `com.samsung.tv.context-aware-service.service` | context-aware service (com.samsung.tv) |
<!-- debloat-table:end -->

## Services still running

Snapshot from the live TV on 2026-10-25: `systemctl list-units --type=service --state=running`.
The masked units in the table above are absent here. A reboot brings the masked
ones back until the host daemon acquires again.

Two of those leftovers stay running because another service requires them.
`org.tizen.tv.factory-service` is required by `comss`, and the input switcher
is ordered after it. `issue_report_agent` is required by `devicetracker`.

### Picture, sound, and inputs

| Unit | What it does |
| --- | --- |
| `aaa_tvs_deamon.service` | TV service daemon: broadcast and the picture path (`tvs-daemon`) |
| `aaa_tvs_lite.service` | Lighter companion of the TV service |
| `tvs-ht.service` | Home-theater side of the TV service |
| `avocd-launcher.service` | AV output control |
| `source-service.service` | Switches inputs (HDMI, tuner, apps) |
| `hdmicec-service.service` | HDMI-CEC |
| `display-rotator.service` | Panel rotation |
| `screend.service` | Screen manager: panel on, off, and blanking |
| `speaker-manager.service` | Speakers |
| `pulseaudio.service` | Mixes audio |
| `org.tizen.AISControlManager.service` | Audio control settings |
| `media-server.service` | Plays media |
| `mediacontroller.service` | Media playback control |
| `pvr-service.service` | Recordings |
| `QSysLink.service` | Link to a Samsung soundbar |
| `color-pick.service` | Color picker used by the UI |
| `focus-server.service` | Tracks which UI item has focus |

### Apps and the Hub

| Unit | What it does |
| --- | --- |
| `ac.service` | Application manager: starts apps and tracks them |
| `app-context-manager.service` | Which app is in front, and how apps interact |
| `app-control-service.service` | Launches an app and hands it a command |
| `coreapp-service.service` | Host for the built-in TV apps |
| `org.tizen.webappservice.service` | Tizen web app runtime |
| `org.tizen.webserver.service` | Local web server those apps use |
| `pkgmgr-info.service` | Installed-package database |
| `launcher-security.service` | Supervisor for the launcher |
| `boot-helper-dyboost-tv.service` | Speeds app launch after boot |
| `awm-service.service` | App window manager (`awm-app`) |
| `aaa_resource-center.service` | Cache of app resources |
| `aaa_rscmgr-service.service` | Manager for that resource cache |
| `dapi-provider.service` | Data API apps read |
| `data-provider-master.service` | Coordinates the data providers |
| `data-service.service` | App data bus |
| `org.tizen.dseal.service` | IPC and HTTP helper for apps |
| `settings-service.service` | TV Settings backend |
| `global-notif-service.service` | System notifications |
| `scim.service` | On-screen keyboard |
| `alarm-server.service` | Timers and alarms |
| `usb-launcher-service.service` | Reacts when a USB stick is inserted |
| `pvod-appfw.pvodservice.service` | Premium video-on-demand apps |
| `gamebar-service.service` | Game Bar overlay |
| `gamepad-service.service` | Gamepads |
| `ambient-ua-agent.service` | Ambient mode |
| `product-operating.service` | Product operating mode (home or retail) |
| `com.samsung.tv.qse-daemon.service` | Quick settings engine |

### Casting and sharing

| Unit | What it does |
| --- | --- |
| `com.samsung.tv.airplay-service-2.service` | AirPlay receiver |
| `com.samsung.tv.googlecast-service.service` | Google Cast |
| `com.samsung.tv.multiscreen.service` | Smart View, phone to TV |
| `com.samsung.tv.audio-share.service` | Shares TV audio to another device |
| `allshare-svc.service` | AllShare (DLNA) |
| `screen_sharing.service` | Screen sharing |
| `wfd-manager.service` | Wi-Fi Direct |
| `p2p-asm.service` | TV viewer session for a peer connection |
| `msf-server.service` | Samsung multi-screen service framework |
| `wireless-cam-service.service` | Wireless camera through that framework |
| `remote-server.service` | Network remote |

### Network

| Unit | What it does |
| --- | --- |
| `connman.service` | Connection manager |
| `connman-logger.service` | Logs the connection manager |
| `net-config.service` | Network configuration |
| `vd-net-config.service` | Network configuration for this display product |
| `NW-Daemon-service.service` | Network daemon |
| `wpa_supplicant.service` | Wi-Fi authentication |
| `wsm-service.service` | Wi-Fi state (`wifi_state_manager`) |
| `wifi-monitor.service` | Wi-Fi hardware monitor |
| `mdnsd.service` | mDNS discovery |
| `sddp.service` | Device discovery on the LAN |
| `devicetracker.service` | Tracks devices the TV has seen |
| `org.tizen.device-detector-service.service` | Detects attached devices |

### Bluetooth

| Unit | What it does |
| --- | --- |
| `bluetooth-frwk-service.service` | Bluetooth stack |
| `bluetooth-monitor.service` | Watches the Bluetooth stack |
| `bleapp-service.service` | Bluetooth Low Energy |
| `bt.connectionmanager.service` | Bluetooth connections |
| `btapp-service.service` | Bluetooth app backend |
| `bt-settings-external-controller-service.service` | Bluetooth settings from an external controller |
| `bam.service` | Background activity manager (`bam_service`) |

### Security and storage

| Unit | What it does |
| --- | --- |
| `securestorage.service` | Encrypted storage |
| `secure-clock.service` | Secure clock used by DRM |
| `security-tzdaemon.service` | TrustZone |
| `central-key-manager.service` | Key store |
| `fkp.service` | DRM key provisioning (`FKPServer`) |
| `psa-init.service` | Platform security startup, after secure storage |
| `license-manager-agent.service` | App license checks |
| `device-policy-manager.service` | Device policy |
| `sfpmd.service` | Smart Security product monitor |
| `TVGuardAgent-service.service` | TV Guard watchdog |
| `zone-manager.service` | Security zones |
| `zone-security-manager.service` | Policy for those zones |
| `storaged.service` | Storage daemon |
| `buxton2.service` | Configuration database |
| `buxton2_lite.service` | Lighter configuration database |

### System

| Unit | What it does |
| --- | --- |
| `deviced.service` | Hardware events |
| `systemd-udevd.service` | Device nodes |
| `systemd-user-sessions.service` | Allows the app user session |
| `sessiond.service` | User sessions |
| `eventd.service` | Starts a process when an event fires |
| `esd.service` | Event system |
| `resourced.service` | CPU and memory policy |
| `reclaimd.service` | Frees memory early |
| `fconfigd.service` | Which product features are enabled |
| `common-daemon-basic-monitor.service` | Basic health monitor |
| `stability-monitor.service` | Watches for crashes and hangs |
| `sensord.service` | Sensors |
| `sdbd.service` | Smart Development Bridge; this is how the host connects |
| `org.tizen.mbr-daemon.service` | MBR-mode daemon; stays up even when that mode is off |
| `ssc-service.service` | `ssc-service` binary; the unit file does not describe it further |
| `ssdm-service.service` | `ssdm-service` binary; the unit file does not describe it further |

### Left running on purpose

| Unit | What it does |
| --- | --- |
| `org.tizen.tv.factory-service.service` | Factory service. `comss` requires it, and input switching is ordered after it |
| `issue_report_agent.service` | Sends problem reports. `devicetracker` requires it |

## Hygiene

Following the upstream projects' sanitization practice, this repo never commits:
Samsung binaries (including `sdb`), firmware or firmware dumps, extracted keys,
device tokens, or prebuilt exploit payloads. `launch.bat` downloads those into
`tools/` on first run (gitignored). TV network details live in
`config/local/` (gitignored); `config/` holds only templates.
