import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../db/database_helper.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool _isScanning = true;

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final barcode = capture.barcodes.firstOrNull;
    final code = barcode?.rawValue;

    if (code != null && code.isNotEmpty) {
      setState(() {
        _isScanning = false;
      });

      _validateTicket(code);
    }
  }

  Future<void> _validateTicket(String code) async {
    try {
      final isOnline = await _isOnline();
      bool isValid = false;

      if (isOnline) {
        isValid = await _validateWithBackend(code);
      } else {
        isValid = await _validateWithSQLite(code);
      }

      _showDialog(
        isValid
            ? '✅ Ticket validé avec succès\n\nCode : $code'
            : '❌ Ticket invalide ou déjà utilisé\n\nCode : $code',
      );
    } catch (e) {
      _showDialog("Erreur lors de la validation : $e");
    } finally {
      setState(() {
        _isScanning = true;
      });
    }
  }

  Future<bool> _validateWithBackend(String code) async {
    final url = Uri.parse('http://192.168.1.18:8080/api/tickets/valider?code=$code');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['valid'] == true;
    }
    return false;
  }

  Future<bool> _validateWithSQLite(String code) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('tickets', where: 'code = ?', whereArgs: [code]);

    if (result.isNotEmpty && result.first['statut'] != 'utilise') {
      await db.update(
        'tickets',
        {'statut': 'utilise'},
        where: 'code = ?',
        whereArgs: [code],
      );
      return true;
    }
    return false;
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Résultat du scan"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un QR Code'),
        backgroundColor: const Color.fromARGB(255, 76, 155, 175),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(),
            onDetect: _onDetect,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 40),
              padding: const EdgeInsets.all(10),
              color: Colors.black54,
              child: const Text(
                "Placez le QR Code au centre de l'écran",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
