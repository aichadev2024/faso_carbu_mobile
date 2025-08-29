import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  String? qrCode;

  void _onDetect(BarcodeCapture capture) {
    final String? code = capture.barcodes.first.rawValue;
    if (code != null && mounted) {
      setState(() {
        qrCode = code;
      });

      // 🚀 Tu peux ici appeler ton API backend pour valider le ticket scanné
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("QR détecté : $code")));
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
          Expanded(child: MobileScanner(onDetect: _onDetect)),
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
