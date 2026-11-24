import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/api.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';
import '../core/widgets/mobile_widgets.dart';

/// Agent de station : scanne le QR code d'un ticket, vérifie puis valide le plein.
class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key, required this.token, required this.userId});
  final String token;
  final String userId;

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  bool _handling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling || capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;
    _handling = true;
    await _controller.stop();

    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) data = Map<String, dynamic>.from(decoded);
    } catch (_) {}

    if (!mounted) return;
    if (data == null) {
      await _showResult(success: false, message: 'Ce QR code n\'est pas un ticket FasoCarbu.');
    } else {
      final validated = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _ConfirmSheet(raw: raw, data: data!),
      );
      if (validated == true && mounted) {
        await _showResult(success: true, message: '${data['quantite'] ?? ''} L de ${data['carburant'] ?? 'carburant'} validés.');
      }
    }
    _handling = false;
    if (mounted) await _controller.start();
  }

  Future<void> _showResult({required bool success, required String message}) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          success ? Icons.check_circle_rounded : Icons.error_rounded,
          size: 48,
          color: success ? AppColors.success : AppColors.danger,
        ),
        title: Text(success ? 'Ticket validé' : 'Ticket refusé'),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Scanner un autre ticket')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scanner un ticket'),
        actions: [
          IconButton(
            tooltip: 'Lampe',
            color: Colors.white,
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Caméra indisponible. Autorisez l\'accès à la caméra dans les réglages du téléphone.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Cadre de visée
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.brandOnDark, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Text(
              'Placez le QR code du ticket dans le cadre',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmSheet extends StatefulWidget {
  const _ConfirmSheet({required this.raw, required this.data});
  final String raw;
  final Map<String, dynamic> data;

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  bool _loading = false;
  String? _error;

  Future<void> _valider() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Api.post('/tickets/valider', {
        'codeQr': widget.raw,
        'montant': '${widget.data['montant'] ?? 0}',
      });
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final d = widget.data;
    final montant = double.tryParse('${d['montant'] ?? 0}') ?? 0;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Vérifiez le ticket', style: t.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            Center(child: Text('${d['quantite'] ?? '—'} L', style: t.displaySmall)),
            Center(child: Text('${d['carburant'] ?? ''} · ${formatNumber(montant)} FCFA', style: t.bodyLarge)),
            const SizedBox(height: AppSpacing.lg),
            KeyValueRow(icon: Icons.directions_car_outlined, label: 'Véhicule', value: '${d['vehicule'] ?? ''}'),
            KeyValueRow(icon: Icons.place_outlined, label: 'Station', value: '${d['station'] ?? ''}'),
            KeyValueRow(
              icon: Icons.event_outlined,
              label: 'Émis le',
              value: formatDate(DateTime.tryParse('${d['dateEmission'] ?? ''}'), withTime: true),
            ),
            if (_error != null) ...[const SizedBox(height: AppSpacing.md), InlineAlert(message: _error!)],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: 'Valider le plein', icon: Icons.check_rounded, onPressed: _valider, loading: _loading, expand: true),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ],
        ),
      ),
    );
  }
}
