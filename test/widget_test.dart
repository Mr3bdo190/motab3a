import 'package:flutter_test/flutter_test.dart';
import 'package:motab3a/main.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // إعداد Firebase وهمي للاختبار
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    
    await tester.pumpWidget(const Motab3aApp());
    expect(find.text('Firebase اتصل بنجاح!'), findsOneWidget);
  });
}
