#!/usr/bin/with-contenv bash

# Videobrücke JVB sofort beim Start von meet per UDP wecken (Port 10000)
# Mehrere Methoden (Python, Bash /dev/udp, nc) für maximale Portabilität
JVB_HOST="${XMPP_SERVER:-jvb}"

# 1. Python UDP-Ping
python3 -c "
import socket, os
host = os.getenv('XMPP_SERVER', 'jvb')
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(1.0)
    s.sendto(b'wakeup', (host, 10000))
    s.close()
except Exception:
    pass
" >/dev/null 2>&1 || true

# 2. Bash /dev/udp Ping als Fallback
(echo -n "wakeup" > "/dev/udp/$JVB_HOST/10000") >/dev/null 2>&1 || true

# 3. nc Fallback
nc -u -w 1 "$JVB_HOST" 10000 <<< "wakeup" >/dev/null 2>&1 || true

# 4. Patch vorhandener idlewatch-Skripte im Image, falls vorhanden
# Suche nach idlewatch Skripten im System und sorge für sofortiges Wecken vor der 60s-Warteschleife
find /usr /etc -name "*idlewatch*" -type f 2>/dev/null | while read -r f; do
    if [ -f "$f" ]; then
        # Falls es ein Bash- oder Python-Skript ist mit sleep 60 am Anfang, patchen
        sed -i 's/sleep 60/sleep 1/g' "$f" 2>/dev/null || true
    fi
done
