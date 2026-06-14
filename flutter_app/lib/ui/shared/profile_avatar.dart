import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? fallbackIcon;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.backgroundColor,
    this.textColor,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      final url = imageUrl!.startsWith('http')
          ? imageUrl!
          : '${ApiService.baseUrl.replaceAll('/api', '')}/$imageUrl';
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[200],
        backgroundImage: NetworkImage(url),
      );
    }

    // Fallback to name initial or icon
    if (fallbackIcon != null || (name == null || name!.isEmpty)) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[200],
        child: Icon(
          fallbackIcon ?? Icons.person,
          size: radius * 1.2,
          color: textColor ?? Colors.grey[600],
        ),
      );
    }

    final initial = name![0].toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          color: textColor ?? Colors.black54,
        ),
      ),
    );
  }
}
