import 'package:flutter_test/flutter_test.dart';
import 'package:kas/app.dart';

void main() {
  testWidgets('FinoteApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FinoteApp());

    // Karena belum login, harus muncul tulisan sapaan guest
    expect(find.textContaining('Halo'), findsWidgets);
    expect(find.text('FINOTE'), findsWidgets);
  });
}