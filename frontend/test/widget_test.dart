import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('renders backend status page', (tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Backend status'), findsOneWidget);
  });
}
