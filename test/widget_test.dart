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
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('课记'), findsWidgets);
  });
}
