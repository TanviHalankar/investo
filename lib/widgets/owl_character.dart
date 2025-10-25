import 'package:flutter/material.dart';

class OwlCharacter extends StatefulWidget {
  final double size;
  final bool isAnimated;
  final Color? primaryColor;
  final Color? secondaryColor;

  const OwlCharacter({
    super.key,
    this.size = 40.0,
    this.isAnimated = true,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<OwlCharacter> createState() => _OwlCharacterState();
}

// Simple owl using emoji as fallback
class SimpleOwlCharacter extends StatelessWidget {
  final double size;
  
  const SimpleOwlCharacter({super.key, this.size = 40.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Center(
        child: Text(
          '🦉',
          style: TextStyle(fontSize: size * 0.6),
        ),
      ),
    );
  }
}

class _OwlCharacterState extends State<OwlCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: -5.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 0.8, curve: Curves.easeInOut),
    ));

    if (widget.isAnimated) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? const Color(0xFF8B4513);
    final secondaryColor = widget.secondaryColor ?? const Color(0xFFDEB887);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: OwlPainter(
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                blinkValue: _blinkAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class OwlPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double blinkValue;

  OwlPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.blinkValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Ensure minimum size for visibility
    final minRadius = 8.0;
    final actualRadius = radius < minRadius ? minRadius : radius;

    // Owl body (main circle)
    paint.color = primaryColor;
    canvas.drawCircle(center, actualRadius * 0.9, paint);

    // Owl belly (lighter circle)
    paint.color = secondaryColor;
    canvas.drawCircle(center, actualRadius * 0.6, paint);

    // Ears/feathers on top
    paint.color = primaryColor;
    final earPath = Path();
    earPath.moveTo(center.dx - actualRadius * 0.3, center.dy - actualRadius * 0.8);
    earPath.lineTo(center.dx - actualRadius * 0.1, center.dy - actualRadius * 1.1);
    earPath.lineTo(center.dx + actualRadius * 0.1, center.dy - actualRadius * 1.1);
    earPath.lineTo(center.dx + actualRadius * 0.3, center.dy - actualRadius * 0.8);
    earPath.close();
    canvas.drawPath(earPath, paint);

    // Eyes
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(center.dx - actualRadius * 0.25, center.dy - actualRadius * 0.2),
      actualRadius * 0.15,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + actualRadius * 0.25, center.dy - actualRadius * 0.2),
      actualRadius * 0.15,
      paint,
    );

    // Eye pupils (with blink effect)
    paint.color = Colors.black;
    final pupilSize = actualRadius * 0.08 * blinkValue;
    canvas.drawCircle(
      Offset(center.dx - actualRadius * 0.25, center.dy - actualRadius * 0.2),
      pupilSize,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + actualRadius * 0.25, center.dy - actualRadius * 0.2),
      pupilSize,
      paint,
    );

    // Beak
    paint.color = const Color(0xFFFFA500);
    final beakPath = Path();
    beakPath.moveTo(center.dx - actualRadius * 0.1, center.dy + actualRadius * 0.1);
    beakPath.lineTo(center.dx, center.dy + actualRadius * 0.3);
    beakPath.lineTo(center.dx + actualRadius * 0.1, center.dy + actualRadius * 0.1);
    beakPath.close();
    canvas.drawPath(beakPath, paint);

    // Wings
    paint.color = primaryColor;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - actualRadius * 0.6, center.dy),
        width: actualRadius * 0.4,
        height: actualRadius * 0.6,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + actualRadius * 0.6, center.dy),
        width: actualRadius * 0.4,
        height: actualRadius * 0.6,
      ),
      paint,
    );

    // Feet
    paint.color = const Color(0xFFFFA500);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx - actualRadius * 0.3, center.dy + actualRadius * 0.8),
      Offset(center.dx - actualRadius * 0.4, center.dy + actualRadius * 0.9),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - actualRadius * 0.2, center.dy + actualRadius * 0.8),
      Offset(center.dx - actualRadius * 0.1, center.dy + actualRadius * 0.9),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + actualRadius * 0.2, center.dy + actualRadius * 0.8),
      Offset(center.dx + actualRadius * 0.1, center.dy + actualRadius * 0.9),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + actualRadius * 0.3, center.dy + actualRadius * 0.8),
      Offset(center.dx + actualRadius * 0.4, center.dy + actualRadius * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is OwlPainter && oldDelegate.blinkValue != blinkValue;
  }
}

// Static owl character for non-animated use
class StaticOwlCharacter extends StatelessWidget {
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  const StaticOwlCharacter({
    super.key,
    this.size = 40.0,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return OwlCharacter(
      size: size,
      isAnimated: false,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }
}
