import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shimmer_loading.dart';

class PetImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const PetImageWidget({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        child: const Icon(Icons.pets, size: 50, color: Colors.grey),
      );
    }

    if (imageUrl!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => const ShimmerLoading.rectangular(height: double.infinity),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 50, color: Colors.grey),
        ),
      );
    }

    // Otherwise, assume it is base64 encoded
    try {
      String cleanBase64 = imageUrl!;
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',').last;
      }
      final bytes = base64Decode(cleanBase64.trim());
      return Image.memory(
        bytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 50, color: Colors.grey),
        ),
      );
    } catch (e) {
      return Container(
        width: width,
        height: height,
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        child: const Icon(Icons.pets, size: 50, color: Colors.grey),
      );
    }
  }
}
