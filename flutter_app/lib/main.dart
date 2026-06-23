import 'package:flutter/material.dart';
import 'package:rehabilitation_app/ui/app_theme.dart';
import 'package:rehabilitation_app/ui/auth/WelcomePage.dart';
import 'package:rehabilitation_app/ui/auth/login.dart';
import 'package:rehabilitation_app/ui/auth/signup.dart';
import 'package:rehabilitation_app/ui/patient/home/patientHome.dart'
    as patient_home;
import 'package:rehabilitation_app/ui/doctor/home/DoctorHome.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.loadToken(); // Restore JWT from disk
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rehabilitation App',
      theme: AppTheme.lightTheme(),
      home: const InitialCoordinator(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class InitialCoordinator extends StatefulWidget {
  const InitialCoordinator({Key? key}) : super(key: key);

  @override
  State<InitialCoordinator> createState() => _InitialCoordinatorState();
}

class _InitialCoordinatorState extends State<InitialCoordinator> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    // If no token exists in persistent storage, go to WelcomePage
    if (ApiService.currentToken == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomePage()));
      }
      return;
    }

    try {
      // Attempt to validate token by fetching profile
      final profile = await ApiService.getUserProfileOrThrow();

      if (mounted) {
        if (profile == null) {
          // Token was invalid or expired
          await ApiService.clearToken();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const WelcomePage()));
        } else {
          // Active session. Route based on role
          final String role =
              profile['role']?.toString().toLowerCase() ?? 'patient';
          if (role == 'doctor') {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DoctorHome()));
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const patient_home.PatientHomeScreen()));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Network Error'),
            content: const Text(
                'Could not connect to the server. Please check your internet connection and try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _checkAuth(); // Retry
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      body: const Center(
        child: CircularProgressIndicator(color: Color(0xFF2196F3)),
      ),
    );
  }
}
