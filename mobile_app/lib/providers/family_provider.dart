import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../data/models/family_member_model.dart';
import 'auth_provider.dart';

class FamilyState {
  final bool isLoading;
  final List<FamilyMemberModel> members;
  final String? inviteCode;

  FamilyState({
    this.isLoading = false,
    this.members = const [],
    this.inviteCode,
  });

  FamilyState copyWith({
    bool? isLoading,
    List<FamilyMemberModel>? members,
    String? inviteCode,
  }) {
    return FamilyState(
      isLoading: isLoading ?? this.isLoading,
      members: members ?? this.members,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}

class FamilyNotifier extends StateNotifier<FamilyState> {
  final ApiService _apiService;

  FamilyNotifier(this._apiService) : super(FamilyState());

  Future<void> fetchFamilyMembers() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _apiService.client.get('${ApiConstants.family}/members');
      if (res.data['success'] == true) {
        final list = (res.data['data'] as List)
            .map((f) => FamilyMemberModel.fromJson(f))
            .toList();
        state = state.copyWith(isLoading: false, members: list);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<String?> generateInviteLink(String? relationship) async {
    try {
      final res = await _apiService.client.post('${ApiConstants.family}/invite', data: {
        'relationship': relationship ?? 'family',
      });
      if (res.data['success'] == true) {
        final code = res.data['invite_code'];
        state = state.copyWith(inviteCode: code);
        return code;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

final familyProvider = StateNotifierProvider<FamilyNotifier, FamilyState>((ref) {
  return FamilyNotifier(ref.watch(apiServiceProvider));
});
