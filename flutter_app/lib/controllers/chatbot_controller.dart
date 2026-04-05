import 'package:flutter/foundation.dart';

import 'package:rehabilitation_app/services/chatbot_service.dart';

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}

class ChatbotController extends ChangeNotifier {
  ChatbotController({ChatbotService? service})
      : _service = service ?? ChatbotService() {
    _messages.add(
      ChatMessage(
        text:
            'Hello! 👋 I\'m FLEXIO\'s AI Assistant. How can I help you today?',
        isBot: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    );
  }

  final ChatbotService _service;
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> sendMessage(String rawMessage) async {
    final text = rawMessage.trim();
    if (text.isEmpty) return;

    _messages.add(
      ChatMessage(
        text: text,
        isBot: false,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 500));

    _messages.add(
      ChatMessage(
        text: _service.buildResponse(text),
        isBot: true,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
