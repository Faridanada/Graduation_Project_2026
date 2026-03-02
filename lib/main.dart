import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rehabilitation_app/login.dart';

//new part
import 'features/presentation/patient/presentation/screens/patient_home_screen.dart';

void main() {
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
      //new try
      home: const PatientHomeScreen(),
      //old
      //home: const WelcomePage(),
      routes: {'/login': (context) => const LoginScreen()},
      debugShowCheckedModeBanner: false,
    );
  }
}
