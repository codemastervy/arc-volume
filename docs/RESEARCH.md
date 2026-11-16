# Samsung HW-B750 non-IR control: findings (offline, web only). No bytes invented.

## Control paths for the HW-B750
- **Wi-Fi / SmartThings / Samsung Sound**: the B750 has no Wi-Fi. The open-source projects found all
  target Wi-Fi models, so they do not apply:
  - HW-Q990D class local API (port 56001 / TCP 1516): https://community.home-assistant.io/t/samsung-soundbar-local/884397 , https://github.com/snowriderau/SamsungSoundbar
  - OCF/DTLS, verified on HW-Q900C: https://github.com/chemicalsno/hass-samsung-soundbar-ocf
  - SmartThings cloud: https://gist.github.com/c-kick/e15c233262e0050dd3f56a6070525862
- **Samsung Audio Remote** (Bluetooth app for older models): https://www.apkmirror.com/apk/samsung-electronics-co-ltd/samsung-audio-remote/ . Nothing found linking it to the B750.
  No source publishes its Bluetooth command format.
- **Bluetooth/BLE protocol of Samsung soundbars**: no public reverse-engineering found
  (searches for HW-B/HW-Q, RFCOMM/SPP, GATT). Harman StealthTech has one (different vendor): https://github.com/jackspirou/libstealthtech
- **CEC vendor commands / Anynet+**: no public opcode list found. Anynet+ is Samsung's name for CEC
  and is said to follow standard CEC opcodes (https://forums.openpli.org/topic/19186-hdmi-cec-driver-device/);
  a forum remark that Samsung TVs use proprietary extensions is opinion only
  (https://groups.io/g/crestron/topic/samsung_ue65es8005u/35798610).
- **Android side**: HdmiControlManager is privileged (see CEC.md). AOSP files read:
  https://android.googlesource.com/platform/frameworks/base/+/refs/heads/main/services/core/java/com/android/server/hdmi/HdmiCecKeycode.java ,
  .../HdmiControlShellCommand.java

## The soundbar's own remote (IR) per B750D manual excerpts (OCR, unclear)
Sound modes listed: Surround Sound, Standard, Game, Adaptive, DTS Virtual:X, Bass Boost.
Buttons seen: SOUND MODE, WOOFER up/down, PAIR; "hidden button" functions: TV remote control on/off,
TV Auto connect (BT Ready), Bluetooth multi-connection, ID SET, 7 Band EQ, DRC on/off, Bluetooth Power.
No Night mode found. Sources: https://manualslib.mx/manual/920698/Samsung-Hw-B750D.html?page=13 ,
https://www.richersounds.com/content/product_files/SamsungHW_B650D.pdf (sibling model, woofer -6..+6, -12 option).
These are for the D/F variants; confirm on your B750 remote.

## Static analysis of Samsung's app: not done
Reasons: no evidence the B750 is supported by any Samsung app; the app would come from a third-party
mirror; it needs jadx (not installed). Offered, not done. If you want it: I download the APK in an empty
scratch dir, never run it, read the decompiled Bluetooth code, and add findings here as UNVERIFIED.

## Candidate tables (UNVERIFIED)
Standard CEC User Control codes (from AOSP, public spec): see CEC.md. Samsung-specific bytes: **none known**.
IR button names seen in the manual: power, sound mode, woofer up/down (no codes held).
