import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedTab = 0;

  final List<Map<String, dynamic>> sessions = [
    {
      "date": "10 Feb 2026",
      "title": "Knee Flexion",
      "duration": "12 min",
      "status": "Improved",
    },
    {
      "date": "08 Feb 2026",
      "title": "Balance Training",
      "duration": "15 min",
      "status": "Stable",
    },
    {
      "date": "05 Feb 2026",
      "title": "Shoulder Rotation",
      "duration": "10 min",
      "status": "Needs Work",
    },
    {
      "date": "02 Feb 2026",
      "title": "Stretching Routine",
      "duration": "18 min",
      "status": "Improved",
    },
    {
      "date": "02 Feb 2026",
      "title": "Stretching Routine",
      "duration": "18 min",
      "status": "Improved",
    },
  ];

  List<Map<String, dynamic>> get filteredSessions {
    if (selectedTab == 1) {
      return sessions.where((e) => e["status"] == "Improved").toList();
    } else if (selectedTab == 2) {
      return sessions.where((e) => e["status"] == "Needs Work").toList();
    }
    return sessions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  const Text(
                    "History",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      const Icon(Icons.notifications_none),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.settings),
                ],
              ),

              const SizedBox(height: 20),

              /// SEGMENTED CONTROL
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _tabItem("All", 0),
                    _tabItem("Improved", 1),
                    _tabItem("Needs Work", 2),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// TITLE
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Past Sessions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

              /// LIST
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSessions.length,
                  itemBuilder: (context, index) {
                    final item = filteredSessions[index];
                    return _sessionCard(item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  /// 🔘 TAB ITEM
  Widget _tabItem(String title, int index) {
    final isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 📦 SESSION CARD
  Widget _sessionCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// DATE + STATUS
          Row(
            children: [
              Text(
                item["date"],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              _statusChip(item["status"]),
            ],
          ),

          const SizedBox(height: 8),

          /// TITLE
          Text(
            item["title"],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          /// DURATION
          Text(item["duration"], style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// 🎯 STATUS CHIP
  Widget _statusChip(String status) {
    Color color;

    switch (status) {
      case "Improved":
        color = Colors.blue;
        break;
      case "Needs Work":
        color = Colors.red;
        break;
      case "Stable":
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
