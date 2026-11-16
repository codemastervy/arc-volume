#!/usr/bin/env bash
# Fails if tracked/staged files contain private addresses, tokens, webhook ids or emails.
cd "$(dirname "$0")/.."
files=$(git ls-files -co --exclude-standard)
bad=0
pat='([0-9]{1,3}\.){3}[0-9]{1,3}|eyJ[A-Za-z0-9_-]{20,}|api/webhook/[A-Za-z0-9_-]{16,}|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}|password|secret'
for f in $files; do
  [ -f "$f" ] || continue; case "$f" in *.png|scripts/privacy-scan.sh) continue;; esac
  # allowed: emulator host alias and loopback
  hits=$(grep -nEI "$pat" "$f" | grep -vE '192\.168\.0\.14|10\.0\.2\.2|127\.0\.0\.1|0\.0\.0\.0|noreply\.github\.com' || true)
  [ -n "$hits" ] && { echo "== $f"; echo "$hits"; bad=1; }
done
[ $bad = 0 ] && echo "privacy scan clean" || { echo "privacy scan FAILED"; exit 1; }
