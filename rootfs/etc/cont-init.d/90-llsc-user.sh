#!/usr/bin/with-contenv bash
set -e

# Verhindere, dass ein alter Nutzer 'verein' noch irgendwo angelegt wird
if [ -d "/etc/cont-init.d" ]; then
    grep -l "verein" /etc/cont-init.d/* 2>/dev/null | grep -v "90-llsc-user.sh" | while read -r f; do
        sed -i 's/\bverein\b/disabled_verein/g' "$f" 2>/dev/null || true
    done
fi

# Idempotentes Skript zum Anlegen des llsc Vereinsaccounts in Prosody / Jitsi Meet
if [ -n "$JITSI_VEREIN_PASSWORD" ]; then
    XMPP_DOMAIN="${XMPP_DOMAIN:-meet.jitsi}"

    # Prosody Konfigurationsdatei flexibel lokalisieren
    PROSODY_OPT=""
    if [ -f "/config/prosody/prosody.cfg.lua" ]; then
        PROSODY_OPT="--config /config/prosody/prosody.cfg.lua"
    elif [ -f "/config/prosody.cfg.lua" ]; then
        PROSODY_OPT="--config /config/prosody.cfg.lua"
    elif [ -f "/etc/prosody/prosody.cfg.lua" ]; then
        PROSODY_OPT="--config /etc/prosody/prosody.cfg.lua"
    fi

    # Registrierung idempotent ohne Logging von Passwörtern
    if ! prosodyctl $PROSODY_OPT registered llsc "$XMPP_DOMAIN" >/dev/null 2>&1; then
        prosodyctl $PROSODY_OPT register llsc "$XMPP_DOMAIN" "$JITSI_VEREIN_PASSWORD" >/dev/null 2>&1 || true
    else
        prosodyctl $PROSODY_OPT passwd llsc "$XMPP_DOMAIN" "$JITSI_VEREIN_PASSWORD" >/dev/null 2>&1 || true
    fi
fi
