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
  (initial commit `145a69f`). Visibility: currently Public — flip to Private
  pending user decision (note: flipping breaks HTTPS pulls; use the SSH
  remote).

### Host setup (step 1)

- [ ] Download `samsung-tv-root-0.0.12-windows-x86_64.zip` to `tools/downloads/` (gitignored)
- [ ] Install Tizen Studio CLI tools on Windows for `sdb.exe`
- [ ] `samsung-tv-root.exe doctor` passes
- [ ] `sdb connect <tv>:26101` works

### Foothold (step 2, go/no-go)

- [ ] `archive-root probe <tv>` → injection gives uid 901

### Root (step 3)

- [ ] probe passes runtime/capability checks, or adapt (capscan + couchroot S90D record)
- [ ] `archive-root root <tv> --command 'id'` → `uid=0`

### Controller + mods (steps 4-5)

- [ ] daemon run config saved
- [ ] Service census on the TV (names will differ from Q70T's)
- [ ] Debloat masks re-applied by daemon; RAM before/after measured
- [ ] Remote Home-key observation → suppress rule
- [ ] `app.launch` action extension → Home opens Free My TV
