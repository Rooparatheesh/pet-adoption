import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/pet_provider.dart';
import '../../../providers/adoption_provider.dart';
import '../../../providers/service_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/pet_image_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../data/models/pet_model.dart';
import '../../../data/models/adoption_request_model.dart';
import '../../../core/utils/avatar_helper.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPetsAsync = ref.watch(myPetsProvider);
    final adoptionState = ref.watch(adoptionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Build a map: petId → list of received requests for quick lookup
    final Map<int, List<AdoptionRequestModel>> requestsByPet = {};
    for (final req in adoptionState.receivedRequests) {
      requestsByPet.putIfAbsent(req.petId, () => []).add(req);
    }

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxScrolled) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 140,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Listings',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    myPetsAsync.when(
                      data: (pets) => Text(
                        '${pets.length} pet${pets.length == 1 ? '' : 's'} listed',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [AppColors.darkSurface, AppColors.darkCardBg]
                          : [const Color(0xFFFFF3EF), Colors.white],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.07),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 30,
                        top: 10,
                        child: Icon(
                          Icons.pets,
                          size: 60,
                          color: AppColors.primary.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                  tooltip: 'Add New Listing',
                  onPressed: () => context.push('/add-pet'),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myPetsProvider);
              ref.read(adoptionProvider.notifier).loadRequests();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppColors.primary,
            child: myPetsAsync.when(
              data: (pets) {
                if (pets.isEmpty) {
                  return _EmptyListingsView(onAddTap: () => context.push('/add-pet'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    final petRequests = requestsByPet[pet.id] ?? [];
                    return _MyListingCard(
                      pet: pet,
                      index: index,
                      requests: petRequests,
                      onDeleted: () => ref.invalidate(myPetsProvider),
                      onViewRequests: () => _showRequestsBottomSheet(
                        context, ref, pet, petRequests,
                      ),
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: 4,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ShimmerLoading.rectangular(height: 130),
                ),
              ),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      err.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(myPetsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-pet'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          'List a Pet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
    );
  }

  // ── Bottom Sheet showing requests for a pet ──────────────────────────────
  void _showRequestsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    PetModel pet,
    List<AdoptionRequestModel> requests,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RequestsBottomSheet(pet: pet, requests: requests, ref: ref),
    );
  }
}

// ── Requests Bottom Sheet ─────────────────────────────────────────────────────

class _RequestsBottomSheet extends ConsumerStatefulWidget {
  final PetModel pet;
  final List<AdoptionRequestModel> requests;
  final WidgetRef ref;

  const _RequestsBottomSheet({
    required this.pet,
    required this.requests,
    required this.ref,
  });

  @override
  ConsumerState<_RequestsBottomSheet> createState() => _RequestsBottomSheetState();
}

class _RequestsBottomSheetState extends ConsumerState<_RequestsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final adoptionState = ref.watch(adoptionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get updated requests from provider
    final updatedRequests = adoptionState.receivedRequests
        .where((r) => r.petId == widget.pet.id)
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 52, height: 52,
                      child: PetImageWidget(imageUrl: widget.pet.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.pet.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'Outfit',
                          ),
                        ),
                        Text(
                          '${updatedRequests.length} adoption request${updatedRequests.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),

            // Requests List
            Expanded(
              child: updatedRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 52, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No adoption requests yet',
                            style: TextStyle(color: Colors.grey.shade500, fontFamily: 'Outfit'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: updatedRequests.length,
                      itemBuilder: (context, index) {
                        final req = updatedRequests[index];
                        return _RequesterCard(request: req, isDark: isDark, theme: theme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Requester Card ────────────────────────────────────────────────────────────

class _RequesterCard extends ConsumerWidget {
  final AdoptionRequestModel request;
  final bool isDark;
  final ThemeData theme;

  const _RequesterCard({required this.request, required this.isDark, required this.theme});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return AppColors.success;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = request.status.toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Requester info row
          Row(
            children: [
              buildAvatar(request.requester?.avatarUrl, radius: 22, iconSize: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requester?.name ?? 'Unknown',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (request.requester?.phone != null)
                      Text(
                        request.requester!.phone!,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                  ],
                ),
              ),
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor(request.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _statusColor(request.status).withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(request.status), size: 13, color: _statusColor(request.status)),
                    const SizedBox(width: 4),
                    Text(
                      request.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _statusColor(request.status),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Message
          if (request.message != null && request.message!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
              child: Text(
                '"${request.message}"',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ],

          // Action buttons (only for pending)
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final ok = await ref.read(adoptionProvider.notifier).updateRequestStatus(
                            requestId: request.id,
                            status: 'rejected',
                          );
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request rejected.'), backgroundColor: AppColors.danger),
                        );
                        ref.invalidate(myPetsProvider);
                      }
                    },
                    icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
                    label: const Text('Reject', style: TextStyle(color: AppColors.danger)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final ok = await ref.read(adoptionProvider.notifier).updateRequestStatus(
                            requestId: request.id,
                            status: 'approved',
                          );
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🎉 Request approved!'), backgroundColor: AppColors.success),
                        );
                        ref.invalidate(myPetsProvider);
                      }
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

// ── Individual Listing Card ───────────────────────────────────────────────────

class _MyListingCard extends ConsumerWidget {
  final PetModel pet;
  final int index;
  final List<AdoptionRequestModel> requests;
  final VoidCallback onDeleted;
  final VoidCallback onViewRequests;

  const _MyListingCard({
    required this.pet,
    required this.index,
    required this.requests,
    required this.onDeleted,
    required this.onViewRequests,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pendingCount = requests.where((r) => r.status == 'pending').length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => context.push('/pet/${pet.id}'),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBg : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: SizedBox(
                      width: 110, height: 130,
                      child: PetImageWidget(imageUrl: pet.imageUrl, fit: BoxFit.cover),
                    ),
                  ),

                  // Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name + Status badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pet.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _StatusBadge(isAdopted: pet.isAdopted),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Breed
                          Text(
                            pet.breed,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Tags row
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _MiniTag(icon: Icons.calendar_today_outlined, label: pet.ageText, color: AppColors.primary),
                              _MiniTag(
                                icon: pet.gender.toLowerCase() == 'male' ? Icons.male : Icons.female,
                                label: pet.gender,
                                color: pet.gender.toLowerCase() == 'male' ? Colors.blue : Colors.pink,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Location + Delete button
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  pet.location,
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _DeleteButton(pet: pet, onDeleted: onDeleted, ref: ref),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ── Adoption Requests Banner ─────────────────────────────────
              if (requests.isNotEmpty)
                GestureDetector(
                  onTap: onViewRequests,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: pendingCount > 0
                          ? AppColors.primary.withOpacity(0.08)
                          : AppColors.success.withOpacity(0.07),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: pendingCount > 0
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.success.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          pendingCount > 0 ? Icons.notifications_active_outlined : Icons.people_outline,
                          size: 16,
                          color: pendingCount > 0 ? AppColors.primary : AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pendingCount > 0
                                ? '$pendingCount pending adoption request${pendingCount > 1 ? 's' : ''}'
                                : '${requests.length} adoption request${requests.length > 1 ? 's' : ''} — all reviewed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: pendingCount > 0 ? AppColors.primary : AppColors.success,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: pendingCount > 0 ? AppColors.primary : AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate()
      .fade(delay: Duration(milliseconds: 80 * index), duration: 350.ms)
      .slideX(begin: 0.08, end: 0, delay: Duration(milliseconds: 80 * index), duration: 350.ms, curve: Curves.easeOut);
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isAdopted;
  const _StatusBadge({required this.isAdopted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAdopted ? AppColors.success.withOpacity(0.12) : AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAdopted ? AppColors.success.withOpacity(0.4) : AppColors.warning.withOpacity(0.5),
        ),
      ),
      child: Text(
        isAdopted ? '✓ Adopted' : '⏳ Available',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isAdopted ? AppColors.success : const Color(0xFFB8860B),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Mini Tag ──────────────────────────────────────────────────────────────────

class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniTag({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ── Delete Button ─────────────────────────────────────────────────────────────

class _DeleteButton extends StatelessWidget {
  final PetModel pet;
  final VoidCallback onDeleted;
  final WidgetRef ref;

  const _DeleteButton({required this.pet, required this.onDeleted, required this.ref});

  void _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Listing?',
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        content: Text('Remove "${pet.name}" from listings? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(petRepositoryProvider).deletePet(pet.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${pet.name} removed.'), backgroundColor: AppColors.success),
          );
          onDeleted();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmDelete(context),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyListingsView extends StatelessWidget {
  final VoidCallback onAddTap;
  const _EmptyListingsView({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
              ),
              child: const Icon(Icons.pets, size: 64, color: AppColors.primary),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            const Text(
              'No listings yet!',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 22, fontWeight: FontWeight.bold),
            ).animate().fade(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 10),
            Text(
              'Help a furry friend find a forever home.\nTap below to list your first pet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ).animate().fade(delay: 300.ms, duration: 400.ms),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAddTap,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('List a Pet', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ).animate().fade(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
