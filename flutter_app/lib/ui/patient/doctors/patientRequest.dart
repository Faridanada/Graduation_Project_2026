import 'package:flutter/material.dart';
import 'package:rehabilitation_app/ui/doctor/home/DoctorHome.dart';
import 'package:rehabilitation_app/ui/chats/Chats.dart';
import 'package:rehabilitation_app/ui/doctor/profile/DoctorProfile.dart';
import 'package:rehabilitation_app/services/api_service.dart';

class PatientRequest extends StatefulWidget {
  const PatientRequest({Key? key}) : super(key: key);

  @override
  State<PatientRequest> createState() => _PatientRequestState();
}

class _PatientRequestState extends State<PatientRequest> {
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;
  int _selectedNavIndex = 0; // Pushed from Home dashboard context

  void _onNavTap(int index) {
    if (index == 0) {
      // Navigate to Home dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DoctorHome()),
      );
    } else if (index == 1) {
      // Navigate to Chats
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Chats()),
      );
    } else if (index == 2) {
      // Navigate to Profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DoctorProfile()),
      );
    }

    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => isLoading = true);
    try {
      final fetched = await ApiService.getDoctorRequests();
      final parsed = List<Map<String, dynamic>>.from(fetched);

      setState(() {
        requests = parsed;
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        requests = [];
        isLoading = false;
      });
    }
  }

  Future<void> _handleResponse(
      String requestId, bool accept, String doctorName) async {
    // Optimistic UI update or loading spinner can go here
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await ApiService.respondToDoctorRequest(requestId, accept);

    if (context.mounted) if (Navigator.canPop(context)) Navigator.pop(context); // hide loading

    if (success) {
      setState(() {
        requests.removeWhere((r) => (r['id'] ?? '').toString() == requestId);
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accept
                ? 'Accepted $doctorName\'s request'
                : 'Dismissed $doctorName\'s request'),
            backgroundColor: accept ? Colors.green : Colors.grey,
          ),
        );
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update request status.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get filteredRequests {
    return requests;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredRequests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "No requests found",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
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
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
      ),
      title: const Text(
        'Patient Requests',
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
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
            color: Colors.black.withValues(alpha: 0.05),
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
                  color: const Color(0xFF5798C6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    (request['patientName'] ?? 'U')[0].toUpperCase(),
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
                      request['patientName'] ?? 'Unknown Patient',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Connection Request',
                      style: TextStyle(
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
                (request['createdAt'] ?? '').split('T')[0],
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
          const Text(
            'Patient is requesting to connect with you.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _handleResponse(request['id'] ?? 'req_1', true,
                        request['patientName'] ?? 'Unknown');
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
                  _handleResponse(request['id'] ?? 'req_1', false,
                      request['patientName'] ?? 'Unknown');
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: const Text(
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
      currentIndex: _selectedNavIndex,
      onTap: _onNavTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.grey,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(color: Colors.grey),
      unselectedLabelStyle: const TextStyle(color: Colors.grey),
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
