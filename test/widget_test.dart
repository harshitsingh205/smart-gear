import 'package:flutter_test/flutter_test.dart';
import 'package:smart_gear/app/app.dart';

void main() {
  testWidgets('SmartGear app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartGearApp());
    await tester.pump();

    // Verify SmartGear logo/title is shown on splash
    expect(find.text('SmartGear'), findsOneWidget);
  });
}
