import 'package:flutter/material.dart';

class LiveSessionScreen extends StatelessWidget {
  const LiveSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: Column(
          children: [
            /// TOP BAR
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Live Session",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const Icon(Icons.settings)
                ],
              ),
            ),

            /// TIMER
            const Text(
              "12:39",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// IMAGE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61",
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// MESSAGE
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text("Great job! Keep going"),
            ),

            const Spacer(),

            /// BUTTON
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: const Color(0xFF4A90E2),
                ),
                onPressed: () {},
                child: const Text("Finish Session"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
// TODO Implement this library.
