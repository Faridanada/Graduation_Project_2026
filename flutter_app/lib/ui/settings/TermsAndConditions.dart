import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Privacy Policy'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Use & Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last Updated: April 2026\n\n'
              'Welcome to our platform. By accessing or using our application, you agree to be bound by these terms. This application provides tools for physical therapy management and communication between doctors and patients.\n\n'
              '1. Medical Disclaimer\n'
              'This application does not provide medical advice. All content, including text, graphics, images, and tools, is for general informational purposes only. Do not disregard professional medical advice or delay seeking treatment based on something you have read here.\n\n'
              '2. User Data and Privacy\n'
              'Your privacy is our priority. We employ industry-standard encryption to protect your sensitive health data stored in our databases. By using the app, you consent to the collection and use of your profile data, injury history, and chat logs exclusively for the purpose of facilitating your physical therapy rehabilitation and doctor-patient communication.\n\n'
              '3. Account Responsibilities\n'
              'You are responsible for safeguarding your login credentials. We will never ask for your password directly outside of the secure login portal. If you suspect unauthorized access, reset your password immediately.\n\n'
              '4. Communication Protocol\n'
              'Features such as real-time messaging and wound monitoring are provided as supplementary tools for your physical therapy journey. In case of an emergency, do not use this application. Please contact your local emergency response service immediately.\n\n'
              '5. AI Training & Sensor Data Usage\n'
              'By using this application, you expressly agree and consent that any sensor data collected during your physical therapy exercises may be used by us to train, improve, and refine our artificial intelligence models. We are committed to your privacy and assure you that this data will never be published, shared, or sold to any third-party companies. Your data empowers our AI to offer increasingly personalized and accurate insights to help you and others heal faster.\n\n'
              '6. Modifications\n'
              'We reserve the right to modify these terms at any time. Continued use of the application following any changes indicates your acceptance of the new terms.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'I Understand & Agree',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
