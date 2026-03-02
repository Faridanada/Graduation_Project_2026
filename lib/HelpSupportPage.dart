import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

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
          'Help & Support',
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
                Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildFAQItem(
                  'How do I manage my active patients?',
                  'Access your Active Patients dashboard to view all current cases. Each patient card shows wound progression, exercise compliance, and AI-generated recovery insights. You can filter by treatment stage or urgency.',
                ),
                _buildFAQItem(
                  'How can I communicate with my patients?',
                  'Use the Chats section to message patients directly. You can send exercise videos, wound care instructions, or schedule video consultations. All conversations are HIPAA-compliant and encrypted.',
                ),
                _buildFAQItem(
                  'How do I customize exercise plans for patients?',
                  'Navigate to the patient\'s profile and select "Manage Exercises". You can assign exercises from the library, set frequencies, and adjust difficulty based on their progress. The AI will suggest modifications based on patient data.',
                ),
                _buildFAQItem(
                  'Is patient data secure and HIPAA-compliant?',
                  'Yes, all patient data is encrypted end-to-end and stored on HIPAA-compliant servers. Access logs are maintained, and you have full control over data sharing permissions.',
                ),
                _buildFAQItem(
                  'Can I export patient reports for insurance or referrals?',
                  'Yes, generate comprehensive reports from the patient profile. These include wound progression photos, exercise compliance data, and treatment outcomes. Reports can be exported as PDF or shared securely via the platform.',
                ),
                const SizedBox(height: 30),
                Text(
                  'Contact Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildContactMethod(
                  Icons.email_outlined,
                  'Email Support',
                  'support@flexio.com',
                  'Response time: 24 hours',
                ),
                _buildContactMethod(
                  Icons.phone_outlined,
                  'Phone Support',
                  '+1 (800) FLEXIO-1',
                  'Available: Mon-Fri, 9 AM - 6 PM EST',
                ),
                _buildContactMethod(
                  Icons.chat_outlined,
                  'Live Chat',
                  'Available in the app',
                  'Response time: Within 15 minutes',
                ),
                const SizedBox(height: 30),
                Text(
                  'Resources',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildResourceSection(
                  'Getting Started Guide',
                  'Learn how to use FLEXIO as a healthcare provider',
                  [
                    '1. Complete Your Professional Profile - Add your credentials, specializations, and practice details to build trust with patients.',
                    '2. Set Your Availability - Configure your working hours and appointment slots to manage your schedule efficiently.',
                    '3. Review Active Patients - Access the dashboard to see all assigned patients, their progress, and upcoming sessions.',
                    '4. Assign Treatment Plans - Create customized exercise and wound care plans using AI-powered recommendations.',
                    '5. Monitor Progress - Review patient compliance, wound healing photos, and AI-generated recovery insights.',
                    '6. Communicate Effectively - Use secure messaging and video calls to provide guidance and answer patient questions.',
                  ],
                ),
                _buildResourceSection(
                  'Best Practices for Patient Care',
                  'Clinical tips for optimal treatment outcomes',
                  [
                    '• Regular Progress Monitoring - Review patient wound photos and exercise logs at least twice weekly to catch complications early.',
                    '• Personalized Treatment Plans - Use AI insights to adapt exercise intensity and frequency based on individual recovery rates.',
                    '• Patient Engagement - Send motivational messages and acknowledge milestones to improve compliance rates.',
                    '• Early Intervention - Set up alerts for missed exercises or concerning wound photos to address issues promptly.',
                    '• Documentation Excellence - Keep detailed notes on each session for continuity of care and insurance requirements.',
                    '• Evidence-Based Modifications - Adjust treatment protocols based on the latest recovery data and patient feedback.',
                    '• Holistic Approach - Consider mental health, nutrition, and lifestyle factors when designing rehabilitation programs.',
                  ],
                ),
                _buildResourceSection(
                  'Clinical Exercise Library',
                  'Prescribe evidence-based exercises',
                  [
                    'How to Prescribe Exercises:',
                    '• Select from 100+ evidence-based exercises categorized by body region, difficulty, and therapeutic goal.',
                    '• Use AI recommendations based on patient\'s injury type, recovery stage, and physical capabilities.',
                    '• Set frequency (daily/weekly), repetitions, and duration for each exercise.',
                    '• Add video demonstrations and written instructions for patient clarity.',
                    '',
                    'Exercise Categories Available:',
                    '• Range of Motion - Ankle, knee, hip, shoulder, spine flexibility exercises',
                    '• Strengthening - Progressive resistance exercises for all major muscle groups',
                    '• Balance & Coordination - Stability training and gait improvement protocols',
                    '• Functional Training - Activities of daily living (ADL) simulation exercises',
                    '• Post-Surgical - Specialized protocols for various surgical procedures',
                    '',
                    'Tracking Patient Compliance:',
                    '• View completion rates, time spent, and patient-reported difficulty for each exercise.',
                    '• Receive alerts when patients consistently skip exercises or report excessive pain.',
                  ],
                ),
                _buildResourceSection(
                  'Professional Network',
                  'Connect with other healthcare providers',
                  [
                    'Join our community of physical therapists, doctors, and rehabilitation specialists:',
                    '',
                    '📌 Case Studies - Share challenging cases and get peer feedback on treatment approaches.',
                    '💬 Clinical Discussions - Discuss latest research, techniques, and treatment protocols.',
                    '🎓 Continuing Education - Access webinars, workshops, and certification programs.',
                    '🤝 Professional Collaboration - Network with specialists for patient referrals and consultations.',
                    '',
                    'Popular Discussion Topics:',
                    '• Novel Treatment Approaches',
                    '• Complex Case Management',
                    '• Technology Integration in Practice',
                    '• Patient Compliance Strategies',
                    '• Insurance & Billing Best Practices',
                    '',
                    'Note: All discussions are moderated and comply with HIPAA regulations. Never share patient-identifying information.',
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
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

  Widget _buildContactMethod(
    IconData icon,
    String title,
    String detail,
    String info,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6BA5CF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6BA5CF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6BA5CF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceSection(
      String title, String subtitle, List<String> content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          iconColor: const Color(0xFF6BA5CF),
          collapsedIconColor: Colors.grey[600],
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content.map((item) {
                  if (item.isEmpty) {
                    return const SizedBox(height: 8);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        height: 1.6,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
