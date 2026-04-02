#!/system/bin/sh
# Powered by FN CREATIVE

LOG="/data/props/autoprops.log"

CPU=$(getprop ro.board.platform)
GPU=$(getprop ro.hardware.egl)
RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')

echo "[FN CREATIVE] Hardware CPU=$CPU GPU=$GPU RAM=$RAM" >> "$LOG"

if echo "$CPU" | grep -qi "sdm"; then

PROFILE="Pixel 7"

elif echo "$CPU" | grep -qi "mt"; then

PROFILE="Redmi Note 12"

elif echo "$CPU" | grep -qi "exynos"; then

PROFILE="Samsung Galaxy S21"

else

PROFILE="Generic Android Device"

fi

setprop ro.product.model "$PROFILE"

echo "[FN CREATIVE] AI profile applied $PROFILE" >> "$LOG"
