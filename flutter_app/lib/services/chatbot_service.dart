class ChatbotService {
  String buildResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('exercise') || lowerMessage.contains('pain')) {
      return 'For exercise-related questions, I recommend:\n'
          '• Start with low-intensity exercises\n'
          '• Stop if you experience sharp pain\n'
          '• Consult your therapist for personalized guidance';
    }

    if (lowerMessage.contains('wound') || lowerMessage.contains('photo')) {
      return 'For wound care:\n'
          '• Take photos from the same angle for consistency\n'
          '• Ensure good lighting\n'
          '• Keep the area clean before uploading\n\n'
          'Upload your photos regularly so your doctor can monitor progress!';
    }

    if (lowerMessage.contains('appointment') ||
        lowerMessage.contains('schedule')) {
      return 'To schedule or view appointments:\n'
          '• Go to the Appointments tab\n'
          '• Click "Book Appointment" to reserve a slot\n'
          '• Check your therapist\'s availability\n\n'
          'You can also message your therapist directly!';
    }

    if (lowerMessage.contains('medication') ||
        lowerMessage.contains('medicine')) {
      return 'For medication questions:\n'
          '• Follow your doctor\'s prescribed instructions\n'
          '• Report any side effects immediately\n'
          '• Don\'t change dosages without consulting your doctor\n\n'
          'Chat with your doctor through the app for personalized advice.';
    }

    if (lowerMessage.contains('recovery') ||
        lowerMessage.contains('progress')) {
      return 'Tracking your recovery:\n'
          '• Upload wound photos regularly\n'
          '• Log your exercises daily\n'
          '• Check AI-generated progress reports\n'
          '• Stay in touch with your therapist\n\n'
          'Consistency is key to faster recovery!';
    }

    if (lowerMessage.contains('help') || lowerMessage.contains('support')) {
      return 'I can help with:\n'
          '✓ Exercise guidance\n'
          '✓ Wound care tips\n'
          '✓ Appointment scheduling\n'
          '✓ Recovery progress\n'
          '✓ General app navigation';
    }

    if (lowerMessage.contains('contact') ||
        lowerMessage.contains('therapist')) {
      return 'To contact your therapist:\n'
          '• Go to the Chats section\n'
          '• Select your therapist\n'
          '• Send a message or request a video call\n\n'
          'For urgent matters, call the support hotline!';
    }

    return 'I am unable to answer this question. Please ask your doctor for more information.';
  }
}
