# Minimales Dockerfile für "Jans Jitsi"
# Baut auf dem aktuell laufenden Jitsi-Web-Image auf
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Selektive Konfigurations-Overrides
COPY defaults/kr-config.js /defaults/kr-config.js
COPY defaults/kr-interface_config.js /defaults/kr-interface_config.js

# Frontend-Dateien (Title, Styling, Wasserzeichen, Favicon, Branding)
COPY rootfs/usr/share/jitsi-meet/title.html /usr/share/jitsi-meet/title.html
COPY rootfs/usr/share/jitsi-meet/css/custom.css /usr/share/jitsi-meet/css/custom.css
COPY rootfs/usr/share/jitsi-meet/images/watermark.svg /usr/share/jitsi-meet/images/watermark.svg
COPY rootfs/usr/share/jitsi-meet/images/kr/watermark.svg /usr/share/jitsi-meet/images/kr/watermark.svg
COPY rootfs/usr/share/jitsi-meet/images/favicon.svg /usr/share/jitsi-meet/images/favicon.svg
COPY rootfs/usr/share/jitsi-meet/images/kr/branding.json /usr/share/jitsi-meet/images/kr/branding.json

# s6-overlay Init-Skripte (llsc Vereinsaccount, sofortiges JVB-Aufwecken)
COPY rootfs/etc/cont-init.d/90-llsc-user.sh /etc/cont-init.d/90-llsc-user.sh
COPY rootfs/etc/cont-init.d/95-idlewatch-patch.sh /etc/cont-init.d/95-idlewatch-patch.sh
COPY patch-translations.py /tmp/patch-translations.py

# Ausführungsrechte vergeben, Sprachdateien bereinigen und temporäre Dateien entfernen
RUN chmod +x /etc/cont-init.d/90-llsc-user.sh /etc/cont-init.d/95-idlewatch-patch.sh && \
    python3 /tmp/patch-translations.py 2>/dev/null || true && \
    rm -f /tmp/patch-translations.py
