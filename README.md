# Jans Jitsi Meet Web Image

Eigenes Docker-Image für den Jitsi Web Dienst `meet` ("Jans Jitsi"), optimiert für InstaCloud ohne persistente Volumes.

---

## 1. Build & Push (z.B. GitHub Container Registry)

### Voraussetzungen
- Docker installiert
- Authentifizierung bei GHCR:
  ```bash
  echo $CR_PAT | docker login ghcr.io -u <github-username> --password-stdin
  ```

### Build
Das Image baut direkt auf dem aktuell in InstaCloud laufenden Image auf:

```bash
# Aktuelles Image ermitteln (im InstaCloud Dashboard unter Dienst 'meet' -> Image)
# Beispiel: docker build --build-arg BASE_IMAGE=<aktuelles-meet-image> -t ghcr.io/<github-username>/jans-jitsi:latest .
docker build --build-arg BASE_IMAGE=jitsi-meet-web:latest -t ghcr.io/<github-username>/jans-jitsi:latest .
```

### Push
```bash
docker push ghcr.io/<github-username>/jans-jitsi:latest
```

> **Tipp (öffentlich vs. privat)**:
> In GitHub unter `Packages` -> `jans-jitsi` -> `Package settings` die Sichtbarkeit auf **Public** stellen, damit InstaCloud das Image ohne Registry-Credentials ziehen kann. Falls es privat bleiben soll, die Image-Pull-Credentials (Registry: `ghcr.io`, User: `<github-username>`, Token: `read:packages` Personal Access Token) im InstaCloud Dashboard eintragen.

---

## 2. In InstaCloud hinterlegen

1. InstaCloud Dashboard öffnen -> Projekt auswählen.
2. Dienst **`meet`** auswählen -> **Configuration / Settings**.
3. **Image** ändern auf:
   ```text
   ghcr.io/<github-username>/jans-jitsi:latest
   ```
4. Speichern und Dienst neu starten.

---

## 3. Benötigte Environment Secrets

| Variable | Beschreibung | Pflicht? |
| :--- | :--- | :--- |
| `JITSI_VEREIN_PASSWORD` | Passwort für den zusätzlichen Account `llsc@meet.jitsi`. Wird beim Containerstart idempotent via `prosodyctl` registriert und nie in Logs ausgegeben. | Ja (wenn Vereinslogin genutzt wird) |
| `JITSI_ADMIN_USER` | Admin-Benutzername (wie bisher) | Ja |
| `JITSI_ADMIN_PASSWORD` | Admin-Passwort (wie bisher) | Ja |
| `INSTA_IDLE_TOKEN` / `INSTA_PROJECT_ID` / `JVB_SERVICE_ID` / `MEET_SERVICE_ID` | InstaCloud Schlaf- & Aufwachsteuerung (wie bisher) | Ja |

---

## 4. Prüfliste nach Deployment (Deploy & Kaltstart)

Nach dem Bereitstellen und nach einem vollständigen Schlaf-/Aufwach-Zyklus prüfen:

- [ ] **Branding & Startseite**: Startseite zeigt "Jans Jitsi", das neue Logo, den Untertitel "Calls mit Jan" und kein "Kühne Runde" mehr (`curl -s https://jitsi.berlin-mitte-institut.de | grep -i kühn` liefert keine Treffer).
- [ ] **Accounts & BOSH**: Login mit `jan` und `llsc` per BOSH funktioniert direkt nach dem Aufwachen. Der alte Account `verein` existiert nicht mehr.
- [ ] **JVB Kaltstart**: Call mit 3 Teilnehmern verbindet sich innerhalb von ca. 15 Sekunden (Videobrücke `jvb` wird direkt beim Start von `meet` per UDP Port 10000 geweckt).
- [ ] **Idle-Modus**: Nach 10 Minuten ohne aktive Konferenz schlafen beide Dienste (`meet` und `jvb`) wieder automatisch (Schlafmodus aktiv, Guthaben wird geschont).
