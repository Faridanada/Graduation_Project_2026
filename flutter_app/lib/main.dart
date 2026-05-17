import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rehabilitation_app/ui/WelcomePage.dart';
import 'package:rehabilitation_app/ui/login.dart';
import 'package:rehabilitation_app/ui/signup.dart';
import 'package:rehabilitation_app/ui/patientHome.dart' as patient_home;
import 'package:rehabilitation_app/ui/DoctorHome.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
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
    _checkAuth();
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

    // Attempt to validate token by fetching profile
    final profile = await ApiService.getUserProfile();

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
