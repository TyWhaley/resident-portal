import '../config.dart';

class DeepLinkService {
  static String portalPathForDeepLink(String deepLink) {
    final type = AppConfig.portalType;
    switch (deepLink) {
      case 'app://pay':
        return '/$type/payments';
      case 'app://maintenance/new':
        return '/$type/maintenance/new';
      case 'app://messages':
        return '/$type/messages';
      default:
        return '/$type';
    }
  }

  static Uri portalUriForDeepLink(String deepLink) {
    final path = portalPathForDeepLink(deepLink);
    return AppConfig.portalUri.replace(path: path);
  }
}
