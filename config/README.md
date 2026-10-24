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
