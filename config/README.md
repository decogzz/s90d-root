# Config

`config/local/` holds the real TV details (gitignored). Copy the template and
fill it in:

```
mkdir -p config/local
cp tv.example.env config/local/tv.env
```

Values referenced by scripts in `scripts/`:

| Variable | Meaning |
|---|---|
| `TV_IP` | TV LAN address (SDB port 26101) |
| `HOST_IP` | Controller PC LAN address (TV calls back here) |
| `SDB` | Path to Samsung `sdb` executable from Tizen Studio |

## Files here

| File | Purpose |
| --- | --- |
| `tv.example.env` | Template for `config/local/tv.env` (real network details) |
| `daemon.example.toml` | **Generated** by `scripts/debloat.py sync` — do not edit by hand |
| `debloat.services` | **The editable single source of truth** for debloated services: one per line, `group | unit | what it does`. Edit this, then run `scripts/debloat.py sync` to regenerate the example toml, the standalone mask bat, and the README table (`--win-config` also refreshes the live Windows `config.toml`). |
