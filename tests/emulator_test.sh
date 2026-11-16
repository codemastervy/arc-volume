#!/usr/bin/env bash
# Emulator test with a FAKE CEC source: the emulator's STREAM_MUSIC index is driven with
# `cmd media_session volume`, which makes AudioService broadcast the same VOLUME_CHANGED_ACTION
# the TV sends when the soundbar reports its level. A fake Home Assistant webhook (host python)
# records what the app posts. NEVER run this against a real TV: serial is fixed to emulator-5556.
set -euo pipefail
cd "$(dirname "$0")/.."
ADB="adb -s emulator-5556"
PKG=io.github.domanell.arcvolume
PORT=8199
OUT=$(mktemp -d)/posts.jsonl; : > "$OUT"
fails=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: got [$2] want [$3]"; fails=$((fails+1)); fi; }
vol() { $ADB shell am broadcast -n test.fakecec/.SetReceiver --ei level "$1" >/dev/null; }
mute() { $ADB shell am broadcast -n test.fakecec/.SetReceiver --es mute "$1" >/dev/null; }
levels() { python3 -I -c 'import json,sys;print(",".join(str(json.loads(l)["body"]["level"]) for l in open(sys.argv[1])))' "$OUT"; }

python3 tests/fake_ha.py $PORT "$OUT" & FAKE=$!
trap 'kill $FAKE 2>/dev/null || true' EXIT

ARC_HA_WEBHOOK_URL="http://10.0.2.2:$PORT/api/webhook/arc_test" bash build.sh >/dev/null
bash tests/fakecec/build.sh >/dev/null
$ADB install -r tests/fakecec/build/fakecec.apk >/dev/null
$ADB uninstall $PKG >/dev/null 2>&1 || true
$ADB install -r build/arc-volume-*.apk >/dev/null
$ADB shell appops set $PKG SYSTEM_ALERT_WINDOW allow
$ADB logcat -c
$ADB shell am start -n $PKG/.MainActivity >/dev/null
sleep 3
check "service running" "$($ADB shell dumpsys activity services $PKG | grep -c 'ServiceRecord.*VolumeService' | tr -d '\r')" "1"

# A: step-1 bar. Each press = one change.
vol 3; sleep 1; : > "$OUT"
vol 5; sleep 1
vol 6; sleep 1
check "A posts settled levels only" "$(levels)" "5,6"
mute on; sleep 1
check "mute posted" "$(tail -1 "$OUT" | python3 -I -c 'import json,sys;b=json.loads(sys.stdin.read())["body"];print(b["muted"])')" "True"
mute off; sleep 1

# B: step-2 bar. Each press = local +1 then report +2. Intermediates must never be posted.
: > "$OUT"; vol 4; sleep 1; : > "$OUT"
for t in 1 2 3; do b=$((4+2*(t-1))); vol $((b+1)); sleep 0.25; vol $((b+2)); sleep 1.2; done
check "B posts 6,8,10 not 5,7,9" "$(levels)" "6,8,10"
check "B learned step 2" "$($ADB logcat -d -s ArcVolume | grep -c 'learned soundbar step 2' | tr -d '\r')" "1"
vol 11; sleep 0.5
check "overlay window attached" "$($ADB shell dumpsys window windows | grep -q ArcVolumeOverlay && echo yes || echo no)" "yes"
check "payload shape" "$(tail -1 "$OUT" | python3 -I -c 'import json,sys;print(sorted(json.loads(sys.stdin.read())["body"]))')" "['level', 'max', 'muted', 'source', 'step']"
check "path" "$(tail -1 "$OUT" | python3 -I -c 'import json,sys;print(json.loads(sys.stdin.read())["path"])')" "/api/webhook/arc_test"

# C: HA down -> app survives
kill $FAKE; wait $FAKE 2>/dev/null || true; FAKE=
vol 12; sleep 2
check "survives HA down" "$($ADB shell dumpsys activity services $PKG | grep -c 'ServiceRecord.*VolumeService' | tr -d '\r')" "1"

# D: default build (no URL) makes no webhook
bash build.sh >/dev/null
$ADB install -r build/arc-volume-*.apk >/dev/null; $ADB logcat -c
$ADB shell am start -n $PKG/.MainActivity >/dev/null; sleep 3; vol 14; sleep 1
check "no webhook when unconfigured" "$($ADB logcat -d -s ArcVolume | grep -c 'webhook' | tr -d '\r')" "0"

echo "failures: $fails"; exit $fails
