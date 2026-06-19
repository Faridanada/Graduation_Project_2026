import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/shared/profile_avatar.dart';

class ConversationScreen extends StatefulWidget {
  final String name;
  final String initials;
  final String? profileImage;
  final String message;
  final String? receiverId;

  const ConversationScreen({
    Key? key,
    required this.name,
    required this.initials,
    this.profileImage,
    required this.message,
    this.receiverId,
  }) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late TextEditingController _messageController;
  List<dynamic> messages = [];
  bool _isLoading = true;
  String? currentUserId;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    await _loadProfile();
    await _fetchMessages();
    setState(() => _isLoading = false);

    // Start polling every 3 seconds
    _pollTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _fetchMessages());
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getUserProfile();
    if (profile != null && mounted) {
      setState(() {
        currentUserId = profile['id'];
      });
    }
  }

  Future<void> _fetchMessages() async {
    if (widget.receiverId == null) return;

    final fetchedMessages = await ApiService.getChatHistory(widget.receiverId!);
    if (mounted) {
      setState(() {
        messages = fetchedMessages;
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || widget.receiverId == null) return;

    _messageController.clear();

    // Optimistic UI update (optional, but let's just wait for API for simplicity in this flow)
    final success = await ApiService.sendChatMessage(widget.receiverId!, text);
    if (success) {
      await _fetchMessages();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to send message'),
              backgroundColor: Colors.red),
        );
      }
    }
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
            ProfileAvatar(
              imageUrl: widget.profileImage,
              name: widget.name,
              radius: 18,
              backgroundColor: const Color(0xFF6BA5CF),
              textColor: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Text(
                            'No messages yet. Say hi!',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          reverse: false,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            final isSentByMe = msg['senderId'] == currentUserId;
                            
                            // Check if we need a date divider
                            bool showDateDivider = false;
                            if (index == 0) {
                              showDateDivider = true;
                            } else {
                              final prevMsg = messages[index - 1];
                              if (_formatDate(msg['createdAt']) != _formatDate(prevMsg['createdAt'])) {
                                showDateDivider = true;
                              }
                            }

                            final messageWidget = Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: isSentByMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  if (!isSentByMe) ...[
                                      ProfileAvatar(
                                        imageUrl: widget.profileImage,
                                        name: widget.name,
                                        radius: 16,
                                        backgroundColor: const Color(0xFF6BA5CF),
                                        textColor: Colors.white,
                                      ),
                                    const SizedBox(width: 8),
                                  ],
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.65,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSentByMe
                                          ? const Color(0xFF6BA5CF)
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isSentByMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg['messageText'] ?? '',
                                          style: TextStyle(
                                            color: isSentByMe
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _formatTime(msg['createdAt']),
                                                style: TextStyle(
                                                  color: isSentByMe
                                                      ? Colors.white70
                                                      : Colors.black45,
                                                  fontSize: 10,
                                                ),
                                              ),
                                              if (isSentByMe) ...[
                                                const SizedBox(width: 4),
                                                Icon(
                                                  msg['isRead'] == true ? Icons.done_all : Icons.check,
                                                  size: 14,
                                                  color: msg['isRead'] == true ? Colors.blue[200] : Colors.white70,
                                                ),
                                              ],
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSentByMe) const SizedBox(width: 8),
                                ],
                              ),
                            );

                            if (showDateDivider) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _formatDateFriendly(msg['createdAt']),
                                        style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  messageWidget,
                                ],
                              );
                            }
                            return messageWidget;
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
            ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _formatDateFriendly(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateToCheck = DateTime(dt.year, dt.month, dt.day);

      if (dateToCheck == today) {
        return 'Today';
      } else if (dateToCheck == yesterday) {
        return 'Yesterday';
      } else {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
      }
    } catch (_) {
      return '';
    }
  }
}

