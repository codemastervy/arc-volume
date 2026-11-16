# The single real check (TCL C8L + HW-B750), with you watching
Prereqs: Android 14 on the TV (confirmed). Nothing else is touched.
1. Mute the TV (TV remote mute) and keep the soundbar low. Build locally: `bash build.sh` (debug-signed APK).
2. Enable Developer options > USB/network debugging on the TV, `adb connect <TV IP>` (the one IP you give), `adb install -r build/arc-volume-*.apk`.
3. Open "ARC Volume" from the apps row, allow "Display over other apps" when asked.
4. Press the TV remote Volume Up once. Expected: a number appears under the TV volume panel.
5. Compare with the B750's own display/LED count: must match within one step. Press Volume Down once; repeat 3 times.
6. Press Mute: crossed-out speaker should show.
7. Pass = number tracks the bar. Fail = TV shows only +/- and no number, or the number never matches: then the B750 does not report its level over CEC (or the TCL does not send CEC volume); I report that and do not fake a number.
8. Optional read-only extra (needs your yes): `adb shell dumpsys hdmi_control` (see CAPTURE_PLAN.md).
9. Cleanup: `adb uninstall io.github.domanell.arcvolume`, turn debugging off.
