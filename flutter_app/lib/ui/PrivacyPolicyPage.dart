import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BA5CF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPolicySection(
                  'Data Collection',
                  'We collect information necessary to provide rehabilitation services, including personal health data, medical history, and progress tracking information. This data is used solely for improving your treatment plan.',
                ),
                _buildPolicySection(
                  'Data Protection',
                  'Your data is protected using industry-standard encryption. We comply with HIPAA regulations and maintain strict confidentiality of all medical information.',
                ),
                _buildPolicySection(
                  'Third-Party Sharing',
                  'We do not share your personal or medical information with third parties without your explicit consent, except as required by law.',
                ),
                _buildPolicySection(
                  'User Rights',
                  'You have the right to access, modify, or delete your personal information at any time by contacting our support team.',
                ),
                _buildPolicySection(
                  'Cookies & Tracking',
                  'We use cookies to improve user experience. You can disable cookies in your device settings, though some features may be limited.',
                ),
                _buildPolicySection(
                  'Policy Updates',
                  'We may update this privacy policy periodically. We will notify you of any significant changes via email or in-app notification.',
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Last updated: March 1, 2026',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[900],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

