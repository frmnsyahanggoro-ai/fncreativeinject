FN CREATIVE — database shard (target ±25.000 baris terkurasi total)

Format:
  Brand|Model|Fingerprint|SecurityPatch

Shard (urutan merge):
  samsung.txt   xiaomi.txt   oppo.txt   realme.txt   pixel.txt   oneplus.txt   others.txt

Merge boot (jika tidak ada database/.remote_db):
  sh /data/props/build_database.sh /data/props/database
  → device_db.txt (satu file; engine hanya membaca ini)

Contoh:
  Samsung|SM-G991B|samsung/o1sxxx/o1s:13/TP1A.220624.014/G991BXXU6EWAF:user/release-keys|2023-06-01

others.txt — merek di luar daftar utama (mis. Motorola, Vivo, dll.).

Unduhan OTA mengisi ulang device_db.txt dan men-set .remote_db — lihat README repo.

Powered by FN CREATIVE.
