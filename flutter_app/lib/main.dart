import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rehabilitation_app/ui/WelcomePage.dart';
import 'package:rehabilitation_app/ui/login.dart';
import 'package:rehabilitation_app/ui/signup.dart';
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
      home: const WelcomePage(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
