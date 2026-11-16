#!/usr/bin/env bash
# Builds build/fakecec.apk (test helper, debug-signed). Same toolchain as ../../build.sh.
set -euo pipefail
cd "$(dirname "$0")"
bt="$ANDROID_HOME/build-tools/34.0.0"; jar="$ANDROID_HOME/platforms/android-34/android.jar"
rm -rf build; mkdir -p build/classes build/dex
"$bt/aapt2" link -o build/u.apk -I "$jar" --manifest AndroidManifest.xml --min-sdk-version 34 --target-sdk-version 34
javac --release 8 -Xlint:-options -cp "$jar" -d build/classes src/*.java
jar cf build/classes.jar -C build/classes .
"$bt/d8" --release --min-api 34 --lib "$jar" --output build/dex build/classes.jar
(cd build/dex && "$bt/aapt" add ../u.apk classes.dex >/dev/null)
"$bt/zipalign" -p -f 4 build/u.apk build/z.apk
[ -f ../../debug.keystore ] || { echo "run ../../build.sh once first" >&2; exit 1; }
"$bt/apksigner" sign --ks ../../debug.keystore --ks-pass pass:android --out build/fakecec.apk build/z.apk
echo built build/fakecec.apk
