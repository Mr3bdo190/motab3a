import 'package:flutter_test/flutter_test.dart';
import 'package:motab3a/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // بناء التطبيق
    await tester.pumpWidget(const Motab3aApp());

    // التأكد من ظهور النص
    expect(find.text('تم بناء التطبيق بنجاح!'), findsOneWidget);
  });
}
