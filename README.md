# FN CREATIVE Android Props Engine

Magisk / KernelSU module: **device props** (brand, model, fingerprint, security patch), **shard database**, **rotation**, **OTA DB**, companion app **`com.fncreative.engine`**.

**Powered by FN CREATIVE.**

## Struktur folder (final)

```text
CelestialCore/
├── module/                      # Isi ZIP flash (akar arsip = folder ini)
│   ├── module.prop
│   ├── banner.png
│   ├── customize.sh
│   ├── install.sh               # ★ Satu skrip deploy / perbaikan / one-click
│   ├── service.sh               # Boot: install.sh --quiet --no-engine + engine
│   ├── post-fs-data.sh
│   ├── uninstall.sh
│   ├── engine/
│   │   ├── autoprops_engine.sh
│   │   ├── ai_selector.sh
│   │   └── hardware_selector.sh
│   ├── config/autoprops.conf
│   ├── database/                # *.txt shard → device_db.txt
│   └── toolkit/
│       ├── menu.sh
│       ├── build_database.sh
│       ├── update_database.sh
│       ├── update_module.sh
│       ├── device_detect.sh
│       └── db_stats.sh
├── gui/                         # APK sumber → di-stage ke module/gui/ saat build
├── FN-CREATIVE-Control/         # App Android (FN CREATIVE Engine)
├── website/                     # Landing statis (GitHub Pages)
├── build/                       # build.sh / build.ps1 → ZIP rilis
├── build.sh                     # Memanggil build/build.sh
├── tools/                       # build_banner.py, validate_device_db.py
├── .github/workflows/build.yml
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## One-click di perangkat (`install.sh`)

Setelah modul ter-flash, isi modul ada di (contoh Magisk):

`/data/adb/modules/fn_autoprops/`

**Satu perintah (root), tanpa input:**

```sh
su -c "sh /data/adb/modules/fn_autoprops/install.sh"
```

Atau dari **menu** modul opsi `9` (jalankan `install.sh --no-engine`).

Yang dilakukan skrip:

- Cek **root** dan **`/data`**
- Resolve **`MODDIR`** (argumen `$0` atau path modul standar Magisk / KSU)
- **`chmod 700`** pada `/data/props` dan `database/`
- Menyalin **config**, **shard database**, **engine**, **toolkit**, **gui** (APK)
- Menjalankan **`build_database.sh`** jika tidak ada **`database/.remote_db`**
- Log: **`/data/props/install.log`**
- Opsional menjalankan **`autoprops_engine.sh`** (default **ya**; boot memakai **`--no-engine`** supaya engine dijalankan dari **`service.sh`**)

Opsi internal: `--quiet` · `--no-engine` · `--no-merge`

## Build ZIP rilis

```bash
chmod +x build.sh build/build.sh
./build.sh
```

Output: **`FN-CREATIVE-AutoProps-v25-Final.zip`** (akar modul Magisk, tanpa folder pembungkus).

## Fitur inti

- Engine + log `[FN CREATIVE] …` (**engine start**, **AI profile applied**, **database updated** / **rebuilt**, dll.)
- Shard → **`device_db.txt`**; pembaruan OTA memakai **`update_database.sh`**
- **`hardware_selector.sh`** / **`ai_selector.sh`** (konfigurasi di **`autoprops.conf`**)
- App **FN CREATIVE Engine** (`com.fncreative.engine`)
- Safe mode: `touch /cache/.disable_autoprops` lalu reboot

## Disclaimer

Gunakan pada perangkat milik sendiri dan untuk tujuan sah. Mengubah props dapat merusak aplikasi atau melanggar ketentuan layanan.

*Powered by FN CREATIVE.*
