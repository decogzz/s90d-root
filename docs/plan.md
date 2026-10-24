---
name: Root and mod the S90D over SDB
overview: ""
todos:
  - id: setup
    content: Download samsung-tv-root v0.0.12 Windows release + install Tizen Studio CLI for sdb.exe; run doctor
    status: pending
  - id: foothold
    content: Run archive-root probe to test SDB injection foothold (go/no-go gate)
    status: pending
  - id: root
    content: Attempt root via archive-launcher route; fall back to capability/mount-namespace adaptation if cap_sys_admin missing
    status: pending
  - id: daemon
    content: Set up host controller daemon for volatile root reacquisition after TV reboots
    status: pending
  - id: mods
    content: Apply chosen mods (debloat masks, Home-key remap to Free My TV, etc.)
    status: pending
isProject: false
---

# Root and mod the QN77S90D over network SDB (no cable)

## Goal
Attempt root on the TV at `192.168.50.36` (QN77S90DAEXZX, Tizen platform 9.0, Developer Mode already on) using `samsung-tv-root` (chris-ritsen) as the toolchain, with `samsung-q70t-tizen-root` docs as methodology reference. Then apply mods (e.g. debloat, remote remap such as Home → Free My TV).

## Key facts driving the plan
- Foothold = SVE-2025-50109 SDB package-name injection → `uid=901(sdk)`, network-only. Implemented in [sdb.py](samsung-tv-root/src/samsung_tv_root/sdb.py) (`build_shell_injection`, `SdbClient.capture`), documented in [01-foothold.md](samsung-q70t-tizen-root/docs/methodology/01-foothold.md).
- Root route = model-independent archive-launcher ([archive_root.py](samsung-tv-root/src/samsung_tv_root/archive_root.py)): checks SDB foothold, `cap_sys_admin` file capabilities, tar support, and the TV's installed .NET runtime; stages `SamsungTvArchiveRoot.dll` into `/home/owner/share/tmp/sdk_tools`.
- Your TV is same family as the reported-rooted S90D (`T-PTMDAKUC-0090-2130.0`), but that owner needed a capability/mount-namespace adaptation → the stock route may fail and require adaptation (fallback phase below).
- Risk level: foothold + archive route are low-risk (no raw block writes; staging is cleaned up). The Q70T's persistent raw-block patch route is NOT used.
- Samsung's `sdb` binary is required (not redistributable). Prebuilt release v0.0.12 for Windows x86_64 includes TV payloads — no .NET SDK build needed.

## Steps

1. **Host setup (Windows side, driven from WSL via `powershell.exe`)**
   - Download `samsung-tv-root-0.0.12-windows-x86_64.zip` from the releases page; extract; run `samsung-tv-root.exe doctor`.
   - Install Tizen Studio (CLI tools package is enough) to provide `sdb.exe`; verify `sdb connect 192.168.50.36:26101`.
   - Why Windows side: the injected command captures output via a TCP callback TV → host; WSL2 NAT would block it. (Alternative if preferred: run in WSL + `netsh portproxy` forward — we can decide during execution.)

2. **Foothold test (go/no-go gate #1)**
   - `samsung-tv-root.exe archive-root probe 192.168.50.36` — first verifies the injection gives uid 901.
   - If the injection is rejected (as happens on one Tizen 10 build), stop and reassess; no known workaround for a rejected foothold.

3. **Root attempt**
   - `probe` also checks dotnet runtime + file capabilities. If all pass: `archive-root root 192.168.50.36 --command 'id'` → expect `uid=0`.
   - **Fallback if `cap_sys_admin` is missing on dotnet (likely on this Tizen 9 build):** enumerate capability-bearing binaries on the TV (adapt `capscan.sh` from the q70t repo), and study the couchroot S90D device record + owner's route description (linked in the compatibility table) for the capability/mount-namespace adaptation they used. This phase is exploratory and may take iterations.

4. **Keep root available**
   - `samsung-tv-root.exe daemon run` — reacquires volatile root after TV reboots. Root stays volatile (cleared on power-off), which is the safe design; no TV-side boot persistence.

5. **Mods — primary goal: debloat**
   - **Debloat (primary, low-risk):** enumerate services on the TV first (`systemctl` census from a root shell; names may differ from the Q70T's), then disable ad/ACR/bloat via `/run` masks — the Q70T reference set is `acr.service`, `acr.path`, `contents-recognition-service`, `vision-data-recognition-service`, `vdsystem-update-manager`, `org.tizen.remotepc` (measured effect there: free RAM 213 MB → 830 MB). Plus `ConditionPathExists` marker guards for ad backends (pisa/adagent, TV Plus slive) and optional DNS → AdGuard Home. Masks are volatile: the controller daemon re-applies them after each boot (semi-persistent, zero raw writes, fully reversible by deleting mask symlinks).
   - **Home-key remap (secondary):** free-my-tv-style home stays a signed web app (already built/forked). To make the remote's Home open it: enable remote handling in the controller, observe the Home key code, add a `suppress` rule, and extend the packaged action set with a small `app.launch` action (schema entry + host dispatcher mapping + model capability implementation, per [REMOTE_POLICY.md](samsung-tv-root/docs/user/REMOTE_POLICY.md) "Extending it"). Requires the controller running on the LAN host; nothing persists on the TV.
   - **Out of scope (revisit later):** replacing Smart Hub itself as the true default launcher — reported done on this exact S90D family by the couchroot owner, but requires persistent TV-side changes with real brick risk; not part of this plan.

## Guardrail: no persistent changes
Everything in this plan is volatile — a reboot returns the TV to fully stock. Explicitly forbidden during execution: raw block writes, the Q70T `profile.d`/`persistent-hook` patcher, boot hooks, TV-side boot services, package uninstalls, and any UEP-persistent disable. All debloat/remaps live in `/run` or on the host PC and are re-applied by the controller daemon only. The only persistent artifacts allowed are ordinary user-level ones (Developer Mode setting, installed apps, TV settings).

## Risks / unknowns
- Foothold may be rejected on this exact build (go/no-go at step 2).
- Stock archive route may fail without the capability/mount-namespace adaptation (step 3 fallback).
- Your variant is LatAm region `EXZX`, not the reported US `FXZA` — same firmware family expected, but unproven.
- Root is volatile by design; TV internet-blocking and observation features stay off unless you opt in.