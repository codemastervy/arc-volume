# What HDMI-CEC can and cannot do for the HW-B750 from the TCL (Android 14)

Status: research only. Every row marked UNVERIFIED needs the real-hardware read-only capture
in `CAPTURE_PLAN.md` (not run; waiting for approval).

## What a normal Android app can reach
- `HdmiControlManager` / `HdmiClient.sendVendorCommand` are system APIs guarded by the `HDMI_CEC`
  permission; a sideloaded app cannot hold it. (Android source and docs, see RESEARCH.md.)
- AOSP maps no Android key to CEC "Select Sound Presentation" (0x57): source comment
  "No Android keycode defined for CEC_KEYCODE_SELECT_SOUND_PRESENTATION". So the TV never sends it
  on an app's behalf.
- What does work for an app: `AudioManager.adjustStreamVolume` (raise / lower / toggle mute). With the
  soundbar as audio system and the TV in full-volume mode, the TV turns these into standard CEC
  `<User Control Pressed>` volume up (0x41) / down (0x42) / mute (0x43) to the soundbar, and the
  bar answers `<Report Audio Status>`. This is what ARC Volume reads. Only this path is usable by an app.

## Table
| Function | Standard CEC message exists? | Reachable from a sideloaded app? | Verdict |
|---|---|---|---|
| Volume up/down | yes, User Control 0x41/0x42 | yes, via AudioManager | CEC, works via AudioManager (no app built for it) |
| Mute | yes, 0x43 | yes, via AudioManager | CEC, works via AudioManager (no app built for it) |
| Level read-back | yes, `<Report Audio Status>` | yes, via STREAM_MUSIC index (full-volume mode) | CEC, B750 reporting UNVERIFIED |
| Power on/off of the bar | yes (0x40 / 0x6C / 0x6D), also System Audio Mode | no per-device control; TV standby may power the bar | not controllable; use IR |
| Sound mode | partly: User Control "Select Sound Presentation" 0x57 with operands (Auto equalizer 0xA0, Down mix 0x80, Auto reverb 0x90, Mix 0x20/0x30) | no (no Android key, system API only) | cannot; B750 support also UNVERIFIED |
| Bass / treble step | yes in spec, operands 0xB1 + / 0xB2 neutral / 0xB3 −, treble 0xC1/0xC2/0xC3 | no (same) | cannot; whether the bar's sub follows is UNVERIFIED |
| Samsung sub level, named modes (Game, Adaptive, DTS Virtual:X ...) | no standard message | no | would need Samsung vendor commands: **no public documentation found** |

## Paths that would send raw CEC (all need approval, none attempted)
1. `adb shell cmd hdmi_control vendorcommand -t <type> -d <dest> -a <hex:args> [-i true|false]`
   exists in AOSP `HdmiControlShellCommand`. It sends only `<Vendor Command>` frames, not
   User Control. It needs adb to the TV and the Samsung opcode bytes (unknown).
2. A Raspberry Pi / Linux CEC adapter that stands in for the TV (`cec-ctl`) can send any CEC
   frame. This is the fallback already in the plan; probing the real bar this way is real hardware.
