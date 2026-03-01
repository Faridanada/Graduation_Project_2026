import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _dotsController;
  int _activeDot = 0;

  @override
  void initState() {
    super.initState();

    // Loading dots animation - cycle through each dot
    _dotsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _dotsController.addListener(() {
      setState(() {
        // Cycle through 0, 1, 2 continuously
        _activeDot = (_dotsController.value * 3).floor() % 3;
      });
    });

    // Navigate to login after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo1.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          // Loading dots overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 150),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLoadingDot(0),
                  const SizedBox(width: 8),
                  _buildLoadingDot(1),
                  const SizedBox(width: 8),
                  _buildLoadingDot(2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDot(int index) {
    final bool isActive = _activeDot == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: isActive ? 20 : 6,
      height: isActive ? 20 : 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isActive ? const Color(0xFF1F7D9F) : Colors.white.withOpacity(0.3),
      ),
    );
  }
}
