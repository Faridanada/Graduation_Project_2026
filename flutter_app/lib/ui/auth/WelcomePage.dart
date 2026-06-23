import 'package:flutter/material.dart';
import 'package:rehabilitation_app/ui/auth/OnboardingPage.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 3 seconds for one full spin
    )..repeat();

    // Navigate to onboarding after exactly 2 full spins (6 seconds)
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => const OnboardingPage(userEmail: null)),
        );
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background waves and dots
          Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundPainter(),
            ),
          ),
          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Image Container with Loading Animation
                SizedBox(
                  width: 290,
                  height: 290,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circle that fills from 0 to 100% and restarts
                      AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return SizedBox(
                            width: 290,
                            height: 290,
                            child: CircularProgressIndicator(
                              value: _rotationController.value, // Animates from 0.0 to 1.0
                              strokeWidth: 3.0,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF86B9C1)),
                            ),
                          );
                        },
                      ),
                      // Main Logo Container
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          // Removed the Border.all since FinalLogo.png already has its own border
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/FinalLogo.png', // Main knee logo
                            fit: BoxFit.cover, // Fill the circle entirely
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset('assets/images/logo.png', fit: BoxFit.cover);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // FLEXIO Text with lines
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 1,
                      color: const Color(0xFF86B9C1),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'F L E X I O',
                      style: TextStyle(
                        fontSize: 34,
                        fontFamily: 'Inter', // Assuming modern font
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4.0,
                        color: Color(0xFF0F2C59),
                      ),
                    ),
                    const SizedBox(width: 11), // Adjusting for letter spacing shift
                    Container(
                      width: 40,
                      height: 1,
                      color: const Color(0xFF86B9C1),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Small dot under the text
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF86B9C1),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Top-left subtle wave 1 (Lightest)
    final path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(size.width * 0.6, 0);
    path1.quadraticBezierTo(
        size.width * 0.2, size.height * 0.05, 0, size.height * 0.25);
    path1.close();
    paint.color = const Color(0xFFF3F7FB);
    canvas.drawPath(path1, paint);

    // Top-left subtle wave 2 (Slightly darker)
    final path2 = Path();
    path2.moveTo(0, 0);
    path2.lineTo(size.width * 0.35, 0);
    path2.quadraticBezierTo(
        size.width * 0.05, size.height * 0.05, 0, size.height * 0.15);
    path2.close();
    paint.color = const Color(0xFFE8F0F8);
    canvas.drawPath(path2, paint);

    // Bottom-right subtle wave 1
    final path3 = Path();
    path3.moveTo(size.width, size.height);
    path3.lineTo(size.width * 0.4, size.height);
    path3.quadraticBezierTo(
        size.width * 0.8, size.height * 0.95, size.width, size.height * 0.75);
    path3.close();
    paint.color = const Color(0xFFF3F7FB);
    canvas.drawPath(path3, paint);

    // Bottom-right subtle wave 2
    final path4 = Path();
    path4.moveTo(size.width, size.height);
    path4.lineTo(size.width * 0.65, size.height);
    path4.quadraticBezierTo(
        size.width * 0.95, size.height * 0.95, size.width, size.height * 0.85);
    path4.close();
    paint.color = const Color(0xFFE8F0F8);
    canvas.drawPath(path4, paint);

    // Dotted pattern configuration
    final dotPaint = Paint()
      ..color = const Color(0xFFE1EBF5)
      ..style = PaintingStyle.fill;

    const double dotRadius = 1.5;
    const double spacing = 18.0;

    // Top-right dots
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        canvas.drawCircle(
          Offset(size.width - 20 - (i * spacing), 40 + (j * spacing)),
          dotRadius,
          dotPaint,
        );
      }
    }

    // Bottom-left dots
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        canvas.drawCircle(
          Offset(20 + (i * spacing), size.height - 40 - (j * spacing)),
          dotRadius,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
