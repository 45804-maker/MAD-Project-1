import 'package:flutter_test/flutter_test.dart';
import 'package:madproject/main.dart';

void main() {
  testWidgets('App renders correctly test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Flutter Animations App'), findsOneWidget);
  });
}
