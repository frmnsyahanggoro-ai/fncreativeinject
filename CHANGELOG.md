# Auto Props Engine (Changelog)

_Powered by **FN CREATIVE**._

## v25 (refactor)

- **Satu skrip deploy**: **`module/install.sh`** — root, permission, salin data, merge DB, logging **`/data/props/install.log`**, error handling; dipanggil manual (one-click) atau dari **`service.sh`** (`--quiet --no-engine`).
- **`service.sh`** disederhanakan: delegasi ke **`install.sh`** lalu **`autoprops_engine.sh`**.
- **Dinonaktifkan / dihapus**: `device_optimizer.sh` (overlap **hardware_selector**), `gui_menu.sh`, **`toolkit/gui/`** (dashboard HTTP + busybox `nc` — mengurangi permukaan error).
- **Menu** CLI: opsi **9** = re-sync via **`install.sh`**.

## v25 (earlier)

- Smart profile selection, rotation, shard DB, OTA, companion app, website, CI ZIP **FN-CREATIVE-AutoProps-v25-Final.zip**, banner premium, branding global.

## Earlier development (internal)

Build **CelestialCore** → **FN CREATIVE**.
