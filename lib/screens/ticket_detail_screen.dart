import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/mobile_widgets.dart';

/// Détail d'un ticket, présenté comme un vrai ticket avec son QR code.
class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key, required this.ticket});
  final Map<String, dynamic> ticket;

  @override
  Widget build(BuildContext context) {
    final data = TicketData.fromMap(ticket);
    return Scaffold(
      appBar: AppBar(title: Text('Ticket N° ${data.numero}')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TicketCard(data: data),
            ),
          ),
        ),
      ),
    );
  }
}
