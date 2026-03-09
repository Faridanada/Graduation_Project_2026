import 'package:flutter/material.dart';

class ActivePatientsPage extends StatefulWidget {
  const ActivePatientsPage({Key? key}) : super(key: key);

  @override
  State<ActivePatientsPage> createState() => _ActivePatientsPageState();
}

class _ActivePatientsPageState extends State<ActivePatientsPage> {
  final List<Map<String, dynamic>> activePatients = [
    {
      'name': 'John Doe',
      'age': '21',
      'phone': '555-0101',
      'injuryType': 'Knee Fracture',
    },
    {
      'name': 'Harry Black',
      'age': '25',
      'phone': '555-0102',
      'injuryType': 'Shoulder Dislocation',
    },
    {
      'name': 'Jack Doe',
      'age': '43',
      'phone': '555-0103',
      'injuryType': 'Back Strain',
    },
    {
      'name': 'Alice Smith',
      'age': '31',
      'phone': '555-0104',
      'injuryType': 'Ankle Sprain',
    },
    {
      'name': 'Emma Jones',
      'age': '28',
      'phone': '555-0105',
      'injuryType': 'Wrist Fracture',
    },
    {
      'name': 'Michael Brown',
      'age': '35',
      'phone': '555-0106',
      'injuryType': 'Hip Replacement',
    },
    {
      'name': 'Sarah Wilson',
      'age': '42',
      'phone': '555-0107',
      'injuryType': 'Knee Ligament Tear',
    },
    {
      'name': 'David Lee',
      'age': '29',
      'phone': '555-0108',
      'injuryType': 'Elbow Fracture',
    },
    {
      'name': 'Jessica Martinez',
      'age': '26',
      'phone': '555-0109',
      'injuryType': 'Rotator Cuff Tear',
    },
    {
      'name': 'Chris Anderson',
      'age': '38',
      'phone': '555-0110',
      'injuryType': 'Lower Back Pain',
    },
    {
      'name': 'Lauren Taylor',
      'age': '32',
      'phone': '555-0111',
      'injuryType': 'Knee Meniscus Tear',
    },
    {
      'name': 'James White',
      'age': '45',
      'phone': '555-0112',
      'injuryType': 'Spinal Cord Injury',
    },
    {
      'name': 'Megan Harris',
      'age': '24',
      'phone': '555-0113',
      'injuryType': 'Ankle Fracture',
    },
    {
      'name': 'Ryan Davis',
      'age': '39',
      'phone': '555-0114',
      'injuryType': 'Shoulder Strain',
    },
    {
      'name': 'Sophie Clark',
      'age': '27',
      'phone': '555-0115',
      'injuryType': 'Knee Arthritis',
    },
    {
      'name': 'Daniel Miller',
      'age': '44',
      'phone': '555-0116',
      'injuryType': 'Hip Strain',
    },
    {
      'name': 'Olivia Rodriguez',
      'age': '30',
      'phone': '555-0117',
      'injuryType': 'Wrist Tendonitis',
    },
    {
      'name': 'Tyler Jackson',
      'age': '25',
      'phone': '555-0118',
      'injuryType': 'Foot Fracture',
    },
    {
      'name': 'Ava Martinez',
      'age': '33',
      'phone': '555-0119',
      'injuryType': 'Knee Bursitis',
    },
    {
      'name': 'Nathan Garcia',
      'age': '41',
      'phone': '555-0120',
      'injuryType': 'Back Disc Herniation',
    },
    {
      'name': 'Isabella Lopez',
      'age': '28',
      'phone': '555-0121',
      'injuryType': 'Ankle Instability',
    },
    {
      'name': 'Mason Thomas',
      'age': '36',
      'phone': '555-0122',
      'injuryType': 'Shoulder Impingement',
    },
    {
      'name': 'Charlotte Lee',
      'age': '29',
      'phone': '555-0123',
      'injuryType': 'Knee Ligament Sprain',
    },
    {
      'name': 'Ethan Walker',
      'age': '40',
      'phone': '555-0124',
      'injuryType': 'Lumbar Strain',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF95B8D1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Active Patients',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Total Patients: ${activePatients.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: activePatients.length,
                itemBuilder: (context, index) {
                  return _buildPatientCard(activePatients[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF95B8D1).withOpacity(0.6),
                  child: Text(
                    patient['name'].substring(0, 1),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Age: ${patient['age']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Phone:',
                    patient['phone'],
                    Icons.phone,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Injury Type:',
                    patient['injuryType'],
                    Icons.medical_services,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF95B8D1)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}
