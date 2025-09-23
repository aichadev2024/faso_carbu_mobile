import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:faso_carbu_mobile/main.dart';

void main() {
  testWidgets('FasoCarbuApp loads with startScreen', (
    WidgetTester tester,
  ) async {
    // Crée un startScreen factice pour le test
    final startScreen = Scaffold(body: Center(child: Text('Start Screen')));

    // Build notre app et déclenche un frame
    await tester.pumpWidget(FasoCarbuApp(startScreen: startScreen));

    // Vérifie que le startScreen s'affiche
    expect(find.text('Start Screen'), findsOneWidget);
  });
}
