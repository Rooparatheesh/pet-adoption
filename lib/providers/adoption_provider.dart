import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/adoption_request_model.dart';
import 'service_providers.dart';
import 'auth_provider.dart';
import 'pet_provider.dart';

class AdoptionState {
  final List<AdoptionRequestModel> sentRequests;
  final List<AdoptionRequestModel> receivedRequests;
  final bool isLoading;
  final String? error;

  AdoptionState({
    required this.sentRequests,
    required this.receivedRequests,
    this.isLoading = false,
    this.error,
  });

  factory AdoptionState.initial() => AdoptionState(
        sentRequests: [],
        receivedRequests: [],
        isLoading: false,
      );

  AdoptionState copyWith({
    List<AdoptionRequestModel>? sentRequests,
    List<AdoptionRequestModel>? receivedRequests,
    bool? isLoading,
    String? error,
  }) {
    return AdoptionState(
      sentRequests: sentRequests ?? this.sentRequests,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AdoptionNotifier extends StateNotifier<AdoptionState> {
  final Ref _ref;

  AdoptionNotifier(this._ref) : super(AdoptionState.initial()) {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        loadRequests();
      } else if (next.status == AuthStatus.unauthenticated) {
        state = AdoptionState.initial();
      }
    });

    if (_ref.read(authProvider).status == AuthStatus.authenticated) {
      loadRequests();
    }
  }

  Future<void> loadRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(adoptionRepositoryProvider);
      
      final sent = await repo.getAdoptionRequests(isReceived: false);
      final received = await repo.getAdoptionRequests(isReceived: true);
      
      state = state.copyWith(
        sentRequests: sent,
        receivedRequests: received,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> submitRequest({required int petId, String? message}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newRequest = await _ref.read(adoptionRepositoryProvider).submitRequest(
            petId: petId,
            message: message,
          );
      state = state.copyWith(
        sentRequests: [newRequest, ...state.sentRequests],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateRequestStatus({required int requestId, required String status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _ref.read(adoptionRepositoryProvider).updateRequestStatus(
            requestId: requestId,
            status: status,
          );
      
      // Update received list
      final newReceived = state.receivedRequests.map((req) {
        if (req.id == updated.id) return updated;
        // If the pet is the same and status became approved/completed, other pending requests became rejected
        if (req.petId == updated.petId && req.id != updated.id && (status == 'approved' || status == 'completed')) {
          return AdoptionRequestModel(
            id: req.id,
            userId: req.userId,
            petId: req.petId,
            status: 'rejected',
            message: req.message,
            pet: req.pet,
            requester: req.requester,
            createdAt: req.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return req;
      }).toList();

      state = state.copyWith(
        receivedRequests: newReceived,
        isLoading: false,
      );

      // Force refresh pets list to show that the pet is adopted
      _ref.invalidate(petListProvider);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

final adoptionProvider = StateNotifierProvider<AdoptionNotifier, AdoptionState>((ref) {
  return AdoptionNotifier(ref);
});
