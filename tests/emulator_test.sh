#!/usr/bin/env bash
# Emulator test with a FAKE CEC source: tests/fakecec sets STREAM_MUSIC like the TV does when the
# soundbar reports <Report Audio Status>. Asserts what the overlay shows (debug log) and that the
# overlay window exists. Serial from ARC_SERIAL (default emulator-5556, must be an emulator); NEVER run against a real TV.
set -euo pipefail
cd "$(dirname "$0")/.."
SERIAL=${ARC_SERIAL:-emulator-5556}; case "$SERIAL" in emulator-*) ;; *) echo "emulator only"; exit 2;; esac
ADB="adb -s $SERIAL"; PKG=io.github.domanell.arcvolume; fails=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: got [$2] want [$3]"; fails=$((fails+1)); fi; }
vol() { $ADB shell am broadcast -n test.fakecec/.SetReceiver --ei level "$1" >/dev/null; }
mute() { $ADB shell am broadcast -n test.fakecec/.SetReceiver --es mute "$1" >/dev/null; }
shown() { $ADB logcat -d -s ArcVolume | grep -o 'shown=[0-9]*' | cut -d= -f2 | paste -sd, -; }
settled() { $ADB logcat -d -s ArcVolume | grep -o 'settled: volume=[0-9]*' | cut -d= -f2 | paste -sd, -; }

bash build.sh >/dev/null
bash tests/fakecec/build.sh >/dev/null
$ADB install -r tests/fakecec/build/fakecec.apk >/dev/null
$ADB uninstall $PKG >/dev/null 2>&1 || true
$ADB install -r build/arc-volume-*.apk >/dev/null
$ADB shell appops set $PKG SYSTEM_ALERT_WINDOW allow
$ADB shell setprop log.tag.ArcVolume DEBUG
$ADB shell input keyevent KEYCODE_HOME; sleep 1
for _ in 1 2 3 4 5; do $ADB shell am start -n $PKG/.MainActivity >/dev/null; sleep 3
  $ADB shell dumpsys activity services $PKG | grep -q "ServiceRecord.*VolumeService" && break; done
check "service running" "$($ADB shell dumpsys activity services $PKG | grep -c 'ServiceRecord.*VolumeService' | tr -d '\r')" "1"

# A: step-1 bar, one change per press
vol 3; sleep 1; $ADB logcat -c
vol 5; sleep 1; vol 6; sleep 1
check "A overlay shows 5,6" "$(shown | cut -d, -f1,2)" "5,6"
mute on; sleep 1
check "mute seen" "$($ADB logcat -d -s ArcVolume | grep -q 'muted=true' && echo yes || echo no)" "yes"
mute off; sleep 1

# B: step-2 bar: each press = local +1 then report +2; step is learned; settled levels are 6,8,10
vol 4; sleep 1; $ADB logcat -c
for t in 1 2 3; do b=$((4+2*(t-1))); vol $((b+1)); sleep 0.25; vol $((b+2)); sleep 1.2; done
check "B settled levels" "$(settled)" "6,8,10"
check "B learned step 2" "$($ADB logcat -d -s ArcVolume | grep -c 'learned soundbar step 2')" "1"
vol 11; sleep 0.5
check "overlay window attached" "$($ADB shell dumpsys window windows | grep -q ArcVolumeOverlay && echo yes || echo no)" "yes"
echo "failures: $fails"; exit $fails
