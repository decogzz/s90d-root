# S90D root work

Work files for rooting and debloating a Samsung QN77S90DAEXZX (S90D family,
Tizen platform 9.0) over network SDB, and remapping the remote's Home key to
launch [Free My TV](https://github.com/decogzz/free-my-tv) (my fork).

Base tooling and reference:

- [chris-ritsen/samsung-tv-root](https://github.com/chris-ritsen/samsung-tv-root) — the
  toolchain: SDB foothold (`SVE-2025-50109`), model-independent archive-launcher
  root route, host controller daemon, remote observation/remapping.
- [samsung-q70t-tizen-root](https://github.com/chris-ritsen/samsung-q70t-tizen-root) —
  methodology reference: foothold doc, capability scanning, debloat playbook.

## Status

- **Rooted (volatile)** — stock `samsung-tv-root` v0.0.12 `archive-root` route
  works on this S90D; uid 0 with full caps, verified 2026-10-24.
- **Debloat applied** — 24 ads/telemetry/ACR/auto-update/voice services
  runtime-masked in `/run`; RAM available ~208 MB → ~375 MB.
- **Watcher installed** on the Windows host (Startup loop) re-applies masks
  automatically after each TV reboot. The stock daemon doesn't support the
  archive route, so the watcher drives one-shot root sessions instead.
- **Home-key remap: not done** — the remote grab/rules feature requires the
  host controller daemon, which in v0.0.12 only supports QN90B/QN90F backends.
  Needs source-level adaptation (new archive-route daemon backend + persistent
  agent). Deferred; `docs/journal.md` has details.

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

## Hygiene

Following the upstream projects' sanitization practice, this repo never commits:
Samsung binaries (including `sdb`), firmware or firmware dumps, extracted keys,
device tokens, or prebuilt exploit payloads. TV network details live in
`config/local/` (gitignored); `config/` holds only templates.
