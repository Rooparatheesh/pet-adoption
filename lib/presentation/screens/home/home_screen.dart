import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/pet_provider.dart';
import '../../../core/widgets/pet_card.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/avatar_helper.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext WidgetContext) {
    final authState = ref.watch(authProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final petsAsync = ref.watch(petListProvider);
    
    final theme = Theme.of(WidgetContext);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(categoryListProvider);
            ref.invalidate(petListProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Welcome Header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello,',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            authState.user?.name ?? 'Guest',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      buildAvatar(authState.user?.avatarUrl, radius: 24, iconSize: 24),
                    ],
                  ).animate().fade(duration: 400.ms),
                ),
              ),

              // Search Bar
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverToBoxAdapter(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      ref.read(searchQueryProvider.notifier).state = val;
                    },
                    decoration: InputDecoration(
                      hintText: 'Search breed, name, location...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state = '';
                              },
                            )
                          : null,
                    ),
                  ).animate().fade(delay: 100.ms, duration: 400.ms),
                ),
              ),

              // Categories Header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Categories',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ).animate().fade(delay: 150.ms, duration: 400.ms),
                ),
              ),

              // Categories List
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: categoriesAsync.when(
                    data: (categories) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: categories.length + 1, // +1 for "All"
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return CategoryChip(
                            name: 'All',
                            iconKey: 'pets',
                            isSelected: selectedCategoryId == null,
                            onTap: () {
                              ref.read(selectedCategoryIdProvider.notifier).state = null;
                            },
                          );
                        }
                        final cat = categories[index - 1];
                        return CategoryChip(
                          name: cat.name,
                          iconKey: cat.icon ?? 'pets',
                          isSelected: selectedCategoryId == cat.id,
                          onTap: () {
                            ref.read(selectedCategoryIdProvider.notifier).state = cat.id;
                          },
                        );
                      },
                    ),
                    loading: () => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 5,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: const ShimmerLoading.rectangular(
                          width: 80,
                          height: 40,
                        ),
                      ),
                    ),
                    error: (err, stack) => const Center(
                      child: Text('Error loading categories'),
                    ),
                  ),
                ).animate().fade(delay: 200.ms, duration: 400.ms),
              ),

              // Pets Header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Adopt a Friend',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ).animate().fade(delay: 250.ms, duration: 400.ms),
                ),
              ),

              // Pets Grid List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: petsAsync.when(
                  data: (pets) {
                    if (pets.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No paw-fect matches found.',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final pet = pets[index];
                          return PetCard(
                            pet: pet,
                            onTap: () => context.push('/pet/${pet.id}'),
                          ).animate().fade(duration: 300.ms).scale(duration: 300.ms);
                        },
                        childCount: pets.length,
                      ),
                    );
                  },
                  loading: () => SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const ShimmerLoading.rectangular(height: 200),
                      childCount: 4,
                    ),
                  ),
                  error: (err, stack) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('Error loading pets: ${err.toString().replaceAll('Exception: ', '')}'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: authState.status == AuthStatus.authenticated
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/add-pet'),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text(
                'List a Pet',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0)
          : null,
    );
  }
}
