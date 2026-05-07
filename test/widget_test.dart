import 'package:flutter_test/flutter_test.dart';

import 'package:mad/main.dart';

void main() {
  testWidgets('shows Firebase setup error when initialization fails', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp(firebaseError: 'test error'));

    expect(find.text('Firebase is not configured yet'), findsOneWidget);
    expect(find.textContaining('test error'), findsOneWidget);
  });
}
