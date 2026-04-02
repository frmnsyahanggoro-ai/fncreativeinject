#!/system/bin/sh
# Powered by FN CREATIVE — menu CLI

PROPS="/data/props"

clear 2>/dev/null || true

echo "================================="
echo "       FN CREATIVE ENGINE"
echo "================================="
echo ""
echo "1. Enable profile rotation"
echo "2. Disable rotation"
echo "3. Manual device profile"
echo "4. Detect device info"
echo "5. Database statistics"
echo "6. Update database (remote)"
echo "7. View log"
echo "8. Disable module (safe mode)"
echo "9. Re-sync /data/props (install.sh)"
echo "10. Exit"
echo ""

read opt

case "$opt" in

1)
	touch "$PROPS/.auto_rotate_profile"
	echo "Rotation enabled"
	;;

2)
	rm -f "$PROPS/.auto_rotate_profile"
	echo "Rotation disabled"
	;;

3)
	echo "Enter device model:"
	read profile
	echo "$profile" > "$PROPS/.manual_profile"
	echo "Manual profile set"
	;;

4)
	sh "$PROPS/device_detect.sh"
	;;

5)
	sh "$PROPS/db_stats.sh"
	;;

6)
	sh "$PROPS/update_database.sh"
	;;

7)
	cat "$PROPS/autoprops.log"
	;;

8)
	touch /cache/.disable_autoprops
	echo "Module disabled — reboot"
	;;

9)
	_found=""
	for m in /data/adb/modules/fn_autoprops /data/adb/modules_update/fn_autoprops; do
		if [ -f "$m/install.sh" ]; then
			sh "$m/install.sh" --no-engine
			_found=1
			break
		fi
	done
	if [ -z "$_found" ]; then
		echo "install.sh not found (flash module first)"
	fi
	;;

10)
	exit 0
	;;

esac
