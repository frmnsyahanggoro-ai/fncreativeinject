#!/system/bin/sh
# Powered by FN CREATIVE — installer gaya ROM

ui_print " "
ui_print "███████╗███╗   ██╗"
ui_print "██╔════╝████╗  ██║"
ui_print "█████╗  ██╔██╗ ██║"
ui_print "██╔══╝  ██║╚██╗██║"
ui_print "██║     ██║ ╚████║"
ui_print "╚═╝     ╚═╝  ╚═══╝"

ui_print " "
ui_print "        FN CREATIVE"
ui_print "   Android Props Engine"
ui_print " "
ui_print "Powered by FN CREATIVE"
ui_print " "

sleep 1

ui_print "[10%] Initializing engine..."
sleep 0.4

ui_print "[30%] Loading configuration..."
sleep 0.4

ui_print "[60%] Preparing database..."
sleep 0.4

ui_print "[90%] Finalizing installation..."
sleep 0.4

ui_print "[100%] Installation complete"

ui_print " "
ui_print "Please reboot your device"
ui_print " "
ui_print "Repair data: su -c sh /data/adb/modules/fn_autoprops/install.sh"
