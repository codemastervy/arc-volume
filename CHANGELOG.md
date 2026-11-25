# Changelog (fork of Domanell/android-tv-arc-volume, MIT)

Upstream is the `upstream` git remote.

## Unreleased
- Package renamed from io.github.domanell.arcvolume to io.github.codemastervy.arcvolume. Existing installs of the old ID must be
  uninstalled, and the permissions set again (Display over other apps, and the TCL auto-start appops commands in the README).
- The number is now only a level the soundbar reported; the per-press step learning, the step screens and the
  expected-level display are removed. With no report nothing is shown. Raw values are logged under the `ArcVolume` tag.
- Soundbar control panel (ControlActivity) with a transport table; unsupported rows say so.
- Notes: CEC limits for the HW-B750, source audit, real-check and capture plans.
- New README and own screenshots in docs/screens/; upstream screenshots removed.
- The short-lived Home Assistant webhook was dropped.
