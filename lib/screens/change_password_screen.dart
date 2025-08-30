import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class ChangePasswordScreen extends StatefulWidget {
  final String token;

  const ChangePasswordScreen({super.key, required this.token});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ancienController = TextEditingController();
  final _nouveauController = TextEditingController();
  bool _loading = false;
  String? _message;

  Future<void> _changerMotDePasse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    try {
      final response = await http.put(
        Uri.parse(
          "https://faso-carbu-backend-2.onrender.com/api/auth/changer-mot-de-passe",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'email': email,
          'ancienMotDePasse': _ancienController.text,
          'nouveauMotDePasse': _nouveauController.text,
        }),
      );
      logger.i(response.statusCode);
      logger.i(response.body);

      if (response.statusCode == 200) {
        setState(() => _message = "✅ Mot de passe modifié avec succès");
        _ancienController.clear();
        _nouveauController.clear();
      } else {
        setState(
          () => _message =
              "❌ Échec : ${jsonDecode(response.body)['message'] ?? 'Erreur inconnue'}",
        );
      }
    } catch (e) {
      setState(() => _message = "❌ Erreur réseau");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Changer le mot de passe")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _ancienController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Ancien mot de passe",
                ),
                validator: (value) => (value == null || value.length < 4)
                    ? 'Entrer un mot de passe valide'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nouveauController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Nouveau mot de passe",
                ),
                validator: (value) => (value == null || value.length < 4)
                    ? 'Mot de passe trop court'
                    : null,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _changerMotDePasse,
                      child: const Text("Confirmer le changement"),
                    ),
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains("✅") ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
