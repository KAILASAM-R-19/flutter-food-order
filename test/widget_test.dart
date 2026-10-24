import 'package:flutter_test/flutter_test.dart';
import 'package:firstdemo/main.dart';

void main() {
  testWidgets('Food ordering app basic smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title and a menu item are present.
    expect(find.text('Food Menu'), findsOneWidget);
    expect(find.text('Burger'), findsOneWidget);

    // Verify Add button is present and tap it.
    final addButton = find.text('Add').first;
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pump();

    // Verify cart label updates to Cart (1).
    expect(find.text('Cart (1)'), findsOneWidget);
  });
}
