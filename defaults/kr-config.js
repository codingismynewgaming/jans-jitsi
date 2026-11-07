// Jans Jitsi - selektive Config-Overrides
if (typeof config === 'undefined') {
    var config = {};
}

// Lokale und entfernte Anzeigenamen
config.defaultLocalDisplayName = 'ich';
config.defaultRemoteDisplayName = 'Gast';

// Sprache und Pflicht-Anzeigename
config.defaultLanguage = 'de';
config.requireDisplayName = true;

// Vorschaltseite (Prejoin)
config.prejoinConfig = config.prejoinConfig || {};
config.prejoinConfig.enabled = true;

// Audio / Video Stummschaltung ab dem 5. Teilnehmer
config.startAudioMuted = 5;
config.startVideoMuted = 5;

// Standard 360p, damit Rechenzeit und Datenvolumen klein bleiben
config.resolution = 360;
config.constraints = config.constraints || {};
config.constraints.video = Object.assign({}, config.constraints.video, {
    height: { ideal: 360, max: 720, min: 180 }
});

// Bevorzugter Codec VP8
config.preferredCodec = 'VP8';

// Peer-to-Peer aktivieren
config.p2p = config.p2p || {};
config.p2p.enabled = true;

// Wartezimmer (Lobby) nur bei Bedarf, Moderator schaltet es im Call ein
config.lobby = config.lobby || {};
config.lobby.autoKnock = true;
config.lobby.enableChat = true;

// Umfragen, Reaktionen, Breakout-Räume
config.disablePolls = false;
config.disableReactions = false;
config.breakoutRooms = config.breakoutRooms || {};
config.breakoutRooms.hideAddRoomButton = false;
config.breakoutRooms.hideAutoAssign = false;

// Keine Drittanbieter-Anfragen
config.disableThirdPartyRequests = true;

// Dynamic Branding
config.dynamicBrandingUrl = '/images/kr/branding.json?v=2';

// Eigenes Branding
config.dynamicBrandingUrl = '/images/kr/branding.json?v=3';
