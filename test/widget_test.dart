import 'package:flutter_test/flutter_test.dart';
import 'package:dirxplore_pro/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TorrentApp());
    expect(find.text('DirXplore Pro'), findsOneWidget);
  });
}
