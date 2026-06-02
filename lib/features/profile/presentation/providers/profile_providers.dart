import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../data/profile_repository.dart';
import '../../domain/profile_models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ProfileRepository(database);
});

final profileStatsProvider = StreamProvider<ProfileStats>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.watchProfileStats();
});

final gameHistoryProvider = StreamProvider<List<GameHistoryItem>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.watchGameHistory();
});

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);

class ProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateProfile({
    required String displayName,
    required ProfileAvatarAsset avatarAsset,
    required ProfileAvatarColorKey avatarColor,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);
      await repository.updateProfile(
        displayName: displayName,
        avatarAsset: avatarAsset,
        avatarColor: avatarColor,
      );
      ref.invalidate(onboardingProfileProvider);
    });
  }

  Future<void> clearGameHistory() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(profileRepositoryProvider).clearGameHistory();
    });
  }
}
