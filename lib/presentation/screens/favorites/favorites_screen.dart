import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/favorite_provider.dart';
import '../../../core/widgets/pet_card.dart';
import '../../../core/widgets/shimmer_loading.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext WidgetContext, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteProvider);
    final theme = Theme.of(WidgetContext);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ).animate().scale(duration: 400.ms),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse pets and tap the heart icon to add them here.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final pet = favorites[index];
              return PetCard(
                pet: pet,
                onTap: () => context.push('/pet/${pet.id}'),
              ).animate().fade(duration: 300.ms).scale(duration: 300.ms);
            },
          );
        },
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: 4,
          itemBuilder: (context, index) => const ShimmerLoading.rectangular(height: 200),
        ),
        error: (err, stack) => Center(
          child: Text('Error loading favorites: ${err.toString().replaceAll('Exception: ', '')}'),
        ),
      ),
    );
  }
}
