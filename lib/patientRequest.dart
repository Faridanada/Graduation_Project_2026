import 'package:flutter/material.dart';

class PatientRequest extends StatefulWidget {
  const PatientRequest({Key? key}) : super(key: key);

  @override
  State<PatientRequest> createState() => _PatientRequestState();
}

class _PatientRequestState extends State<PatientRequest> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> requests = [
    {
      'name': 'John Doe',
      'type': 'Appointment Request',
      'message': 'Requesting appointment for next Tuesday at 2 PM',
      'timestamp': '10 mins ago',
      'status': 'pending',
    },
    {
      'name': 'Alice Smith',
      'type': 'Exercise Question',
      'message':
          'Is it normal to feel slight discomfort during the knee exercises?',
      'timestamp': '2 hours ago',
      'status': 'pending',
    },
    {
      'name': 'Mark Lee',
      'type': 'Prescription Refill',
      'message': 'Need prescription refill for pain medication',
      'timestamp': '1 day ago',
      'status': 'completed',
    },
    {
      'name': 'Emma Brown',
      'type': 'Wound Check',
      'message': 'I uploaded new wound photos for review.',
      'timestamp': '3 hours ago',
      'status': 'pending',
    },
    {
      'name': 'Michael Johnson',
      'type': 'Extra Exercise Session',
      'message':
          'Can we add another session this week? Feeling good with progress.',
      'timestamp': '5 hours ago',
      'status': 'pending',
    },
    {
      'name': 'Sarah Williams',
      'type': 'Change Appointment Time',
      'message':
          'Can we move tomorrow\'s session to afternoon instead of morning?',
      'timestamp': '12 hours ago',
      'status': 'completed',
    },
    {
      'name': 'David Khan',
      'type': 'Appointment Request',
      'message':
          'Would like to schedule an appointment for next Friday at 10 AM',
      'timestamp': '30 mins ago',
      'status': 'pending',
    },
    {
      'name': 'Jennifer Lee',
      'type': 'Exercise Question',
      'message':
          'Is it safe to continue with the current intensity or should I reduce it?',
      'timestamp': '45 mins ago',
      'status': 'pending',
    },
  ];

  List<Map<String, dynamic>> get filteredRequests {
    if (selectedFilter == 'All') {
      return requests;
    } else if (selectedFilter == 'Pending') {
      return requests.where((req) => req['status'] == 'pending').toList();
    } else {
      return requests.where((req) => req['status'] == 'completed').toList();
    }
  }

  int get pendingCount =>
      requests.where((req) => req['status'] == 'pending').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterTabs(),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildRequestCard(filteredRequests[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF95B8D1),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        'Patient Requests',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterButton('All', selectedFilter == 'All'),
          const SizedBox(width: 12),
          _buildFilterButton('Pending', selectedFilter == 'Pending',
              badge: pendingCount),
          const SizedBox(width: 12),
          _buildFilterButton('Completed', selectedFilter == 'Completed'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, bool isSelected, {int? badge}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5798C6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
                fontFamily: 'Poppins',
              ),
            ),
            if (badge != null && badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 152, 0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final isCompleted = request['status'] == 'completed';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar, name, type, and timestamp
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with first letter of name
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF5798C6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    request['name'][0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5798C6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name, Type, and Timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request['type'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5798C6),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                request['timestamp'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Message
          Text(
            request['message'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons or Completed Status
          if (isCompleted)
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: const Color.fromARGB(255, 99, 197, 150),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 99, 197, 150),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Responded to ${request['name']}')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5798C6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Respond',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Dismissed ${request['name']}\'s request')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                  ),
                  child: Text(
                    'Dismiss',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF95B8D1),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
