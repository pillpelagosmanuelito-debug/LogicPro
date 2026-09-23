// Existe para que `flutter create .` (usado en CI) no genere su plantilla
// por defecto, que referencia una clase `MyApp` inexistente.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logicpro/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('LogicProApp se construye sin errores', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: LogicProApp()));
    await tester.pumpAndSettle();

    expect(find.text('LogicPro'), findsOneWidget);
  });
}
