import 'package:flutter_test/flutter_test.dart';
import 'package:rebite_mobile/main.dart';
import 'package:rebite_mobile/pages/splash_screen.dart';
import 'package:rebite_mobile/pages/welcome_screen.dart';

void main() {
  testWidgets('Splash screen navigates to Welcome', (tester) async {
    await tester.pumpWidget(const ReBiteApp());
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.tapAt(tester.getCenter(find.byType(SplashScreen)));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
