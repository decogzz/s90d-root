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

### Root (step 3) — proven by probe

- [x] The probe performs the full archive-launcher root acquisition (bind-mount
      sdbd public.pem + passwd view, tarlauncher --to-command as uid 0) and
      cleans up. Evidence captured above.

### Root (step 3)

- [ ] probe passes runtime/capability checks, or adapt (capscan + couchroot S90D record)
- [ ] `archive-root root <tv> --command 'id'` → `uid=0`

### Controller + mods (steps 4-5)

- [ ] daemon run config saved
- [ ] Service census on the TV (names will differ from Q70T's)
- [ ] Debloat masks re-applied by daemon; RAM before/after measured
- [ ] Remote Home-key observation → suppress rule
- [ ] `app.launch` action extension → Home opens Free My TV
