import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/app_database_provider.dart';

final onboardingProfileProvider = FutureProvider<Profile?>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  return database.fetchProfile();
});

final onboardingDraftNameProvider =
    NotifierProvider<OnboardingDraftNameNotifier, String>(
      OnboardingDraftNameNotifier.new,
    );

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, void>(OnboardingController.new);

class OnboardingDraftNameNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setName(String name) {
    state = name;
  }
}

class OnboardingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submitName(String rawName) async {
    final displayName = rawName.trim();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final database = ref.read(appDatabaseProvider);
      await database.saveProfile(displayName);
      ref.read(onboardingDraftNameProvider.notifier).setName(displayName);
      ref.invalidate(onboardingProfileProvider);
    });
  }
}
