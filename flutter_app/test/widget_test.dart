import 'package:flutter_test/flutter_test.dart';
import 'package:ipeoplehelper/main.dart';

void main() {
  testWidgets('App renders title and sound grid', (WidgetTester tester) async {
    await tester.pumpWidget(const IPeopleHelperApp());
    expect(find.text('我要验牌'), findsOneWidget);
    expect(find.text('小瘪三'), findsOneWidget);
  });
}
