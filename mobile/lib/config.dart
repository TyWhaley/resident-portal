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

  static Uri get portalUri => Uri.parse(portalUrl);
  static String get portalDomain => portalUri.host;
}
