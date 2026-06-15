import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String name;
  final String iconKey;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.name,
    required this.iconKey,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  IconData _getIcon(String key) {
    switch (key.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets_outlined;
      case 'bird':
        return Icons.flutter_dash;
      case 'rabbit':
        return Icons.cruelty_free;
      case 'fish':
        return Icons.sailing; // Simple fish-like sailing/ocean representation or custom icon
      default:
        return Icons.pets;
    }
  }

  @override
  Widget build(BuildContext WidgetContext) {
    final theme = Theme.of(WidgetContext);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected
              ? null
              : (isDark ? AppColors.darkCardBg : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(iconKey),
              size: 20,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey.shade300 : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
