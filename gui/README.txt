FN CREATIVE — APK kontrol grafis (sumber di luar folder module)

Build project Android di repo:
  FN-CREATIVE-Control/

Setelah assembleRelease / assembleDebug, letakkan APK di folder ini sebagai:
  FN-CREATIVE-Control.apk

Jalankan build modul:
  ./build.sh         (Linux/macOS → FN-CREATIVE-AutoProps-v25-Final.zip)
  .\build\build.ps1  (Windows)

Skrip menyalin APK ke module/gui/ lalu membuat ZIP; service.sh mendeploy ke:
  /data/props/gui/FN-CREATIVE-Control.apk

Pasang di perangkat:
  pm install -r /data/props/gui/FN-CREATIVE-Control.apk

Powered by FN CREATIVE.
