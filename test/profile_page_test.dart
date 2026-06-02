import 'package:drift/native.dart';
import 'package:drift/drift.dart' show ProfilesCompanion, Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spillr/core/database/app_database.dart';
import 'package:spillr/core/database/app_database_provider.dart';
import 'package:spillr/features/profile/data/profile_repository.dart';
import 'package:spillr/features/profile/domain/profile_models.dart';
import 'package:spillr/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:spillr/features/profile/presentation/providers/profile_providers.dart';
import 'package:spillr/features/profile/presentation/screens/profile_page_screen.dart';
import 'package:spillr/shared/widgets/spillr_bottom_navigation.dart';

void main() {
  late AppDatabase database;
  late ProfileRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ProfileRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpProfilePage(
    WidgetTester tester, {
    required Profile profile,
    required ProfileStats stats,
  }) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          onboardingProfileProvider.overrideWith(
            (ref) async => profile,
          ),
          profileStatsProvider.overrideWith(
            (ref) => Stream<ProfileStats>.value(stats),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ProfilePageScreen())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> seedProfile({
    String name = 'Chico',
    ProfileAvatarAsset? avatarAsset,
    ProfileAvatarColorKey? avatarColor,
  }) async {
    await database.into(database.profiles).insertOnConflictUpdate(
      ProfilesCompanion.insert(
        id: const Value(1),
        displayName: name,
        completedAt: DateTime(2026, 5, 31, 12, 0),
        avatarAssetPath: Value(avatarAsset?.assetPath),
        avatarColorKey: Value(avatarColor?.value),
      ),
    );
  }

  Profile buildProfile({
    required String name,
    ProfileAvatarAsset? avatarAsset,
    ProfileAvatarColorKey? avatarColor,
  }) {
    return Profile(
      id: 1,
      displayName: name,
      completedAt: DateTime(2026, 5, 31, 12, 0),
      avatarAssetPath: avatarAsset?.assetPath,
      avatarColorKey: avatarColor?.value,
    );
  }

  String _statValue(WidgetTester tester, Key tileKey) {
    final texts = tester.widgetList<Text>(
      find.descendant(of: find.byKey(tileKey), matching: find.byType(Text)),
    );
    return texts.first.data!;
  }

  testWidgets('shows the profile tab as selected when configured', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: SpillrBottomNavigation(
            selectedTab: SpillrBottomNavTab.profile,
            onDecksTap: () {},
            onPlayTap: () {},
            onProfileTap: () {},
          ),
        ),
      ),
    );

    final nav = tester.widget<SpillrBottomNavigation>(
      find.byType(SpillrBottomNavigation),
    );
    expect(nav.selectedTab, SpillrBottomNavTab.profile);
  });

  testWidgets(
    'renders saved profile data, default avatar fallback, static rows, and stats',
    (tester) async {
      final profile = buildProfile(name: 'Chico');
      const stats = ProfileStats(cardsAnswered: 2, cardsPassed: 1);

      await pumpProfilePage(tester, profile: profile, stats: stats);

      expect(find.text('Chico'), findsOneWidget);
      expect(find.text('Play History'), findsOneWidget);
      expect(find.text('Decks and Cards'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Music & Sound'), findsOneWidget);

      final avatar = tester.widget<ProfileAvatarCircle>(
        find.byKey(const ValueKey('profile-avatar')),
      );
      expect(avatar.avatarAsset, isNull);
      expect(avatar.avatarColor, ProfileAvatarColorKey.teal);

      expect(
        _statValue(tester, const ValueKey('profile-stat-cards-played')),
        '3',
      );
      expect(
        _statValue(tester, const ValueKey('profile-stat-cards-answered')),
        '2',
      );
      expect(
        _statValue(tester, const ValueKey('profile-stat-cards-passed')),
        '1',
      );
    },
  );

  testWidgets(
    'opens the edit sheet, updates the live preview, validates the name, and saves the profile',
    (tester) async {
      await seedProfile(name: 'Chico');
      await pumpProfilePage(
        tester,
        profile: buildProfile(name: 'Chico'),
        stats: const ProfileStats.zero(),
      );

      await tester.tap(find.byKey(const ValueKey('profile-edit-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));

      final initialPreview = tester.widget<ProfileAvatarCircle>(
        find.byKey(const ValueKey('profile-avatar-preview')),
      );
      expect(initialPreview.avatarAsset, ProfileAvatarAsset.avatar1);
      expect(initialPreview.avatarColor, ProfileAvatarColorKey.teal);

      await tester.enterText(
        find.byKey(const ValueKey('profile-name-field')),
        '   ',
      );
      await tester.tap(find.byKey(const ValueKey('profile-update-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));

      expect(find.text('Please enter a name.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('profile-name-field')),
        'Mika',
      );
      await tester.tap(find.byKey(const ValueKey('profile-avatar-option-7')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('profile-color-option-cyan')));
      await tester.pump();

      final updatedPreview = tester.widget<ProfileAvatarCircle>(
        find.byKey(const ValueKey('profile-avatar-preview')),
      );
      expect(updatedPreview.avatarAsset, ProfileAvatarAsset.avatar7);
      expect(updatedPreview.avatarColor, ProfileAvatarColorKey.cyan);

      await tester.tap(find.byKey(const ValueKey('profile-update-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));

      final savedProfile = await database.fetchProfile();
      expect(savedProfile, isNotNull);
      expect(savedProfile!.displayName, 'Mika');
      expect(
        savedProfile.avatarAssetPath,
        ProfileAvatarAsset.avatar7.assetPath,
      );
      expect(savedProfile.avatarColorKey, ProfileAvatarColorKey.cyan.value);
      expect(find.byKey(const ValueKey('profile-edit-button')), findsOneWidget);
    },
  );

  testWidgets('toggles the notifications and dark mode switches visually', (
    tester,
  ) async {
    await pumpProfilePage(
      tester,
      profile: buildProfile(name: 'Chico'),
      stats: const ProfileStats.zero(),
    );

    final notificationsSwitch = find.descendant(
      of: find.byKey(const ValueKey('profile-option-notifications')),
      matching: find.byType(Switch),
    );
    final darkModeSwitch = find.descendant(
      of: find.byKey(const ValueKey('profile-option-dark-mode')),
      matching: find.byType(Switch),
    );

    expect(tester.widget<Switch>(notificationsSwitch).value, isTrue);
    expect(tester.widget<Switch>(darkModeSwitch).value, isFalse);

    await tester.tap(notificationsSwitch);
    await tester.tap(darkModeSwitch);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.widget<Switch>(notificationsSwitch).value, isFalse);
    expect(tester.widget<Switch>(darkModeSwitch).value, isTrue);
    expect(find.text('Your Profile'), findsOneWidget);
  });
}
