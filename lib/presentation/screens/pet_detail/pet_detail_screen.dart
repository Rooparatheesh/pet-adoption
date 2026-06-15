import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/pet_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/favorite_provider.dart';
import '../../../providers/adoption_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/avatar_helper.dart';
import '../../../core/widgets/pet_image_widget.dart';

class PetDetailScreen extends ConsumerStatefulWidget {
  final int petId;

  const PetDetailScreen({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  ConsumerState<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends ConsumerState<PetDetailScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showAdoptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adopt this Pet', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Let the owner know why you want to adopt this pet:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Introduce yourself and describe your home...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _submitRequest();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _submitRequest() async {
    final success = await ref.read(adoptionProvider.notifier).submitRequest(
          petId: widget.petId,
          message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adoption request submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      _messageController.clear();
    } else {
      final error = ref.read(adoptionProvider).error ?? 'Submission failed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext WidgetContext) {
    final petAsync = ref.watch(petDetailsProvider(widget.petId));
    final currentUser = ref.watch(authProvider).user;
    final favoritesAsync = ref.watch(favoriteProvider);
    final adoptionState = ref.watch(adoptionProvider);
    
    final isFav = favoritesAsync.value?.any((item) => item.id == widget.petId) ?? false;
    final alreadyRequested = adoptionState.sentRequests.any((req) => req.petId == widget.petId);

    final theme = Theme.of(WidgetContext);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: petAsync.when(
        data: (pet) {
          final isOwner = pet.ownerId == currentUser?.id;
          
          return Stack(
            children: [
              // Scrollable Details Content
              CustomScrollView(
                slivers: [
                  // Image Header
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(WidgetContext).size.height * 0.45,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    actions: [
                      CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.4),
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? AppColors.primary : Colors.white,
                          ),
                          onPressed: () => ref.read(favoriteProvider.notifier).toggleFavorite(pet),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: PetImageWidget(
                        imageUrl: pet.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Info Panel
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBackground : AppColors.background,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name & Age Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pet.name,
                                      style: theme.textTheme.displaySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pet.breed,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (pet.isAdopted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade500,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Adopted',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                )
                              else if (alreadyRequested)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.info,
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: const Text(
                                    'Requested',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ).animate().fade(duration: 400.ms),

                          const SizedBox(height: 20),

                          // Location Card
                          Row(
                            children: [
                              Icon(Icons.location_on, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                pet.location,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ).animate().fade(delay: 100.ms, duration: 400.ms),

                          const SizedBox(height: 24),

                          // Specs Grid (Age, Gender, Size)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSpecItem('Age', pet.ageText, Icons.calendar_today_outlined, isDark),
                              _buildSpecItem('Gender', pet.gender, pet.gender.toLowerCase() == 'male' ? Icons.male : Icons.female, isDark),
                              _buildSpecItem('Size', pet.size, Icons.straighten_outlined, isDark),
                            ],
                          ).animate().fade(delay: 150.ms, duration: 400.ms),

                          const SizedBox(height: 28),

                          // Lister/Owner Card
                          if (pet.owner != null) ...[
                            Text(
                              'Listed By',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCardBg : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  buildAvatar(pet.owner!.avatarUrl, radius: 24, iconSize: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pet.owner!.name,
                                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          pet.owner!.phone ?? 'No phone provided',
                                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fade(delay: 200.ms, duration: 400.ms),
                            const SizedBox(height: 28),
                          ],

                          // Description
                          Text(
                            'Story',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            pet.description ?? 'No description provided.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                            ),
                          ).animate().fade(delay: 250.ms, duration: 400.ms),

                          const SizedBox(height: 100), // Spacing for bottom button
                        ],
                      ),
                    ),
                  )
                ],
              ),

              // Bottom Action Button Overlay
              if (!isOwner && !pet.isAdopted && !alreadyRequested)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: CustomButton(
                    text: 'Adopt Me',
                    onPressed: _showAdoptionDialog,
                    isLoading: adoptionState.isLoading,
                  ).animate().fade(delay: 300.ms, duration: 400.ms),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text('Error loading pet: ${err.toString().replaceAll('Exception: ', '')}'),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value, IconData icon, bool isDark) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
