import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/adoption_provider.dart';
import '../../../data/models/adoption_request_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/pet_image_widget.dart';

class AdoptionScreen extends ConsumerStatefulWidget {
  const AdoptionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends ConsumerState<AdoptionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
      case 'completed':
        return AppColors.success;
      case 'rejected':
        return AppColors.danger;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext WidgetContext) {
    final adoptionState = ref.watch(adoptionProvider);
    final theme = Theme.of(WidgetContext);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Adoption Requests',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.grey : Colors.grey.shade600,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Sent Requests'),
            Tab(text: 'Received Requests'),
          ],
        ),
      ),
      body: adoptionState.isLoading && adoptionState.sentRequests.isEmpty && adoptionState.receivedRequests.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestList(
                  requests: adoptionState.sentRequests,
                  isReceived: false,
                  theme: theme,
                  isDark: isDark,
                ),
                _buildRequestList(
                  requests: adoptionState.receivedRequests,
                  isReceived: true,
                  theme: theme,
                  isDark: isDark,
                ),
              ],
            ),
    );
  }

  Widget _buildRequestList({
    required List<AdoptionRequestModel> requests,
    required bool isReceived,
    required ThemeData theme,
    required bool isDark,
  }) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isReceived ? Icons.move_to_inbox_outlined : Icons.outbox_outlined,
              size: 64,
              color: Colors.grey,
            ).animate().fade(duration: 400.ms),
            const SizedBox(height: 16),
            Text(
              'No requests found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isReceived
                  ? 'You haven\'t received any adoption requests yet.'
                  : 'You haven\'t submitted any adoption requests yet.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pet/Requester Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: PetImageWidget(
                          imageUrl: req.pet?.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Main info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                req.pet?.name ?? 'Unknown Pet',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(req.status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  req.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(req.status),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            req.pet?.breed ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isReceived
                                ? 'From: ${req.requester?.name ?? "Guest"}'
                                : 'To Owner: ${req.pet?.owner?.name ?? "Jane Doe"}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Message Section
                if (req.message != null && req.message!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '"${req.message}"',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],

                // Action Buttons for Received Requests (Approve/Reject)
                if (isReceived && req.status.toLowerCase() == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          ref.read(adoptionProvider.notifier).updateRequestStatus(
                                requestId: req.id,
                                status: 'rejected',
                              );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.danger),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Reject', style: TextStyle(color: AppColors.danger)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(adoptionProvider.notifier).updateRequestStatus(
                                requestId: req.id,
                                status: 'approved',
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Approve', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ).animate().fade(duration: 250.ms).slideX(begin: 0.1, end: 0);
      },
    );
  }
}
