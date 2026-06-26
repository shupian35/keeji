import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keeji/app.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KeejiApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(KeejiApp), findsOneWidget);
  });
}
