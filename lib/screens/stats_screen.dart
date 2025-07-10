import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  final String token;

  const StatsScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: Center(
        child: Text('Statistiques disponibles via le token : $token'),
      ),
    );
  }
}
