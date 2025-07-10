import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un QR Code'),
        backgroundColor: const Color.fromARGB(255, 76, 153, 175),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          if (_scanned) return;

          final String? code = capture.barcodes.first.rawValue;

          if (code != null) {
            setState(() {
              _scanned = true;
            });

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('QR Code détecté'),
                content: Text('Contenu : $code'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() => _scanned = false); // pour scanner à nouveau
                    },
                    child: const Text('Scanner à nouveau'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
