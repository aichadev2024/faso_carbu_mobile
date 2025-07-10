import 'package:flutter/material.dart';

class TicketListScreen extends StatelessWidget {
  final String token;
  final String userEmail;
  final String userRole;

  const TicketListScreen({
    Key? key,
    required this.token,
    required this.userEmail,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Tickets')),
      body: Center(
        child: Text('Liste des tickets\nUser: $userEmail\nRôle: $userRole'),
      ),
    );
  }
}
