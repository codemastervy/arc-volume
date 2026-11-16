#!/usr/bin/env bash
# Soundbar Control panel on emulator-5556: D-pad focus order, CEC volume path (real AudioService),
# unsupported rows labelled. NEVER run against a real TV.
set -euo pipefail
cd "$(dirname "$0")/.."
SERIAL=${ARC_SERIAL:-emulator-5556}; case "$SERIAL" in emulator-*) ;; *) echo "emulator only"; exit 2;; esac
ADB="adb -s $SERIAL"; PKG=io.github.domanell.arcvolume; fails=0; D=$(mktemp -d)/u.xml
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: got [$2] want [$3]"; fails=$((fails+1)); fi; }
focus() { $ADB shell uiautomator dump /sdcard/u.xml >/dev/null 2>&1; $ADB exec-out cat /sdcard/u.xml > "$D"; python3 -I tests/focus.py "$D"; }
key() { $ADB shell input keyevent "$1"; sleep 0.4; }
bash build.sh >/dev/null; bash tests/fakecec/build.sh >/dev/null
$ADB install -r tests/fakecec/build/fakecec.apk >/dev/null
$ADB uninstall $PKG >/dev/null 2>&1 || true; $ADB install -r build/arc-volume-*.apk >/dev/null
$ADB shell appops set $PKG SYSTEM_ALERT_WINDOW allow
$ADB shell am start -n $PKG/.ControlActivity >/dev/null
for _ in $(seq 1 20); do [ "$(focus)" = "Volume up" ] && break; sleep 1; done
want=("Volume up" "Volume down" "Mute" "Soundbar power" "Sound mode" "Subwoofer +" "Subwoofer −")
got=("$(focus)"); for i in 1 2 3 4 5 6; do key KEYCODE_DPAD_DOWN; got+=("$(focus)"); done
check "focus order" "$(printf '%s|' "${got[@]}")" "$(printf '%s|' "${want[@]}")"
key KEYCODE_DPAD_DOWN; check "stops at last" "$(focus)" "Subwoofer −"
for i in 1 2 3 4 5 6; do key KEYCODE_DPAD_UP; done; check "back to first" "$(focus)" "Volume up"
$ADB shell am broadcast -n test.fakecec/.SetReceiver --ei level 5 >/dev/null; sleep 1
vol() { $ADB shell cmd media_session volume --stream 3 --get 2>&1 | grep -o 'volume is [0-9]*' | cut -d' ' -f3; }
key KEYCODE_DPAD_CENTER; sleep 1; check "Volume up OK -> 6" "$(vol)" "6"
key KEYCODE_DPAD_DOWN; key KEYCODE_DPAD_CENTER; sleep 1; check "Volume down OK -> 5" "$(vol)" "5"
$ADB shell uiautomator dump /sdcard/u.xml >/dev/null 2>&1
check "unsupported labelled" "$($ADB exec-out cat /sdcard/u.xml | grep -o 'NOT SUPPORTED over CEC' | wc -l | tr -d ' ')" "4"
echo "failures: $fails"; exit $fails
