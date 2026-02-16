import 'package:flutter_test/flutter_test.dart';
import 'package:resident_portal_mobile/services/deep_link_service.dart';

void main() {
  test('maps app://pay to payments path', () {
    expect(DeepLinkService.portalPathForDeepLink('app://pay'), '/resident/payments');
  });

  test('maps unknown link to resident home', () {
    expect(DeepLinkService.portalPathForDeepLink('app://unknown'), '/resident');
  });
}
