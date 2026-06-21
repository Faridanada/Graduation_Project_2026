import 'package:flutter/material.dart';

import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/shared/NotificationsPage.dart';
import 'package:rehabilitation_app/ui/shared/notification_bell.dart';
import 'package:rehabilitation_app/ui/settings/SettingsPage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedTab = 0;
  bool isLoading = true;

  List<Map<String, dynamic>> sessions = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final data = await ApiService.getPatientExercises();
      List<Map<String, dynamic>> mapped = data.map((e) {
        // Map completions to status logic
        int total = e['repsTotal'] ?? 10;
        int completed = e['repsCompleted'] ?? 0;
        
        String status = "Stable";
        if (completed >= total) status = "Improved";
        else if (completed > 0) status = "Needs Work";
        else status = "Needs Work";

        String dateStr = e['dateAssigned'] ?? e['createdAt'] ?? '';
        String shortDate = dateStr.length > 10 ? dateStr.substring(0, 10) : dateStr;

        return {
          "date": shortDate,
          "title": e['title'] ?? 'Exercise',
          "duration": "${e['estimatedTimeMin'] ?? 10} min",
          "status": status,
        };
      }).toList();

      if (mounted) {
        setState(() {
          sessions = mapped;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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
                  IconButton(
                    onPressed: () { if (Navigator.canPop(context)) Navigator.pop(context); },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  const Text(
                    "History",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const NotificationBell(),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
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
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredSessions.isEmpty
                        ? const Center(child: Text("No history available yet", style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
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

