import 'package:flutter_test/flutter_test.dart';
import 'package:keeji/app.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    await tester.pumpWidget(const KeejiApp());
    expect(find.text('课记'), findsOneWidget);
  });
}
