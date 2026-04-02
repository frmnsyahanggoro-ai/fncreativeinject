#!/system/bin/sh
# Powered by FN CREATIVE

echo "===== Auto Props Engine — device detect ====="
printf '%s' "ro.product.brand="
getprop ro.product.brand
printf '%s' "ro.product.model="
getprop ro.product.model
printf '%s' "ro.board.platform="
getprop ro.board.platform
printf '%s' "ro.build.fingerprint="
getprop ro.build.fingerprint
printf '%s' "ro.build.version.security_patch="
getprop ro.build.version.security_patch
