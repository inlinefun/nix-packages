# "Nix Packages" (?)

### Build caching
For faster rebuilds, there is `!TODO: add shit here`, stored in `/var/cache/`

```nix
  nix.settings.extra-sandbox-paths = [
    "/var/cache/sccache"
    "/var/cache/cpm"
  ];
```
```nix
  systemd.tmpfiles.rules = [
    "d /var/cache/sccache 0775 root nixbld - -"
    "d /var/cache/cpm     0775 root nixbld - -"
  ];
```
