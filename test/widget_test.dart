import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:faso_carbu_mobile/core/widgets/app_widgets.dart';

void main() {
  test('statusInfo traduit les statuts backend', () {
    expect(statusInfo('EN_ATTENTE').label, 'En attente');
    expect(statusInfo('VALIDEE').tone, Tone.success);
    expect(statusInfo('REJETER').tone, Tone.danger);
    expect(statusInfo(null).label, '—');
  });

  test('formatNumber sépare les milliers', () {
    expect(formatNumber(1250000), '1 250 000');
    expect(formatNumber(12.5, decimals: 1), '12,5');
  });

  testWidgets('StatusBadge affiche le libellé du statut', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: StatusBadge.fromStatus('VALIDEE'))));
    expect(find.text('Validé'), findsOneWidget);
  });
}
