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
