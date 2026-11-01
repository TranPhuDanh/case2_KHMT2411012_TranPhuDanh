import 'package:flutter_test/flutter_test.dart';
import 'package:case_study2/main.dart';

void main() {
  testWidgets('TaskManagerApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp(initialRoute: '/login'));
    expect(find.byType(TaskManagerApp), findsOneWidget);
  });
}
