#!/usr/bin/env bash
# Host unit tests (no device). Needs ANDROID_HOME and a JDK.
set -euo pipefail
cd "$(dirname "$0")/.."
out=build/unit; rm -rf "$out"; mkdir -p "$out"
jar="$ANDROID_HOME/platforms/android-34/android.jar"
javac --release 8 -Xlint:-options -cp "$jar" -d "$out" \
  src/io/github/domanell/arcvolume/VolumePredictor.java \
  src/io/github/domanell/arcvolume/HaWebhook.java tests/UnitTest.java
java -cp "$out:$jar" io.github.domanell.arcvolume.UnitTest
