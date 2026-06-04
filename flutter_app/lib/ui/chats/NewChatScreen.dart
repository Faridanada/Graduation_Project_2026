import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/chats/ConversationScreen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({Key? key}) : super(key: key);

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  bool _isLoading = true;
  List<dynamic> _users = [];
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final profile = await ApiService.getUserProfile();
      if (profile != null) {
        _userRole = profile['role'] ?? '';
      }

      List<dynamic> fetchedUsers = [];
      if (_userRole == 'doctor') {
        fetchedUsers = await ApiService.getDoctorPatients();
      } else if (_userRole == 'patient') {
        final myDoctor = await ApiService.getMyDoctor();
        if (myDoctor != null) {
          fetchedUsers = [myDoctor];
        }
      } else {
        // Fallback or handle other roles
      }

      if (mounted) {
        setState(() {
          _users = fetchedUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load users')),
        );
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text(
          'New Chat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () { if (Navigator.canPop(context)) Navigator.pop(context); },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(
                  child: Text(
                    'No contacts found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    String name = '';
                    String id = '';
                    String subtitle = '';

                    if (_userRole == 'doctor') {
                      // patient info
                      id = user['_id'] ?? user['id'] ?? '';
                      name = user['name'] ?? 'Unknown Patient';
                      subtitle = user['email'] ?? '';
                    } else {
                      // doctor info
                      id = user['_id'] ?? user['id'] ?? '';
                      name = user['name'] ?? 'Unknown Doctor';
                      if (!name.toLowerCase().startsWith('dr.')) {
                        name = 'Dr. $name';
                      }
                      subtitle = user['specialization'] ?? user['email'] ?? '';
                    }

                    final initials = _getInitials(name.replaceAll('Dr. ', ''));

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF6BA5CF),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(subtitle),
                        onTap: () {
                          if (id.isNotEmpty) {
                            // Pop the New Chat screen
                            if (Navigator.canPop(context)) Navigator.pop(context);
                            // Push the ConversationScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConversationScreen(
                                  name: name,
                                  initials: initials,
                                  message: '',
                                  receiverId: id,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

