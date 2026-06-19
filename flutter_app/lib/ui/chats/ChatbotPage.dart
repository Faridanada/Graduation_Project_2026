import 'package:flutter/material.dart';

import 'package:rehabilitation_app/controllers/chatbot_controller.dart';
import 'package:rehabilitation_app/ui/shared/profile_avatar.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatbotController _chatbotController;

  @override
  void initState() {
    super.initState();
    _chatbotController = ChatbotController();
    _chatbotController.addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    _chatbotController.removeListener(_scrollToBottom);
    _chatbotController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text;
    _messageController.clear();
    await _chatbotController.sendMessage(message);
  }

  Future<void> _sendQuickReply(String text) async {
    await _chatbotController.sendMessage(text);
  }

  void _scrollToBottom() {
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () { if (Navigator.canPop(context)) Navigator.pop(context); },
        ),
        title: Row(
          children: [
            const ProfileAvatar(
              name: 'F',
              radius: 18,
              backgroundColor: Color(0xFF6BA5CF),
              textColor: Colors.white,
            ),
            const SizedBox(width: 12),
            const Text(
              'FLEXIO Assistant',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _chatbotController,
        builder: (context, _) {
          final messages = _chatbotController.messages;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF6BA5CF),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Column(
      crossAxisAlignment: message.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: message.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (message.isBot) ...[
                const ProfileAvatar(
                  name: 'F',
                  radius: 16,
                  backgroundColor: Color(0xFF6BA5CF),
                  textColor: Colors.white,
                ),
                const SizedBox(width: 8),
              ],
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: message.isBot ? Colors.grey[200] : const Color(0xFF6BA5CF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isBot ? Colors.black : Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              if (!message.isBot) const SizedBox(width: 8),
            ],
          ),
        ),
        if (message.quickReplies != null && message.quickReplies!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: message.quickReplies!.map((reply) {
                return ActionChip(
                  label: Text(
                    reply,
                    style: const TextStyle(
                      color: Color(0xFF6BA5CF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF6BA5CF), width: 1),
                  onPressed: () => _sendQuickReply(reply),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}


