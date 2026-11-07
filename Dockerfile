# Jan's Jitsi: kombinierter Dienst "meet" (Weboberfläche, Prosody, Jicofo)
# Die Videobrücke (jvb) läuft als eigener Dienst aus dem offiziellen Image.
ARG JITSI_TAG=stable-11248-3
FROM ghcr.io/jitsi/prosody:${JITSI_TAG} AS prosody
FROM ghcr.io/jitsi/jicofo:${JITSI_TAG} AS jicofo
FROM ghcr.io/jitsi/web:${JITSI_TAG}

USER root

# Prosody aus dem gleichen Paketkanal wie das offizielle Image
COPY --from=prosody /etc/apt/sources.list.d/prosody.sources /etc/apt/sources.list.d/prosody.sources
COPY --from=prosody /usr/share/keyrings/prosody.gpg /usr/share/keyrings/prosody.gpg
RUN apt-dpkg-wrap apt-get update && \
    apt-dpkg-wrap apt-get install -y \
      lua5.4 "prosody=13.*" lua-inspect lua-luaossl lua-sec lua-unbound \
      openjdk-21-jre-headless netcat-openbsd && \
    apt-cleanup && \
    rm -rf /etc/prosody && \
    (mv /usr/share/lua/5.3/inspect.lua /usr/share/lua/5.4/ 2>/dev/null || true) && \
    (apt-cache policy prosody | grep Installed | grep -Eq " 13\." && sed -i '/idna_to_ascii/d' /usr/share/lua/5.4/prosody/util/jid.lua || true) && \
    usermod -a -G prosody s6 && \
    mkdir -p /var/lib/prosody && chown s6:s6 /var/lib/prosody

# Plugins, Lua Module, Vorlagen und Jicofo aus den offiziellen Images
COPY --from=prosody /prosody-plugins /prosody-plugins
COPY --from=prosody /prosody-plugins-contrib /prosody-plugins-contrib
COPY --from=prosody /usr/local/lib/lua/5.4 /usr/local/lib/lua/5.4
COPY --from=prosody /usr/local/share/lua/5.4 /usr/local/share/lua/5.4
COPY --from=prosody /defaults/ /defaults/
COPY --from=jicofo /usr/share/jicofo /usr/share/jicofo
COPY --from=jicofo /defaults/ /defaults/

# s6 Dienste der beiden Images unter eigenen Namen übernehmen
COPY --from=prosody /etc/s6-overlay /tmp/s6-prosody
COPY --from=jicofo /etc/s6-overlay /tmp/s6-jicofo
COPY s6/ /tmp/s6-eigen/
COPY scripts/merge-s6.sh /tmp/merge-s6.sh
RUN bash /tmp/merge-s6.sh && rm -rf /tmp/s6-prosody /tmp/s6-jicofo /tmp/s6-eigen /tmp/merge-s6.sh

# Branding
COPY --chown=s6:s6 defaults/kr-config.js /config/custom-config.js
COPY --chown=s6:s6 defaults/kr-interface_config.js /config/custom-interface_config.js
COPY rootfs/ /

USER s6
