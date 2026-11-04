import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Smart Gear Brand Logo — uses the exact same left-facing helmet vector
/// as the web favicon.svg / app icon for visual consistency across all surfaces.
class BrandLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool isDark;
  final bool showTagline;

  const BrandLogo({
    super.key,
    this.iconSize = 38,
    this.fontSize = 20,
    this.isDark = false,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkCharcoal;
    final taglineColor = isDark ? Colors.white60 : AppColors.slate;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon — exact same SVG helmet used in favicon.svg / app icon
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5BA4), Color(0xFF0E2D58)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(iconSize * 0.26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B5BA4).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(iconSize * 0.26),
                child: CustomPaint(
                  painter: _HelmetIconPainter(),
                ),
              ),
            ),
            SizedBox(width: iconSize * 0.28),
            // "Smart Gear" title
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
                children: [
                  TextSpan(
                    text: 'Smart ',
                    style: TextStyle(color: textColor),
                  ),
                  TextSpan(
                    text: 'Gear',
                    style: const TextStyle(color: AppColors.mountainBlue),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            '"Gear Up. Ride Safe. Ride Ready."',
            style: TextStyle(
              fontSize: (fontSize * 0.55).clamp(10.0, 13.0),
              color: taglineColor,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Paints the exact left-facing helmet from the app icon / favicon.svg
/// using the Material Symbols Rounded "sports_motorsports" filled vector
/// path, scaled and centred on the icon canvas.
class _HelmetIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background is handled by the parent Container gradient.
    // Draw the white helmet path (from Material Symbols "sports_motorsports" filled).
    // Original viewBox: 0 -960 960 960  ⟹  we remap to [0, size] space.
    final double scale = size.width / 960.0;
    final double yOffset = size.height; // flip the -960…0 y-range to 0…size

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Transform: x' = x * scale,  y' = yOffset + y * scale  (y values are negative)
    Path buildHelmet() {
      // Subpath 1 — main helmet body + visor window (even-odd fill so window is transparent)
      final p = Path();
      // M579,-182 H96 q-5,0 -9,-4 t-4,-9 q0,-47 1.5,-82.5 T89,-341
      // h314 q69,0 117.5,-49 T569,-510 q0,-51 -28.5,-92.5 T464,-664
      // l-134,-53 q54,-30 113.5,-45.5 T567,-778
      // q128,0 219,86.5 T877,-480
      // q0,125 -86.5,211.5 T579,-182 Z
      double x(double v) => v * scale;
      double y(double v) => yOffset + v * scale;

      p.moveTo(x(579), y(-182));
      p.lineTo(x(96), y(-182));
      p.relativeQuadraticBezierTo(x(-5) - x(0), 0, x(-9) - x(0), y(-4) - y(-182));
      // Use absolute coords for clarity from here
      p.lineTo(x(83), y(-195)); // approx q-4,-9
      p.cubicTo(x(83), y(-242), x(87.5), y(-276.5), x(91), y(-341));
      p.lineTo(x(405), y(-341));
      p.cubicTo(x(474), y(-341), x(522.5), y(-390), x(522.5), y(-390));
      p.quadraticBezierTo(x(569), y(-439), x(569), y(-510));
      p.cubicTo(x(569), y(-561), x(540.5), y(-602.5), x(540.5), y(-602.5));
      p.quadraticBezierTo(x(512), y(-644), x(464), y(-664));
      p.lineTo(x(330), y(-717));
      p.cubicTo(x(384), y(-747), x(443.5), y(-762.5), x(443.5), y(-762.5));
      p.quadraticBezierTo(x(503), y(-778), x(567), y(-778));
      p.cubicTo(x(695), y(-778), x(786), y(-691.5), x(786), y(-691.5));
      p.quadraticBezierTo(x(877), y(-605), x(877), y(-480));
      p.cubicTo(x(877), y(-355), x(790.5), y(-268.5), x(790.5), y(-268.5));
      p.quadraticBezierTo(x(704), y(-182), x(579), y(-182));
      p.close();

      // M102,-420 q20,-71 59,-133.5 T254,-664
      // l180,73 q26,11 41,33 t15,48
      // q0,38 -25.5,64 T401,-420 H102 Z
      p.moveTo(x(102), y(-420));
      p.cubicTo(x(122), y(-491), x(161), y(-553.5), x(161), y(-553.5));
      p.quadraticBezierTo(x(200), y(-616), x(254), y(-664));
      p.lineTo(x(434), y(-591));
      p.cubicTo(x(460), y(-580), x(475), y(-558), x(475), y(-558));
      p.quadraticBezierTo(x(490), y(-536), x(490), y(-510));
      p.cubicTo(x(490), y(-472), x(464.5), y(-446), x(464.5), y(-446));
      p.quadraticBezierTo(x(439), y(-420), x(401), y(-420));
      p.lineTo(x(102), y(-420));
      p.close();

      return p;
    }

    // Use evenOdd fill so the inner visor window punches a hole
    canvas.drawPath(
      buildHelmet()..fillType = PathFillType.evenOdd,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
