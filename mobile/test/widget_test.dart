import 'package:flutter_test/flutter_test.dart';
import 'package:resident_portal_mobile/main.dart';

void main() {
  testWidgets('shows bottom navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const ResidentPortalApp());

    expect(find.text('Portal'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
  });
}
