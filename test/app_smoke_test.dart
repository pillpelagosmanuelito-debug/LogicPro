import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logicpro/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('LogicPro arranca y muestra la pestana Inicio con los modulos',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: LogicProApp()));
    await tester.pumpAndSettle();

    expect(find.text('LogicPro'), findsOneWidget);
    expect(find.text('Álgebra booleana'), findsWidgets);
  });

  testWidgets('la TabBar superior permite navegar a Compuertas lógicas',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: LogicProApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('M2'));
    await tester.pumpAndSettle();

    expect(find.text('Elige una compuerta'), findsOneWidget);
  });
}
