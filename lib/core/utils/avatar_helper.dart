import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

Widget buildAvatar(String? avatarUrl, {double radius = 24, double iconSize = 24}) {
  if (avatarUrl == null || avatarUrl.isEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      child: Icon(Icons.person, size: iconSize, color: AppColors.primary),
    );
  }

  if (avatarUrl.startsWith('http')) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(avatarUrl),
    );
  }

  // Otherwise, assume it is base64
  try {
    String cleanBase64 = avatarUrl;
    if (avatarUrl.contains(',')) {
      cleanBase64 = avatarUrl.split(',').last;
    }
    final bytes = base64Decode(cleanBase64.trim());
    return CircleAvatar(
      radius: radius,
      backgroundImage: MemoryImage(bytes),
    );
  } catch (e) {
    // Fallback
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      child: Icon(Icons.person, size: iconSize, color: AppColors.primary),
    );
  }
}
