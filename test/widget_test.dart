// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:global_calc/main.dart';

void main() {
  testWidgets('Renders GlobalCalc tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const GlobalCalcApp());
    await tester.pumpAndSettle();

    expect(find.text('GlobalCalc'), findsOneWidget);
    expect(find.text('Tips'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Discount'), findsOneWidget);
    expect(find.text('Percentages'), findsOneWidget);
  });
}
