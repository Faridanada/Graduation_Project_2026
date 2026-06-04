import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/doctor/management/WoundDetailScreen.dart';
import 'package:rehabilitation_app/ui/chats/ConversationScreen.dart';

class ManageWounds extends StatefulWidget {
  const ManageWounds({Key? key}) : super(key: key);

  @override
  State<ManageWounds> createState() => _ManageWoundsState();
}

class _ManageWoundsState extends State<ManageWounds> {
  List<dynamic> _wounds = [];
  bool _isLoading = true;
  String? _error;
  String _filter = 'all'; // 'all' | 'pending' | 'reviewed'

  int get _unreadCount =>
      _wounds.where((w) => w['status'] == 'pending review').length;

  List<dynamic> get _filtered {
    if (_filter == 'pending')
      return _wounds.where((w) => w['status'] == 'pending review').toList();
    if (_filter == 'reviewed')
      return _wounds
          .where((w) => w['status'] == 'reviewed' || w['status'] == 'healed')
          .toList();
    return _wounds;
  }

  @override
  void initState() {
    super.initState();
    _loadWounds();
  }

  Future<void> _loadWounds() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final wounds = await ApiService.getDoctorWounds();
      if (mounted)
        setState(() {
          _wounds = wounds;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = 'Failed to load wound reports.';
          _isLoading = false;
        });
    }
  }

  void _openWoundDetail(Map<dynamic, dynamic> wound) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WoundDetailScreen(
          wound: wound,
          onStatusChanged: _loadWounds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
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
            const Text(
              'Manage Wounds',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            if (_unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount new',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _loadWounds, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWounds,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── FILTER CHIPS ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
                        child: Row(
                          children: [
                            _filterChip('All', 'all'),
                            const SizedBox(width: 8),
                            _filterChip('Pending', 'pending'),
                            const SizedBox(width: 8),
                            _filterChip('Reviewed', 'reviewed'),
                          ],
                        ),
                      ),

                      // ── GRID ─────────────────────────────────────────
                      Expanded(
                        child: _filtered.isEmpty
                            ? const Center(
                                child: Text('No wounds in this category.',
                                    style: TextStyle(color: Colors.grey)))
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.60,
                                ),
                                itemCount: _filtered.length,
                                itemBuilder: (context, index) =>
                                    _buildWoundCard(_filtered[index]),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4A90E2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!selected)
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildWoundCard(Map<dynamic, dynamic> wound) {
    final isNew = wound['status'] == 'pending review';
    final isReviewed =
        wound['status'] == 'reviewed' || wound['status'] == 'healed';
    final imagePath = wound['imagePath'] as String?;
    final patientName = wound['patientName'] ?? 'Patient';
    final woundArea =
        wound['notes']?['woundArea'] ?? wound['woundArea'] ?? 'Unknown area';
    final painLevel = wound['notes']?['painLevel'] ?? wound['painLevel'] ?? '-';
    final createdAt = wound['createdAt'] as String? ?? '';
    final dateStr =
        createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt;

    return GestureDetector(
      onTap: () => _openWoundDetail(wound),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isNew ? const Color(0xFFE53935) : Colors.grey.shade200,
            width: isNew ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
          color: Colors.white,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── IMAGE SECTION ────────────────────────────
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imagePath != null
                      ? Image.network(
                          'http://10.0.2.2:5000$imagePath',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _noImageBox(woundArea),
                        )
                      : _noImageBox(woundArea),

                  // NEW badge
                  if (isNew)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('NEW',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),

            // ── INFO SECTION ─────────────────────────────
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(woundArea,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('Pain: $painLevel',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                    Text(dateStr,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500)),
                    const Spacer(),

                    // ── QUICK ACTION ROW ──────────────────
                    Row(
                      children: [
                        // Chat shortcut
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final names = patientName.split(' ');
                              final initials = names.length > 1
                                  ? '${names[0][0]}${names[1][0]}'
                                  : patientName[0];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ConversationScreen(
                                    name: patientName,
                                    initials: initials.toUpperCase(),
                                    message: woundArea,
                                  ),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline,
                                    size: 14, color: Color(0xFF4A90E2)),
                                SizedBox(width: 3),
                                Text('Chat',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF4A90E2),
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                        Container(
                            width: 1, height: 18, color: Colors.grey.shade200),
                        // Status indicator
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isReviewed
                                    ? Icons.check_circle
                                    : Icons.access_time_rounded,
                                size: 14,
                                color: isReviewed
                                    ? const Color(0xFF4CAF50)
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isReviewed ? 'Done' : 'Pending',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isReviewed
                                        ? const Color(0xFF4CAF50)
                                        : Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noImageBox(String label) {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.healing_rounded, color: Colors.grey.shade400, size: 36),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

