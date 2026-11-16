# arc-volume

> Fork of [Domanell/android-tv-arc-volume](https://github.com/Domanell/android-tv-arc-volume). MIT, with the original copyright kept in [LICENSE](LICENSE).

An Android TV app that puts the soundbar's real volume level on screen as a number. It is for the case where a
soundbar on HDMI ARC takes over the volume and the TV's own volume bar stops showing a level.

| The number | Muted |
|---|---|
| ![Volume 14](docs/screens/overlay-volume.png) | ![Muted](docs/screens/overlay-muted.png) |

(A soundbar reporting level 14, then mute. The small box on the right is the overlay.)

## What it does
- Listens for Android's own volume and mute broadcasts for the music stream and draws the level in a small overlay that
  hides after a moment. It does not speak CEC itself: when the TV is in ARC "full volume" mode, the TV writes the soundbar's
  reported level into that stream, and this app displays it.
- Learns how many levels the soundbar moves per press (a step of 2 is common) so the number is right straight after a press,
  then corrects it when the soundbar's report arrives.
- Shows a crossed-out speaker when muted. You can move and scale the box.
- Needs Android 14+ and the "Display over other apps" permission. It has no internet permission and no accounts.

## What is different from upstream
- **Soundbar control panel** (`ControlActivity`): a D-pad screen with Volume up/down and Mute, sent through the normal Android
  volume calls (which the TV turns into CEC volume commands), plus power, sound mode and subwoofer rows. Those last three
  are shown as "NOT SUPPORTED over CEC" rather than pretending, because plain CEC does not carry them.
- Written notes on what CEC can and cannot do for a Samsung HW-B750 from a TCL TV
  ([docs/CEC.md](docs/CEC.md), [docs/RESEARCH.md](docs/RESEARCH.md)), a source audit ([docs/AUDIT.md](docs/AUDIT.md)) and a one-off
  real-hardware check plan ([docs/REAL_CHECK.md](docs/REAL_CHECK.md)).
- The upstream screenshots are gone; the ones here are mine. See [CHANGELOG.md](CHANGELOG.md).

![Soundbar control panel](docs/screens/soundbar-control.png)

## Build and install
JDK 17+ and the Android SDK (platform 34, build-tools 34.0.0). No Gradle.
```sh
bash build.sh                       # build/arc-volume-<version>.apk, debug-signed
adb -s <one device> install -r build/arc-volume-*.apk
```
Open **ARC Volume**, allow "Display over other apps", and the main screen should say Running.

![Main screen](docs/screens/main.png)

Build it yourself from this source; there is no prebuilt binary here. Some TVs (TCL among them) don't start apps by
themselves after a restart: check Permissions and auto-start in the app.

## Status
Not yet verified on a real TV: whether the TCL passes the soundbar's level through, and whether a Samsung HW-B750 reports
it at all; see docs/REAL_CHECK.md. If it doesn't, the app shows nothing rather than inventing a number. Sound mode,
subwoofer and power cannot be sent over CEC from an app; `IrHaTransport` is an empty placeholder.

## Undo
`adb uninstall io.github.domanell.arcvolume`, or uninstall it from the TV's app settings. If you allowed auto-start through
ADB, that goes with the app.

## Credit
Original app and overlay design: Domanell (MIT).
