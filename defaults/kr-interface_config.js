// Jans Jitsi - selektive Interface-Config-Overrides
if (typeof interfaceConfig === 'undefined') {
    var interfaceConfig = {};
}

interfaceConfig.APP_NAME = 'Jans Jitsi';
interfaceConfig.NATIVE_APP_NAME = 'Jans Jitsi';
interfaceConfig.PROVIDER_NAME = 'Jan Kühn';

interfaceConfig.DEFAULT_LOCAL_DISPLAY_NAME = 'ich';
interfaceConfig.DEFAULT_REMOTE_DISPLAY_NAME = 'Gast';

// Mobile App Promotion Kasten ausblenden
interfaceConfig.MOBILE_APP_PROMO = false;
interfaceConfig.SHOW_CHROME_EXTENSION_BANNER = false;

// Wasserzeichen
interfaceConfig.SHOW_JITSI_WATERMARK_FOR_GUESTS = true;
interfaceConfig.SHOW_WATERMARK_FOR_GUESTS = true;
interfaceConfig.JITSI_WATERMARK_LINK = 'https://jitsi.berlin-mitte-institut.de';
interfaceConfig.BRAND_WATERMARK_LINK = 'https://jitsi.berlin-mitte-institut.de';
