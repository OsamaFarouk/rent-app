import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_app/app.dart';

void main() {
  testWidgets('Rent App navigation shell smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RentApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(RentApp), findsOneWidget);
  });
}
