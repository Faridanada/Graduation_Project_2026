import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hello! 👋 I\'m FLEXIO\'s AI Assistant. How can I help you today?',
      isBot: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final userMessage = ChatMessage(
      text: _messageController.text,
      isBot: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
    });

    _scrollToBottom();

    // Simulate bot response delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final botResponse = _generateBotResponse(userMessage.text);
      setState(() {
        _messages.add(botResponse);
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  ChatMessage _generateBotResponse(String userMessage) {
    String responseText = '';

    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('exercise') || lowerMessage.contains('pain')) {
      responseText = 'For exercise-related questions, I recommend:\n'
          '• Start with low-intensity exercises\n'
          '• Stop if you experience sharp pain\n'
          '• Consult your therapist for personalized guidance\n\n'
          'Would you like specific exercise recommendations?';
    } else if (lowerMessage.contains('wound') ||
        lowerMessage.contains('photo')) {
      responseText = 'For wound care:\n'
          '• Take photos from the same angle for consistency\n'
          '• Ensure good lighting\n'
          '• Keep the area clean before uploading\n\n'
          'Upload your photos regularly so your doctor can monitor progress!';
    } else if (lowerMessage.contains('appointment') ||
        lowerMessage.contains('schedule')) {
      responseText = 'To schedule or view appointments:\n'
          '• Go to the Appointments tab\n'
          '• Click "Book Appointment" to reserve a slot\n'
          '• Check your therapist\'s availability\n\n'
          'You can also message your therapist directly!';
    } else if (lowerMessage.contains('medication') ||
        lowerMessage.contains('medicine')) {
      responseText = 'For medication questions:\n'
          '• Follow your doctor\'s prescribed instructions\n'
          '• Report any side effects immediately\n'
          '• Don\'t change dosages without consulting your doctor\n\n'
          'Chat with your doctor through the app for personalized advice.';
    } else if (lowerMessage.contains('recovery') ||
        lowerMessage.contains('progress')) {
      responseText = 'Tracking your recovery:\n'
          '• Upload wound photos regularly\n'
          '• Log your exercises daily\n'
          '• Check AI-generated progress reports\n'
          '• Stay in touch with your therapist\n\n'
          'Consistency is key to faster recovery!';
    } else if (lowerMessage.contains('help') ||
        lowerMessage.contains('support')) {
      responseText = 'I can help with:\n'
          '✓ Exercise guidance\n'
          '✓ Wound care tips\n'
          '✓ Appointment scheduling\n'
          '✓ Recovery progress\n'
          '✓ General app navigation\n\n'
          'What would you like help with?';
    } else if (lowerMessage.contains('contact') ||
        lowerMessage.contains('therapist')) {
      responseText = 'To contact your therapist:\n'
          '• Go to the Chats section\n'
          '• Select your therapist\n'
          '• Send a message or request a video call\n\n'
          'For urgent matters, call the support hotline!';
    } else {
      responseText = 'That\'s a great question! 🤔\n\n'
          'You can also:\n'
          '• Chat directly with your therapist\n'
          '• Check Help & Support for more info\n'
          '• View FAQ in Settings\n\n'
          'How else can I assist you?';
    }

    return ChatMessage(
      text: responseText,
      isBot: true,
      timestamp: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BA5CF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FLEXIO Assistant',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: Color(0xFF6BA5CF), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: const Color(0xFF6BA5CF),
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isBot ? Colors.white : const Color(0xFF6BA5CF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isBot ? Colors.black87 : Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}
