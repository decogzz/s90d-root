# Journal

## 2026-10-24

- Confirmed TV over SDB (port 26101, Developer Mode on): model `QN77S90DAEXZX`,
  `platform_version 9.0`, sdbd 2.2.31. Raw `shell:` service opens then closes
  immediately — matches the documented restricted-shell behavior; the injected
  one-shot (`SVE-2025-50109`) is the only path.
- Plan confirmed with the user. Guardrail: no persistent TV-side changes.
- Repo created under github.com/decogzz as the work home:
  `github.com/decogzz/s90d-root`, local clone `/root/projects/s90d-root`
  (remote `origin` via SSH alias `github.com-personal`), `main` pushed
  (initial commit `145a69f`). Visibility: Public — user decision, keep as-is
  (HTTPS clone URLs keep working).

### Host setup (step 1)

- [x] Download `samsung-tv-root-0.0.12-windows-x86_64.zip` to `tools/downloads/` (gitignored) — sha256 verified
- [x] `sdb.exe` obtained: standalone `sdb_4.2.36_windows-64.zip` package from
      download.tizen.org (no full Tizen Studio needed), installed to
      `C:\Users\decog\s90d-root\tools\tizen-sdb\`
- [x] `samsung-tv-root.exe --sdb ... doctor` → Ready: yes (payloads common/common31/qn90b/qn90f)
- [x] `sdb connect 192.168.50.36:26101` → `device QN77S90DAEXZX`

### Foothold (step 2, go/no-go) — PASSED

- [x] `archive-root probe 192.168.50.36` → **uid 0, euid 0, gid 0, egid 0,
      cap_eff 0000003fffffffff, smack User, .NET 6.0 runtime**.
      Preflight: `/usr/bin/dotnet cap_setgid,cap_sys_admin=ei`,
      `/usr/sbin/sdbd-tarlauncher cap_setgid,cap_setuid=eip`.
      `system files unchanged: yes`, `staging cleaned: yes` (guardrail held).
      Stock v0.0.12 archive route works on the S90D — no couchroot-style
      adaptation needed.
- Gotchas hit along the way (for future reruns):
  - First probe runs failed because the TV→host callback was blocked until the
    Windows firewall "Allow" rules for `samsung-tv-root.exe` were approved;
    each failed callback leaves a TV-side bash hung on `/dev/tcp` for ~2 min
    (TCP SYN retries), clogging sdbd's appinstall path. Wait ~2 min after any
    callback failure.
  - The shell-injection timing check needs `delta >= 1.5s`; a slow first
    control call (first-call setup) can eat the margin — just rerun.
  - Windows host needs `openssl` on PATH: Git for Windows ships one at
    `C:\Program Files\Git\usr\bin\openssl.exe`; `run-probe.bat` on the Windows
    side prepends it.

### Root (step 3) — proven by probe and by the daemon

- [x] The probe performs the full archive-launcher root acquisition (bind-mount
      sdbd public.pem + passwd view, tarlauncher --to-command as uid 0) and
      cleans up. Evidence captured above.
- [x] Host controller daemon (`model = "archive"`) acquired a live session:
      `uid=0 euid=0 gid=0 egid=0 cap_eff=0000003fffffffff smack=User`
      (pid 25404, 2026-10-24 15:11). `execute s90d id` works over that lease.

### Controller + mods (steps 4-5)

- [x] Service census on the TV (145 running services) — see
      `evidence/2026-10-24-census.md`. Memory baseline: 1816840 kB total,
      ~42 MB free, swap 91% used.
- [x] Debloat applied via volatile `systemctl mask --runtime --now` (lives in
      `/run/systemd/system/`, zero persistent changes, all reversible by TV
      reboot). User-selected groups: ads/telemetry/ACR, auto-update, voice AI.
      24 services masked. **The list is data-driven now:** the single source is
      `config/debloat.services` (one service per line: `group | unit | what it
      does`); `scripts/debloat.py sync` regenerates `config/daemon.example.toml`,
      `tools/windows/run-mask-apply.bat` and the README table from it, and
      `--win-config` refreshes the live Windows `config.toml`. To change what
      gets disabled, edit the services file and re-run sync.
      Evidence: `evidence/2026-10-24-masks-applied.md`.
- [x] RAM: available 208 MB → 375 MB (~167 MB freed) right after masking.
- [x] Controller daemon: archive-route backend landed on
      `decogzz/samsung-tv-root` branch `archive-daemon` (commits `f5a33e6`,
      `9240e9f`). Runs from source on Windows via `uv` + the v0.0.12 common
      payloads. `post_root_commands` re-applies the 24 `/run` masks on every
      successful acquisition (verified: `adagent-service` `masked-runtime` /
      `inactive`, RAM available ~340 MB). The 6-minute watcher was stopped
      and its Startup entry removed so it does not fight the daemon for SDB.
      Retry delays are 30/60/90/120s — faster retries clog sdbd.
- [x] `remote devices s90d` works on the live lease. Bluetooth remote is
      kernel name `Smart Control` (`/dev/input/event3`). Free My TV app id
      is `FreeMyTVio.FreeMyTV`.
- [x] Home-key remap — DONE and verified end to end (2026-10-24):
      - Twist: the BT remote's keys do NOT arrive on `Smart Control`
        (`event3`) — that node stayed silent through every press. A raw
        `dd` capture across candidate nodes (`event0/1/3/4/5`) showed Home
        arriving on `wt61p807 rc device` (`/dev/input/event1`) as
        `EV_KEY code 63` = `XF86Home` (confirmed against
        `/usr/share/X11/xkb/tizen_key_layout.txt.tv`).
      - Two bugs fixed along the way (`decogzz/samsung-tv-root`
        `archive-daemon` commit `121bb20`): the archive root agent only
        accepts WRITEFILE inside its per-session staging directory, so the
        remote-input token write to the shared model directory killed the
        root connection 20 ms after acquisition (looping retry-wait).
        Fix: `RootAgentConnection.writable_directory` + token writes moved
        there (remote + native events); qn90b/qn90f unaffected.
      - Final config: device `wt61p807 rc device` (filter mode, uinput
        forwarding) + rule
        `{ device = "wt61p807 rc device", key = "XF86Home", action = "app.launch", app = "FreeMyTVio.FreeMyTV" }`.
      - Verified: Home press → `decision: blocked`, action `app.launch`
        `ok: yes` ("successfully launched pid = 13793"), TV fullscreen appid
        flips `com.samsung.tv.csfs` → `FreeMyTVio.FreeMyTV`; all other keys
        (Right/Down/Up/Back) forward natively. Remote behaves normally,
        only Home is remapped.
      - SSDP presence detection is flaky on this LAN; if the daemon sits in
        `idle` after start, `daemon-cmd.bat root acquire s90d` forces it.

## 2026-10-25

- **"Home key back to stock + root gone" — root cause: standby, NOT a cold
  boot.** Kernel uptime 3.7 days (same boot since 2026-10-21 14:56); the
  /run mask symlinks still carried yesterday's timestamps — /run was never
  wiped. What died overnight: the daemon's root lease + remote filter,
  because standby tears down the TV network and the SDB connection with it.
  The daemon's 4 retries (20:02–20:07) all failed while the TV slept
  ("SDB device not listed"), then it gave up for good; SSDP presence was
  too flaky to wake it when the TV came back.
- **Implication (design):** standby is the DAILY case. Masks survive standby;
  only the root lease + Home remap must be reacquired every time the TV
  wakes. Cold boot (rare: unplug / menu restart / long-press power / fw
  update) additionally wipes /run masks. Both are covered by one mechanism:
  reacquire on "SDB port just became reachable" — the port-poll watcher
  (pending decision), since daemon retries assume a briefly-busy TV, not a
  sleeping one, and SSDP is unreliable on this LAN.
- Forced `root acquire` at 08:31 (pid 7389, uid 0, full caps): all 24 masks
  verified `masked-runtime`/inactive|failed, RAM ~328 MB available, remote
  filter active on `wt61p807 rc device`, Home→FreeMyTV rule re-armed.

### Wake watcher (self-healing host stack) — 2026-10-25

- Built `tools/windows/s90d-root-wake-watcher.ps1` + `install-wake-watcher.cmd`
  (+ `stop-wake-watcher.ps1`): a 2-minute loop that heals the whole host
  stack — 1) daemon not answering → restart via `start-daemon.bat`;
  2) TV SDB port closed → wait for wake; 3) port open but daemon not rooted
  → `root acquire` (resets the daemon's dead retry state; acquire_now
  verified in source to clear attempt/retry-index and return immediately
  on a healthy lease). The daemon stays the only SDB client — the watcher
  only polls TCP 26101 and talks to the daemon's local control API.
- Gotchas fixed while testing: cmd.exe quoting mangled daemon-cmd args
  (call the bat directly with `&` instead); UNC cwd from WSL broke the bats
  (`Set-Location C:\Users\decog\s90d-root` at startup); old mask-watcher
  Startup entry removed so only the wake watcher remains.
- Deployed on the Windows host (pid 15136, Startup entry installed).
  Verified steady state: daemon rooted + TV reachable → watcher correctly
  silent across cycles; logs only on action.
- This closes the standby gap: TV wake → port opens → acquire (~40 s) →
  Home→Free My TV re-armed; masks only need re-applying after a true cold
  boot (post_root_commands handles that in the same acquire).
