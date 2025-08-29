import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanQrScreen extends StatefulWidget {
  final String token;
  final String userId;

  const ScanQrScreen({super.key, required this.token, required this.userId});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  String? qrCode;
  bool _isLoading = false;

  Future<void> _validerTicket(String code) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "https://faso-carbu-backend-2.onrender.com/api/tickets/valider",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: jsonEncode({"qrCode": code, "agentId": widget.userId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Ticket validé avec succès !")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Erreur: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠️ Erreur de connexion: $e")));
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    final String? code = capture.barcodes.first.rawValue;
    if (code != null && mounted && !_isLoading) {
      setState(() {
        qrCode = code;
      });

      _validerTicket(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner un QR Ticket"),
        backgroundColor: Colors.red.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MobileScanner(onDetect: _onDetect),
                if (_isLoading)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          if (qrCode != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Text(
                "Dernier QR détecté : $qrCode",
                style: const TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
