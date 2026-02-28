import 'package:flutter/material.dart';
import 'dart:async';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  // Entrance controller (logo + texts)
  late AnimationController _enterController;

  // Dots controller (unchanged behavior)
  late AnimationController _dotsController;

  // Animations
  late Animation<Offset> _logoSlide; // from top to center
  late Animation<Offset> _textsSlide; // from bottom to center
  late Animation<double> _logoFade;
  late Animation<double> _textsFade;

  int _activeDot = 0;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // 1) Entrance animation controller
    _enterController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    // Easing curves for natural movement
    final curve = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutCubic,
    );

    // 2) Define slides:
    //    - Logo: start slightly above (y = -0.4) → center (0)
    //    - Texts: start slightly below (y = 0.4) → center (0)
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.40),
      end: Offset.zero,
    ).animate(curve);

    _textsSlide = Tween<Offset>(
      begin: const Offset(0, 0.40),
      end: Offset.zero,
    ).animate(curve);

    // Optional fades (make entrance softer)
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _enterController,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOut)),
    );
    _textsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _enterController,
          curve: const Interval(0.1, 1.0, curve: Curves.easeOut)),
    );

    // Kick off entrance
    _enterController.forward();

    // 3) Loading dots animation (same logic, just moved here)
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _dotsController.addListener(() {
      setState(() {
        _activeDot = (_dotsController.value * 3).toInt() % 3;
      });
    });

    // 4) Navigate to login after 5 seconds (unchanged)
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _enterController.dispose();
    _dotsController.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep plenty of space so the slide looks natural
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO: slides from top, fades in
              SlideTransition(
                position: _logoSlide,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: Image.asset(
                    'assets/images/logo.jpg.jpeg',
                    width: 220, // you can adjust to fit your design
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: const Color(0xFF95B8D1),
                        child: const Center(
                          child: Icon(
                            Icons.healing,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // TEXTS: slide from bottom, fade in
              SlideTransition(
                position: _textsSlide,
                child: FadeTransition(
                  opacity: _textsFade,
                  child: Column(
                    children: [
                      const Text(
                        'Welcome to your recovery journey',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          height: 1.25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Professional rehabilitation monitoring and care',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Loading dots (unchanged visual)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLoadingDot(0),
                  const SizedBox(width: 8),
                  _buildLoadingDot(1),
                  const SizedBox(width: 8),
                  _buildLoadingDot(2),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDot(int index) {
    final bool isActive = _activeDot == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 12 : 8,
      height: isActive ? 12 : 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF95B8D1) : Colors.grey[300],
      ),
    );
  }
}
