import 'package:flutter_test/flutter_test.dart';
import 'package:alex_transportation/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TransitApp());
    expect(find.byType(TransitApp), findsOneWidget);
  });
}
