import 'package:flutter/material.dart';

// Fichier identique dans faso_carbu_web et faso_carbu_mobile.
// Géométrie identique à brand/logo.svg (repère 100 x 100).

/// Pictogramme FasoCarbu : une goutte de carburant découpée comme un ticket
/// (deux encoches et une perforation), sur un carré arrondi orange.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 40, this.withBackground = true, this.color});

  final double size;

  /// Carré arrondi en dégradé orange derrière la goutte blanche.
  final bool withBackground;

  /// Couleur de la goutte quand il n'y a pas de fond (orange par défaut).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _LogoPainter(withBackground: withBackground, color: color)),
    );
  }
}

/// Logo complet : pictogramme + « FasoCarbu ».
class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 36, this.onDark = false, this.showName = true, this.tagline});

  final double size;
  final bool onDark;
  final bool showName;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    final base = onDark ? Colors.white : Theme.of(context).textTheme.titleLarge?.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoMark(size: size),
        if (showName) ...[
          SizedBox(width: size * 0.3),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'Faso', style: TextStyle(color: base)),
                  const TextSpan(text: 'Carbu', style: TextStyle(color: Color(0xFFF97316))),
                ]),
                style: TextStyle(fontSize: size * 0.56, fontWeight: FontWeight.w800, letterSpacing: -0.4, height: 1.1),
              ),
              if (tagline != null)
                Text(
                  tagline!,
                  style: TextStyle(
                    fontSize: size * 0.27,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    color: (onDark ? Colors.white : base ?? Colors.black).withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter({required this.withBackground, this.color});
  final bool withBackground;
  final Color? color;

  static Path dropPath(double s) {
    Offset p(double x, double y) => Offset(x * s, y * s);
    final drop = Path()
      ..moveTo(50 * s, 15 * s)
      ..cubicTo(54 * s, 18 * s, 63.33 * s, 36.5 * s, 70.47 * s, 47.48 * s)
      ..arcToPoint(p(29.53, 47.48), radius: Radius.circular(24 * s), largeArc: true, clockwise: true)
      ..cubicTo(36.67 * s, 36.5 * s, 46 * s, 18 * s, 50 * s, 15 * s)
      ..close();
    final cuts = Path()
      ..addOval(Rect.fromCircle(center: p(26.19, 63), radius: 5 * s))
      ..addOval(Rect.fromCircle(center: p(73.81, 63), radius: 5 * s));
    // Perforation : tirets de 4,2 espacés de 3, épaisseur 2,6.
    var x = 33.5;
    while (x < 66.5) {
      final end = (x + 4.2).clamp(0, 66.5).toDouble();
      cuts.addRRect(RRect.fromRectAndRadius(Rect.fromLTRB(x * s, 61.7 * s, end * s, 64.3 * s), Radius.circular(1.3 * s)));
      x += 7.2;
    }
    return Path.combine(PathOperation.difference, drop, cuts);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    if (withBackground) {
      final rect = Offset.zero & size;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(22 * s)),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEA580C), Color(0xFFF59E0B)],
          ).createShader(rect),
      );
    }
    canvas.drawPath(
      dropPath(s),
      Paint()
        ..isAntiAlias = true
        ..color = withBackground ? Colors.white : (color ?? const Color(0xFFEA580C)),
    );
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.withBackground != withBackground || old.color != color;
}
