import 'package:flutter/material.dart';

class ConversationScreen extends StatefulWidget {
  final String name;
  final String initials;
  final String message;

  const ConversationScreen({
    Key? key,
    required this.name,
    required this.initials,
    required this.message,
  }) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late TextEditingController _messageController;
  late List<Map<String, String>> messages;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    // Initialize with predefined conversations based on patient name
    messages = _getConversationForPatient(widget.name);
  }

  List<Map<String, String>> _getConversationForPatient(String name) {
    final conversations = {
      'John Doe': [
        {
          'sender': 'Doctor',
          'message': 'Hi John! How are you feeling today?',
          'time': '9:00 AM',
          'type': 'received',
        },
        {
          'sender': 'John Doe',
          'message': 'Hi Doc! I\'m doing better, pain level is down to 3/10',
          'time': '9:05 AM',
          'type': 'sent',
        },
        {
          'sender': 'Doctor',
          'message':
              'Great! That\'s good progress. Did you complete the stretching exercises?',
          'time': '9:10 AM',
          'type': 'received',
        },
        {
          'sender': 'John Doe',
          'message': 'Yes, I did them twice today as you recommended',
          'time': '9:12 AM',
          'type': 'sent',
        },
        {
          'sender': 'Doctor',
          'message':
              'Excellent! Keep it up. Let\'s continue with the same routine for another week.',
          'time': '9:15 AM',
          'type': 'received',
        },
        {
          'sender': 'John Doe',
          'message': 'I completed the session 😊',
          'time': '2 min ago',
          'type': 'sent',
        },
      ],
      'Alice Smith': [
        {
          'sender': 'Doctor',
          'message':
              'Hi Alice, I received your wound photos. Looking much better!',
          'time': '10:30 AM',
          'type': 'received',
        },
        {
          'sender': 'Alice Smith',
          'message': 'Thank you! The healing is progressing well, right?',
          'time': '10:35 AM',
          'type': 'sent',
        },
        {
          'sender': 'Doctor',
          'message':
              'Yes, definitely. Keep the wound clean and dry. Continue with the dressing changes.',
          'time': '10:40 AM',
          'type': 'received',
        },
        {
          'sender': 'Alice Smith',
          'message': 'Can we reschedule tomorrow?',
          'time': '15 min ago',
          'type': 'sent',
        },
        {
          'sender': 'Doctor',
          'message': 'Of course. What time works best for you?',
          'time': '14 min ago',
          'type': 'received',
        },
      ],
      'Mark Lee': [
        {
          'sender': 'Doctor',
          'message': 'Mark, how\'s your shoulder mobility this week?',
          'time': '8:00 AM',
          'type': 'received',
        },
        {
          'sender': 'Mark Lee',
          'message':
              'Much better! I can now reach my shoulder without much pain',
          'time': '8:05 AM',
          'type': 'sent',
        },
        {
          'sender': 'Doctor',
          'message':
              'That\'s fantastic progress! Let\'s increase the exercises to medium difficulty.',
          'time': '8:10 AM',
          'type': 'received',
        },
        {
          'sender': 'Mark Lee',
          'message': 'Shoulder feels better today.',
          'time': '1 hour ago',
          'type': 'sent',
        },
        {
          'sender': 'Doctor',
          'message': 'Great to hear! Remember to ice after exercises.',
          'time': '45 min ago',
          'type': 'received',
        },
      ],
      'Emma Brown': [
        {
          'sender': 'Doctor',
          'message': 'Hi Emma! I reviewed your latest wound photos.',
          'time': '11:00 AM',
          'type': 'received',
        },
        {
          'sender': 'Emma Brown',
          'message': 'What do you think, doctor?',
          'time': '11:05 AM',
          'type': 'sent',
        },
        {
          'sender': 'Doctor',
          'message':
              'The wound is healing beautifully. Continue current treatment plan.',
          'time': '11:10 AM',
          'type': 'received',
        },
        {
          'sender': 'Emma Brown',
          'message': 'Thank you! I uploaded new wound photos.',
          'time': 'Yesterday',
          'type': 'sent',
        },
        {
          'sender': 'Doctor',
          'message':
              'Perfect! I\'ll review them and follow up with you tomorrow.',
          'time': 'Yesterday',
          'type': 'received',
        },
      ],
      'David Clark': [
        {
          'sender': 'Doctor',
          'message':
              'David, I want to understand your exercise pain better. When did it start?',
          'time': '1:00 PM',
          'type': 'received',
        },
        {
          'sender': 'David Clark',
          'message': 'It started during the leg exercises yesterday',
          'time': '1:05 PM',
          'type': 'sent',
        },
        {
          'sender': 'Doctor',
          'message':
              'Let\'s reduce the intensity. Focus on range of motion exercises only for now.',
          'time': '1:10 PM',
          'type': 'received',
        },
        {
          'sender': 'David Clark',
          'message': 'Pain increased during exercise.',
          'time': '2 days ago',
          'type': 'sent',
        },
        {
          'sender': 'Doctor',
          'message':
              'We\'ll investigate this in your next session. Take it easy!',
          'time': '2 days ago',
          'type': 'received',
        },
      ],
    };

    return conversations[name] ?? [];
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        'sender': 'You',
        'message': _messageController.text,
        'time': 'now',
        'type': 'sent',
      });
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 93, 146),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF6BA5CF),
              child: Text(
                widget.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isReceived = message['type'] == 'received';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: isReceived
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      if (isReceived) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF6BA5CF),
                          child: Text(
                            widget.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.65,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isReceived
                              ? Colors.grey[200]
                              : const Color(0xFF6BA5CF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          message['message'] ?? '',
                          style: TextStyle(
                            color: isReceived ? Colors.black : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!isReceived) const SizedBox(width: 8),
                    ],
                  ),
                );
              },
            ),
          ),
          // Message input
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
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
      ),
    );
  }
}
