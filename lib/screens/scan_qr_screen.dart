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
  Map<String, dynamic>? ticketData;
  bool _isLoading = false;

  Future<void> _validerTicket(String code) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final payload = {"codeQr": code, "montant": ticketData?['montant']};

      debugPrint("📤 Envoi au backend:");
      debugPrint(
        "URL: https://faso-carbu-backend-2.onrender.com/api/tickets/valider",
      );
      debugPrint("Headers: {Authorization: Bearer ${widget.token}}");
      debugPrint("Payload: $payload");

      final response = await http.post(
        Uri.parse(
          "https://faso-carbu-backend-2.onrender.com/api/tickets/valider",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: jsonEncode(payload),
      );

      debugPrint(
        "📥 Réponse backend (${response.statusCode}): ${response.body}",
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Ticket validé avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
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
      debugPrint("⚠️ Exception lors de l'appel backend: $e");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Erreur de connexion : $e"),
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    final String? code = capture.barcodes.first.rawValue;

    debugPrint("📷 QR détecté brut: $code");

    if (code != null && mounted && !_isLoading && code != qrCode) {
      try {
        final decoded = jsonDecode(code);
        debugPrint("📦 QR décodé JSON: $decoded");

        setState(() {
          qrCode = code;
          ticketData = decoded;
        });

        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Confirmer validation"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Montant : ${decoded['montant']}"),
                Text("Quantité : ${decoded['quantite']}"),
                Text("Carburant : ${decoded['carburant']}"),
                Text("Véhicule : ${decoded['vehicule']}"),
                Text("Station : ${decoded['station']}"),
                Text("Date émission : ${decoded['dateEmission']}"),
              ],
            ),
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
      } catch (e) {
        debugPrint("❌ Erreur lors du décodage QR: $e");

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ QR invalide : $e"),
            backgroundColor: Colors.red,
          ),
        );
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
          if (ticketData != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  top: BorderSide(color: Colors.red.shade200, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📌 Infos du ticket scanné :",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text("Montant : ${ticketData!['montant']}"),
                  Text("Quantité : ${ticketData!['quantite']}"),
                  Text("Carburant : ${ticketData!['carburant']}"),
                  Text("Véhicule : ${ticketData!['vehicule']}"),
                  Text("Station : ${ticketData!['station']}"),
                  Text("Date : ${ticketData!['dateEmission']}"),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
