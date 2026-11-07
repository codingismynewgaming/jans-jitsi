#!/bin/bash
# Fügt die s6 Dienste von prosody und jicofo in das web Image ein.
# Gleichnamige Dienste (10-config) und Skripte (config) bekommen eigene Namen.
set -euo pipefail
D=/etc/s6-overlay
for comp in prosody jicofo; do
  S=/tmp/s6-$comp
  cp "$S/scripts/config" "$D/scripts/$comp-config"
  for f in "$S"/scripts/*; do
    n=$(basename "$f")
    [ "$n" = config ] && continue
    cp "$f" "$D/scripts/$n"
  done
  mkdir -p "$D/s6-rc.d/$comp-config/dependencies.d"
  echo oneshot > "$D/s6-rc.d/$comp-config/type"
  echo "$D/scripts/$comp-config" > "$D/s6-rc.d/$comp-config/up"
  touch "$D/s6-rc.d/$comp-config/dependencies.d/base"
  touch "$D/s6-rc.d/user/contents.d/$comp-config"
  for svc in "$S"/s6-rc.d/*; do
    n=$(basename "$svc")
    case "$n" in 10-config|user|20-saslauthd) continue ;; esac
    cp -a "$svc" "$D/s6-rc.d/$n"
    if [ -e "$D/s6-rc.d/$n/dependencies.d/10-config" ]; then
      rm "$D/s6-rc.d/$n/dependencies.d/10-config"
      touch "$D/s6-rc.d/$n/dependencies.d/$comp-config"
    fi
    touch "$D/s6-rc.d/user/contents.d/$n"
  done
done
# Jicofo erst nach Prosody starten
touch "$D/s6-rc.d/jicofo/dependencies.d/prosody"
# eigene Dienste: Konten anlegen, Videobrücke wecken
cp -a /tmp/s6-eigen/. "$D/s6-rc.d/"
for n in jan-konten jvb-wecken; do touch "$D/s6-rc.d/user/contents.d/$n"; done
chmod +x "$D"/scripts/* "$D"/s6-rc.d/*/run "$D"/s6-rc.d/*/up 2>/dev/null || true
ls "$D/s6-rc.d" "$D/s6-rc.d/user/contents.d"
