import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/chats/ConversationScreen.dart';

class WoundDetailScreen extends StatefulWidget {
  final Map<dynamic, dynamic> wound;
  final VoidCallback? onStatusChanged;

  const WoundDetailScreen({
    Key? key,
    required this.wound,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  State<WoundDetailScreen> createState() => _WoundDetailScreenState();
}

class _WoundDetailScreenState extends State<WoundDetailScreen> {
  late Map<dynamic, dynamic> _wound;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _wound = Map.from(widget.wound);
  }

  bool get _isReviewed =>
      _wound['status'] == 'reviewed' || _wound['status'] == 'healed';

  String get _patientName => _wound['patientName'] ?? 'Patient';
  String get _woundArea =>
      _wound['notes']?['woundArea'] ?? _wound['woundArea'] ?? 'Unknown area';
  String get _painLevel =>
      _wound['notes']?['painLevel'] ?? _wound['painLevel'] ?? '-';
  String get _description =>
      _wound['notes']?['description'] ?? _wound['description'] ?? '';
  String get _notes =>
      _wound['notes']?['notes'] ?? '';
  String get _status => _wound['status'] ?? 'pending review';
  String get _dateStr {
    final raw = _wound['createdAt'] as String? ?? '';
    return raw.length >= 10 ? raw.substring(0, 10) : raw;
  }

  String? get _imageUrl {
    final path = _wound['imagePath'];
    if (path == null || path.toString().isEmpty) return null;
    if (path.toString().startsWith('http')) return path;
    return '${ApiService.baseUrl.replaceAll('/api', '')}/$path';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'reviewed': return const Color(0xFF4CAF50);
      case 'healed':   return const Color(0xFF2196F3);
      default:         return const Color(0xFFFF9800);
    }
  }

  Future<void> _markAs(String status) async {
    setState(() => _isUpdating = true);
    final woundId = _wound['id'] as String;
    final patientId = _wound['patientId'] as String? ?? '';
    final success = await ApiService.updateWoundStatus(woundId, status, patientId);
    if (!mounted) return;
    setState(() {
      _isUpdating = false;
      if (success) _wound['status'] = status;
    });
    if (success) {
      widget.onStatusChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wound marked as $status'),
          backgroundColor: _statusColor(status),
        ),
      );
    }
  }

  void _openFullImage(BuildContext context) {
    final url = _imageUrl;
    if (url == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ZoomableImageScreen(imageUrl: url, title: '$_patientName • $_woundArea'),
      ),
    );
  }

  void _openChat() {
    final names = _patientName.split(' ');
    final initials = names.length > 1 ? '${names[0][0]}${names[1][0]}' : _patientName[0];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          name: _patientName,
          initials: initials.toUpperCase(),
          message: 'Regarding wound: $_woundArea',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () { if (Navigator.canPop(context)) Navigator.pop(context); },
        ),
        title: const Text(
          'Wound Report',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ─── PATIENT INFO ───────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF95B8D1),
                  child: Text(
                    _patientName.isNotEmpty ? _patientName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_patientName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Submitted $_dateStr',
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(_status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(_status),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── WOUND IMAGE ────────────────────────────────
            if (_imageUrl != null) ...[
              GestureDetector(
                onTap: () => _openFullImage(context),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        _imageUrl!,
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _noImagePlaceholder(),
                      ),
                    ),
                    // Tap-to-zoom hint
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.zoom_in, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('Tap to zoom', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else
              _noImagePlaceholder(),

            // ─── DETAILS GRID ───────────────────────────────
            Row(
              children: [
                Expanded(child: _infoCard('Wound Area', _woundArea, Icons.location_on_rounded, const Color(0xFF4A90E2))),
                const SizedBox(width: 14),
                Expanded(child: _infoCard('Pain Level', _painLevel, Icons.thermostat_rounded, _painColor(_painLevel))),
              ],
            ),

            if (_description.isNotEmpty) ...[
              const SizedBox(height: 16),
              _textCard('Description', _description, Icons.description_rounded),
            ],

            if (_notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _textCard('Patient Notes', _notes, Icons.note_alt_rounded),
            ],

            const SizedBox(height: 28),

            // ─── ACTION BUTTONS ─────────────────────────────
            if (!_isReviewed) ...[
              _actionButton(
                label: 'Mark as Reviewed',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF4CAF50),
                onTap: _isUpdating ? null : () => _markAs('reviewed'),
                isLoading: _isUpdating,
              ),
              const SizedBox(height: 12),
              _actionButton(
                label: 'Mark as Healed',
                icon: Icons.healing_rounded,
                color: const Color(0xFF2196F3),
                onTap: _isUpdating ? null : () => _markAs('healed'),
                isLoading: false,
              ),
              const SizedBox(height: 12),
            ],

            _actionButton(
              label: 'Chat with $_patientName',
              icon: Icons.chat_bubble_outline_rounded,
              color: const Color(0xFF95B8D1),
              onTap: _openChat,
              isLoading: false,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _noImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_rounded, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text('No image uploaded', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _textCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: const Color(0xFF4A90E2), size: 18), const SizedBox(width: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4A90E2)))]),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF1C1F2E))),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required bool isLoading,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade200 : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: onTap == null ? Colors.transparent : color, width: 1.5),
        ),
        child: isLoading
            ? Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: color, strokeWidth: 2)))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: onTap == null ? Colors.grey : color, size: 20),
                  const SizedBox(width: 10),
                  Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: onTap == null ? Colors.grey : color)),
                ],
              ),
      ),
    );
  }

  Color _painColor(String pain) {
    switch (pain.toLowerCase()) {
      case 'low':    return Colors.teal;
      case 'high':   return Colors.red;
      default:       return Colors.orange;
    }
  }
}

// ─── ZOOMABLE FULL SCREEN IMAGE ───────────────────────────────────────────────
class _ZoomableImageScreen extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _ZoomableImageScreen({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.8,
          maxScale: 6.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Text('Failed to load image', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

