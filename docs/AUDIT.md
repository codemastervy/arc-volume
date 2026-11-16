# Source audit (upstream d81c987, 14 Java files, ~2300 lines)

Read in full before any build. Findings:

- **No CEC code.** The app never talks CEC. It listens to Android's own `VOLUME_CHANGED_ACTION` and
  `STREAM_MUTE_CHANGED_ACTION` for `STREAM_MUSIC` and reads `AudioManager.getStreamVolume`. The number
  is the soundbar's level only when the TV runs ARC "full volume" mode and writes the soundbar's
  `<Report Audio Status>` into that stream. On the B750 this is **unverified** (the real check).
- `VolumePredictor` / `StepCalibration`: pure integer logic, learn the bar's per-press step.
- **Upstream had no INTERNET permission, no network code, no `exec`/`Runtime`.** Only reflection:
  `SystemProperties.get` for TCL Guard flags (`SystemScreens`).
- Permissions upstream: FOREGROUND_SERVICE(_SPECIAL_USE), SYSTEM_ALERT_WINDOW, RECEIVE_BOOT_COMPLETED.
  `BootReceiver` and the service/receivers are not abusable from other apps with data (extras are
  only a "reason" string for the log; `VolumeService` is not exported).
- Build: `build.sh`, no Gradle, builds fine with JDK 21 + build-tools 34.0.0 (no 17 needed).

# Changes in this fork
- Added a TV-side "Soundbar Control" panel (ControlActivity, fixed ControlTable, pluggable Transport:
  CecTransport = volume/mute via AudioManager; IrHaTransport = unimplemented stub, supports nothing;
  other rows show NOT SUPPORTED over CEC). No network code, no new permissions. Overlay code untouched.
- Tests: `tests/run.sh` (host unit tests of the step logic),
  `tests/emulator_test.sh` (emulator-5556 only; `tests/fakecec` helper APK plays the soundbar's
  audio-status report by setting STREAM_MUSIC), `scripts/privacy-scan.sh`.
- Home Assistant, webhook and control-panel work was dropped by the user's instruction.

# What emulator tests do NOT prove
The emulator's AudioService stands in for the TV's CEC audio-status path. Whether the TCL C8L passes
volume keys over CEC to the HW-B750 and whether the B750 reports its level is only provable on the real TV.
