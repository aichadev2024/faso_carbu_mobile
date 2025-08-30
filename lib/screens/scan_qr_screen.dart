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
          const SnackBar(
            content: Text("✅ Ticket validé avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Erreur (${response.statusCode}) : ${response.body}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Erreur de connexion : $e"),
          backgroundColor: Colors.orange,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onDetect(BarcodeCapture capture) async {
    final String? code = capture.barcodes.first.rawValue;

    if (code != null && mounted && !_isLoading && code != qrCode) {
      setState(() {
        qrCode = code;
      });

      // 🔹 Demander confirmation avant validation
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Confirmer validation"),
          content: Text("Voulez-vous valider ce ticket ?\n\nQR : $code"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Valider"),
            ),
          ],
        ),
      );

      if (confirm == true) {
        _validerTicket(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner un QR Ticket"),
        backgroundColor: Colors.red.shade700,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.qr_code_scanner, color: Colors.white),
          ),
        ],
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
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  top: BorderSide(color: Colors.red.shade200, width: 1),
                ),
              ),
              child: Text(
                "📌 Dernier QR détecté :\n$qrCode",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
