import '../config.dart';

class DeepLinkService {
  static String portalPathForDeepLink(String deepLink) {
    switch (deepLink) {
      case 'app://pay':
        return '/resident/payments';
      case 'app://maintenance/new':
        return '/resident/maintenance/new';
      case 'app://messages':
        return '/resident/messages';
      default:
        return '/resident';
    }
  }

  static Uri portalUriForDeepLink(String deepLink) {
    final path = portalPathForDeepLink(deepLink);
    return AppConfig.portalUri.replace(path: path);
  }
}
