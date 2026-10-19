import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:madproject/main.dart';

void main() {
  testWidgets('QuranApp builds successfully and displays FrontScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuranApp());
    await tester.pumpAndSettle();

    // Verify MaterialApp title and theme setup
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(FrontScreen), findsOneWidget);
  });
}

