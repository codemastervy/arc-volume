# Read-only capture plan (NOT RUN: needs user approval, real hardware)

Goal: learn what the TCL and B750 actually do over CEC, without sending anything to either.

Step 1 (TCL, read-only). Needs USB/network debugging switched on on the TCL and one adb connection
to the one IP you give. Commands, all reads:
- `adb shell dumpsys hdmi_control`  -> device list with logical/physical address, **vendor id of the bar**,
  device type, power status, system-audio and ARC state, and the recent CEC message history.
- `adb shell cmd hdmi_control history_size get` (no change).
- `adb shell cmd audio get-volume-behavior` is not guaranteed on this build; skip if absent.
Reveals: whether the TV treats the B750 as audio system, whether `<Report Audio Status>` is received,
the bar's vendor id (is it Samsung's) and which messages the bar has sent. Does NOT send CEC.
Do it while the TV is muted and during the single approved volume check; nothing else is pressed.

Step 2 (optional, only if step 1 shows Samsung vendor frames): capture with a separate Pi + CEC adapter
in listen-only mode (`cec-ctl --monitor-all`) inserted between TV and bar. That changes the HDMI chain,
so it needs its own approval. It sends nothing.

Step 3 (not planned): Bluetooth sniffing of the B750 needs an HCI-capable sniffer and a paired official
app, which the B750 may not even support. Out of scope unless you ask.

Stop point: I do none of this until you say yes.
