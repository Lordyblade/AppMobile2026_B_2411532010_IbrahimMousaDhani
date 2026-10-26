import 'package:flutter_test/flutter_test.dart';
import 'package:projectpraktikum5/main.dart';

void main() {
  testWidgets('UangKu menampilkan halaman Login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());

    expect(find.text('UangKu'), findsOneWidget);
    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('Masuk ke akun Anda'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}