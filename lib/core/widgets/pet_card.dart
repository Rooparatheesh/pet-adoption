import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pet_model.dart';
import '../../providers/favorite_provider.dart';
import '../constants/app_colors.dart';
import 'pet_image_widget.dart';

class PetCard extends ConsumerWidget {
  final PetModel pet;
  final VoidCallback onTap;

  const PetCard({
    Key? key,
    required this.pet,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext WidgetContext, WidgetRef ref) {
    final theme = Theme.of(WidgetContext);
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch favorites state
    final favoritesAsync = ref.watch(favoriteProvider);
    final isFav = favoritesAsync.value?.any((item) => item.id == pet.id) ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardBg : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section with Favorite Button Overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PetImageWidget(
                    imageUrl: pet.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  
                  // Favorite Button Overlay
                  Positioned(
                    top: 12,
                    right: 12,
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: GestureDetector(
                          onTap: () {
                            ref.read(favoriteProvider.notifier).toggleFavorite(pet);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.65),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? AppColors.primary : (isDark ? Colors.white : Colors.black87),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Gender Tag Overlay
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: (pet.gender.toLowerCase() == 'male'
                                    ? Colors.blue.shade800.withOpacity(0.4)
                                    : Colors.pink.shade800.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: (pet.gender.toLowerCase() == 'male'
                                  ? Colors.blue.shade300.withOpacity(0.3)
                                  : Colors.pink.shade300.withOpacity(0.3)),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                pet.gender.toLowerCase() == 'male' ? Icons.male : Icons.female,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                pet.gender,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Text Details Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        pet.ageText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet.breed,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          pet.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
