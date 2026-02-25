class AppConfig {
  static const portalUrl = String.fromEnvironment(
    'RENTVINE_PORTAL_URL',
    defaultValue: 'https://example.rentvine.com/resident',
  );

  static const backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const supportPhone = String.fromEnvironment(
    'SUPPORT_PHONE',
    defaultValue: '850-244-2100',
  );

  static const supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'rentals@coastalrealtyservices.com',
  );

  static const supportSms = String.fromEnvironment(
    'SUPPORT_SMS',
    defaultValue: '',
  );

  static const feedbackEmail = String.fromEnvironment(
    'FEEDBACK_EMAIL',
    defaultValue: 'rentals@coastalrealtyservices.com',
  );

  static const iosAppStoreId = String.fromEnvironment(
    'IOS_APP_STORE_ID',
    defaultValue: '',
  );

  static const disableBiometricLock = bool.fromEnvironment(
    'DISABLE_BIOMETRIC_LOCK',
    defaultValue: false,
  );

  static const reviewPromptEnabled = bool.fromEnvironment(
    'REVIEW_PROMPT_ENABLED',
    defaultValue: true,
  );

  static const reviewPromptMinAppOpens = int.fromEnvironment(
    'REVIEW_PROMPT_MIN_APP_OPENS',
    defaultValue: 7,
  );

  static const reviewPromptCooldownDays = int.fromEnvironment(
    'REVIEW_PROMPT_COOLDOWN_DAYS',
    defaultValue: 21,
  );

  /// The portal type currently selected by the user ('resident' or 'owner').
  /// Set at startup from StorageService before the UI renders.
  static String portalType = 'resident';

  /// Base URL without the portal-type path segment.
  /// e.g. 'https://coastalrealtyservices.rentvine.com/portals'
  static String get _portalBaseUrl {
    final uri = Uri.parse(portalUrl);
    final segments = List<String>.from(uri.pathSegments);
    // Drop the last segment (e.g. 'resident') so we can substitute it.
    if (segments.isNotEmpty) segments.removeLast();
    return uri.replace(pathSegments: segments).toString();
  }

  static Uri get portalUri =>
      Uri.parse('$_portalBaseUrl/$portalType');

  static String get portalDomain => Uri.parse(portalUrl).host;
}
