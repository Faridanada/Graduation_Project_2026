import 'dart:ui';
import 'package:flutter/material.dart';

import 'appointment_confirmed_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime currentMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();

  String selectedTime = "10:00 AM";

  final ScrollController _timeScroll = ScrollController();

  final List<String> todaySlots = [
    "4:30 PM",
    "9:00 AM",
    "10:00 AM",
    "11:30 AM",
    "14:00",
  ];

  @override
  void initState() {
    super.initState();

    /// 🔹 Auto scroll to selected slot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = todaySlots.indexOf(selectedTime);
      if (index != -1) {
        _timeScroll.animateTo(
          index * 90,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// 🔹 Generate calendar days
  List<int> getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final weekday = firstDay.weekday % 7;
    final totalDays = DateTime(month.year, month.month + 1, 0).day;

    return [
      ...List.filled(weekday, 0),
      ...List.generate(totalDays, (i) => i + 1),
    ];
  }

  /// 🔹 Glass container
  Widget glassBox(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = getDaysInMonth(currentMonth);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// 🔹 RECOMMENDED
              glassBox(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "✨ Recommended for you",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Thursday – 10:00 AM",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Based on your schedule",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AppointmentConfirmedScreen(
                                  date: "Thursday, April 17",
                                  time: "10:00 AM",
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Confirm Instantly",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 TIME SLOTS
              glassBox(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pick a time that works for you",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text("Today"),
                        const SizedBox(width: 10),

                        /// 🔥 ONE LINE SCROLL
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _timeScroll,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: todaySlots.map((slot) {
                                final isSelected = slot == selectedTime;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedTime = slot;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      slot,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Text("Fri   9:00 AM"),
                        SizedBox(width: 8),
                        Text(
                          "Last slot",
                          style: TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 CALENDAR
              glassBox(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Choose another date",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () {
                                setState(() {
                                  currentMonth = DateTime(
                                    currentMonth.year,
                                    currentMonth.month - 1,
                                  );
                                });
                              },
                            ),
                            Text("${currentMonth.year}-${currentMonth.month}"),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                setState(() {
                                  currentMonth = DateTime(
                                    currentMonth.year,
                                    currentMonth.month + 1,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// WEEK DAYS
                    Row(
                      children:
                          ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                              .map(
                                (e) => Expanded(
                                  child: Center(
                                    child: Text(
                                      e,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),

                    const SizedBox(height: 10),

                    /// GRID
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: days.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (_, i) {
                        final day = days[i];
                        if (day == 0) return const SizedBox();

                        final isSelected = day == selectedDate.day;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = DateTime(
                                currentMonth.year,
                                currentMonth.month,
                                day,
                              );
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$day",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                /// 🔹 DOT
                                Container(
                                  height: 5,
                                  width: 5,
                                  decoration: BoxDecoration(
                                    color: day % 3 == 0
                                        ? Colors.green
                                        : day % 4 == 0
                                            ? Colors.orange
                                            : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    /// LEGEND
                    const Row(
                      children: [
                        Icon(Icons.circle, size: 10, color: Colors.green),
                        Text(" Available"),
                        SizedBox(width: 10),
                        Icon(Icons.circle, size: 10, color: Colors.orange),
                        Text(" Limited"),
                        SizedBox(width: 10),
                        Icon(Icons.circle, size: 10, color: Colors.red),
                        Text(" Full"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 SESSION
              glassBox(
                Row(
                  children: const [
                    CircleAvatar(radius: 20, backgroundColor: Colors.purple),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "In-Clinic Session",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Thu, Apr 11 - 10:00 AM",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // 🔵 BLUE
                    foregroundColor: Colors.white, // ⚪ TEXT
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(), // 💊 rounded
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppointmentConfirmedScreen(
                          date:
                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          time: selectedTime,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Confirm Appointment",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
