import 'package:ahorrify/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Carga la app completa
    await tester.pumpWidget(const AhorrifyApp());

    // Verifica que hay un "0" en pantalla (esto depende de que haya un contador visible)
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Toca el botón con ícono de suma (esto también depende de tu UI actual)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verifica que el número cambió de 0 a 1
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
