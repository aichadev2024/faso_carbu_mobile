import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';

// Fichier identique dans faso_carbu_web et faso_carbu_mobile.

/// Données affichées sur un ticket, indépendantes du format de l'API.
class TicketData {
  const TicketData({
    this.id,
    this.statut,
    this.quantite,
    this.montant,
    this.carburant,
    this.station,
    this.vehicule,
    this.beneficiaire,
    this.entreprise,
    this.validateur,
    this.dateEmission,
    this.dateValidation,
    this.codeQr,
  });

  /// À partir de la réponse JSON brute de l'API.
  factory TicketData.fromMap(Map<String, dynamic> m) {
    String person(String prefix) => '${m['${prefix}Prenom'] ?? ''} ${m['${prefix}Nom'] ?? ''}'.trim();
    double? num_(dynamic v) => v == null ? null : double.tryParse('$v');
    DateTime? date(dynamic v) => v == null ? null : DateTime.tryParse('$v');
    return TicketData(
      id: m['id']?.toString(),
      statut: m['statut']?.toString(),
      quantite: num_(m['quantite']),
      montant: num_(m['somme'] ?? m['montant']),
      carburant: m['carburantNom']?.toString(),
      station: m['stationNom']?.toString(),
      vehicule: m['vehiculeImmatriculation']?.toString(),
      beneficiaire: person('utilisateur'),
      entreprise: m['entrepriseNom']?.toString(),
      validateur: person('validateur'),
      dateEmission: date(m['dateEmission']),
      dateValidation: date(m['dateValidation']),
      codeQr: m['codeQr']?.toString(),
    );
  }

  final String? id;
  final String? statut;
  final double? quantite;
  final double? montant;
  final String? carburant;
  final String? station;
  final String? vehicule;
  final String? beneficiaire;
  final String? entreprise;
  final String? validateur;
  final DateTime? dateEmission;
  final DateTime? dateValidation;
  final String? codeQr;

  String get numero => (id == null || id!.isEmpty) ? '——————' : id!.padLeft(6, '0');

  /// Ticket encore utilisable en station.
  bool get valable => (statut ?? '').toUpperCase() == 'EN_ATTENTE';

  bool get rejete => (statut ?? '').toUpperCase().startsWith('REJET');
}

/// État du ticket tel qu'on l'affiche sur le ticket lui-même.
({String label, Tone tone, String? tampon}) _etat(TicketData d) {
  final s = (d.statut ?? '').toUpperCase();
  if (s == 'EN_ATTENTE') return (label: 'Valable', tone: Tone.success, tampon: null);
  if (s.startsWith('REJET')) return (label: 'Rejeté', tone: Tone.danger, tampon: 'REJETÉ');
  if (s.startsWith('VALID') || s == 'CONSOMMEE') return (label: 'Utilisé', tone: Tone.neutral, tampon: 'UTILISÉ');
  final i = statusInfo(d.statut);
  return (label: i.label, tone: i.tone, tampon: null);
}

/// Ticket carburant façon « vrai ticket » : en-tête aux couleurs de la
/// marque, perforation avec encoches, talon détachable.
///
/// - [compact] : version liste (talon = lien vers le détail) ;
/// - sinon : version détail, avec le QR code dans le talon.
class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.data, this.compact = false, this.showBeneficiaire = true, this.onTap});

  final TicketData data;
  final bool compact;
  final bool showBeneficiaire;
  final VoidCallback? onTap;

  static const double _radius = 18;
  static const double _notch = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final surface = dark ? AppColors.surfaceDark : AppColors.surface;
    final outline = BorderSide(color: dark ? AppColors.borderDark : AppColors.border);
    final etat = _etat(data);

    Widget piece({required bool top, required Widget child}) => Material(
      color: surface,
      clipBehavior: Clip.antiAlias,
      shape: _TicketPieceBorder(notchTop: !top, notchBottom: top, radius: _radius, notch: _notch, side: outline),
      child: InkWell(onTap: onTap, child: child),
    );

    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: dark
            ? null
            : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 10)),
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1)),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          piece(
            top: true,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(data: data, compact: compact),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, compact ? 14 : 20, 20, compact ? 16 : 22),
                      child: compact
                          ? _CompactBody(data: data, etat: etat, showBeneficiaire: showBeneficiaire)
                          : _FullBody(data: data, etat: etat),
                    ),
                  ],
                ),
                if (etat.tampon != null)
                  Positioned(
                    right: compact ? 18 : 22,
                    bottom: compact ? 10 : 26,
                    child: _Tampon(label: etat.tampon!, tone: etat.tone == Tone.neutral ? Tone.info : etat.tone),
                  ),
              ],
            ),
          ),
          piece(
            top: false,
            child: Stack(
              children: [
                Positioned(
                  left: _notch + 6,
                  right: _notch + 6,
                  top: 0,
                  child: CustomPaint(
                    size: const Size.fromHeight(1.5),
                    painter: _DashPainter(color: (dark ? AppColors.textMutedDark : AppColors.textMuted).withValues(alpha: 0.55)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, compact ? 12 : 20, 20, compact ? 12 : 22),
                  child: compact ? _CompactStub(data: data) : _QrStub(data: data),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Semantics(label: 'Ticket carburant numéro ${data.numero}, ${formatNumber(data.quantite)} litres, ${etat.label}', child: card);
  }
}

// ---------------------------------------------------------------------------
// Parties du ticket
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.data, required this.compact});
  final TicketData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final white70 = Colors.white.withValues(alpha: 0.78);
    return Container(
      padding: EdgeInsets.fromLTRB(20, compact ? 12 : 18, 20, compact ? 12 : 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFEA580C), Color(0xFFF59E0B)]),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Pictogramme en filigrane, pour la profondeur.
          Positioned(
            right: -14,
            top: compact ? -22 : -26,
            child: Icon(Icons.local_gas_station_rounded, size: compact ? 76 : 104, color: Colors.white.withValues(alpha: 0.12)),
          ),
          Row(
            children: [
              Container(
                width: compact ? 28 : 34,
                height: compact ? 28 : 34,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(9)),
                child: Icon(Icons.local_gas_station_rounded, color: Colors.white, size: compact ? 17 : 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'FasoCarbu',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: compact ? 15 : 17, letterSpacing: -0.2),
                    ),
                    if (!compact)
                      Text(
                        'TICKET CARBURANT',
                        style: TextStyle(color: white70, fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 1.6),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'N°',
                    style: TextStyle(color: white70, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                  ),
                  Text(
                    data.numero,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Volume extends StatelessWidget {
  const _Volume({required this.data, required this.size});
  final TicketData data;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.bodyLarge?.color;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: formatNumber(data.quantite),
            style: TextStyle(fontSize: size, fontWeight: FontWeight.w800, height: 1, letterSpacing: -1, color: color),
          ),
          TextSpan(
            text: ' L',
            style: TextStyle(fontSize: size * 0.45, fontWeight: FontWeight.w700, color: AppColors.brand),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.tone, this.icon, this.dot = false});
  final String label;
  final Tone tone;
  final IconData? icon;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: tone.softBg(context), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: tone.fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[Icon(icon, size: 14, color: tone.fg), const SizedBox(width: 5)],
          Text(
            label,
            style: TextStyle(color: tone.fg, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CompactBody extends StatelessWidget {
  const _CompactBody({required this.data, required this.etat, required this.showBeneficiaire});
  final TicketData data;
  final ({String label, Tone tone, String? tampon}) etat;
  final bool showBeneficiaire;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final lieu = [
      if (showBeneficiaire && (data.beneficiaire ?? '').isNotEmpty) data.beneficiaire!,
      if ((data.station ?? '').isNotEmpty) data.station!,
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Volume(data: data, size: 32),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [Text('${formatNumber(data.montant)} FCFA', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700))],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _Chip(label: data.carburant ?? 'Carburant', tone: Tone.brand, icon: Icons.water_drop_rounded),
            if (etat.tampon == null) _Chip(label: etat.label, tone: etat.tone, dot: true),
          ],
        ),
        if (lieu.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.place_outlined, size: 15, color: t.bodySmall?.color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(lieu, style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              // Laisse la place au tampon « UTILISÉ » à droite.
              if (etat.tampon != null) const SizedBox(width: 120),
            ],
          ),
        ],
      ],
    );
  }
}

class _FullBody extends StatelessWidget {
  const _FullBody({required this.data, required this.etat});
  final TicketData data;
  final ({String label, Tone tone, String? tampon}) etat;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final infos = <(String, String, IconData)>[
      ('Station', data.station ?? '', Icons.place_outlined),
      ('Véhicule', data.vehicule ?? '', Icons.directions_car_outlined),
      ('Chauffeur', data.beneficiaire ?? '', Icons.badge_outlined),
      ('Entreprise', data.entreprise ?? '', Icons.business_outlined),
      ('Émis le', formatDate(data.dateEmission, withTime: true), Icons.event_outlined),
      if (data.dateValidation != null) ('Utilisé le', formatDate(data.dateValidation, withTime: true), Icons.task_alt_rounded),
      if ((data.validateur ?? '').isNotEmpty) ('Validé par', data.validateur!, Icons.person_pin_outlined),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('VOLUME', style: t.labelSmall?.copyWith(letterSpacing: 1.4, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Volume(data: data, size: 46),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('MONTANT', style: t.labelSmall?.copyWith(letterSpacing: 1.4, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${formatNumber(data.montant)} FCFA', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _Chip(label: data.carburant ?? 'Carburant', tone: Tone.brand, icon: Icons.water_drop_rounded),
            _Chip(label: etat.label, tone: etat.tone, dot: true),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final w = (c.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 14,
              children: [
                for (final (label, value, icon) in infos)
                  SizedBox(
                    width: w,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, size: 16, color: AppColors.brand),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label, style: t.bodySmall),
                              const SizedBox(height: 1),
                              Text(value.isEmpty ? '—' : value, style: t.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CompactStub extends StatelessWidget {
  const _CompactStub({required this.data});
  final TicketData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final valable = data.valable;
    final texte = valable
        ? 'Afficher le QR code'
        : data.dateValidation != null
        ? 'Utilisé le ${formatDate(data.dateValidation, withTime: true)}'
        : 'Émis le ${formatDate(data.dateEmission)}';
    return Row(
      children: [
        Icon(
          valable ? Icons.qr_code_2_rounded : Icons.receipt_long_outlined,
          size: 22,
          color: valable ? AppColors.brand : t.bodySmall?.color,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texte,
            style: (valable ? t.titleSmall?.copyWith(color: AppColors.brand) : t.bodySmall),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (valable) Text(formatDate(data.dateEmission), style: t.bodySmall),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right_rounded, color: t.bodySmall?.color),
      ],
    );
  }
}

class _QrStub extends StatelessWidget {
  const _QrStub({required this.data});
  final TicketData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final qr = data.codeQr;
    if (qr == null || qr.isEmpty) {
      return const InlineAlert(tone: Tone.warning, message: 'QR code indisponible pour ce ticket.');
    }
    final valable = data.valable;
    return Column(
      children: [
        Opacity(
          opacity: valable ? 1 : 0.28,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.brand.withValues(alpha: 0.35), width: 1.5),
            ),
            child: QrImageView(
              data: qr,
              size: 196,
              padding: EdgeInsets.zero,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF18181B)),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF18181B)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          valable
              ? 'Présentez ce code à l\'agent de la station'
              : data.rejete
              ? 'Ce ticket a été rejeté'
              : 'Ce ticket a déjà été utilisé',
          style: t.titleSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(valable ? 'Valable une seule fois · N° ${data.numero}' : 'N° ${data.numero}', style: t.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }
}

/// Tampon encré « UTILISÉ » / « REJETÉ », légèrement incliné.
class _Tampon extends StatelessWidget {
  const _Tampon({required this.label, required this.tone});
  final String label;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final c = tone.fg.withValues(alpha: 0.75);
    return IgnorePointer(
      child: Transform.rotate(
        angle: -0.22,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: c, width: 2.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(color: c, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Forme et perforation
// ---------------------------------------------------------------------------

/// Moitié de ticket : coins arrondis, et deux encoches en demi-cercle du
/// côté de la perforation (la seconde moitié porte l'autre demi-encoche).
class _TicketPieceBorder extends ShapeBorder {
  const _TicketPieceBorder({
    required this.notchTop,
    required this.notchBottom,
    required this.radius,
    required this.notch,
    this.side = BorderSide.none,
  });

  final bool notchTop;
  final bool notchBottom;
  final double radius;
  final double notch;
  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final r = Radius.circular(radius);
    final body = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: notchTop ? Radius.zero : r,
          topRight: notchTop ? Radius.zero : r,
          bottomLeft: notchBottom ? Radius.zero : r,
          bottomRight: notchBottom ? Radius.zero : r,
        ),
      );
    final cuts = Path();
    if (notchTop) {
      cuts
        ..addOval(Rect.fromCircle(center: rect.topLeft, radius: notch))
        ..addOval(Rect.fromCircle(center: rect.topRight, radius: notch));
    }
    if (notchBottom) {
      cuts
        ..addOval(Rect.fromCircle(center: rect.bottomLeft, radius: notch))
        ..addOval(Rect.fromCircle(center: rect.bottomRight, radius: notch));
    }
    return Path.combine(PathOperation.difference, body, cuts);
  }

  /// Contour sans le bord de la perforation : la jointure entre les deux
  /// moitiés reste ouverte, seuls les pointillés la marquent.
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    final r = rect.deflate(side.width / 2);
    final rr = Radius.circular(radius);
    final n = Radius.circular(notch);
    final p = Path();
    if (notchBottom && !notchTop) {
      p
        ..moveTo(r.left + notch, r.bottom)
        ..arcToPoint(Offset(r.left, r.bottom - notch), radius: n, clockwise: false)
        ..lineTo(r.left, r.top + radius)
        ..arcToPoint(Offset(r.left + radius, r.top), radius: rr)
        ..lineTo(r.right - radius, r.top)
        ..arcToPoint(Offset(r.right, r.top + radius), radius: rr)
        ..lineTo(r.right, r.bottom - notch)
        ..arcToPoint(Offset(r.right - notch, r.bottom), radius: n, clockwise: false);
    } else if (notchTop && !notchBottom) {
      p
        ..moveTo(r.right - notch, r.top)
        ..arcToPoint(Offset(r.right, r.top + notch), radius: n, clockwise: false)
        ..lineTo(r.right, r.bottom - radius)
        ..arcToPoint(Offset(r.right - radius, r.bottom), radius: rr)
        ..lineTo(r.left + radius, r.bottom)
        ..arcToPoint(Offset(r.left, r.bottom - radius), radius: rr)
        ..lineTo(r.left, r.top + notch)
        ..arcToPoint(Offset(r.left + notch, r.top), radius: n, clockwise: false);
    } else {
      p.addPath(getOuterPath(r), Offset.zero);
    }
    canvas.drawPath(p, side.toPaint());
  }

  @override
  ShapeBorder scale(double t) =>
      _TicketPieceBorder(notchTop: notchTop, notchBottom: notchBottom, radius: radius * t, notch: notch * t, side: side.scale(t));
}

/// Ligne de perforation en pointillés.
class _DashPainter extends CustomPainter {
  const _DashPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const dash = 6.0, gap = 5.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset((x + dash).clamp(0, size.width), 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
