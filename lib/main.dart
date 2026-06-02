import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/audio/app_audio_provider_overrides.dart';
import 'core/database/app_database.dart';
import 'core/notifications/notification_service.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize();

  final database = AppDatabase();
  try {
    final profile = await database.fetchProfile();
    if (profile != null && profile.notificationsEnabled) {
      await NotificationService.instance.topUpIfNeeded(
        displayName: profile.displayName,
      );
    }
  } finally {
    await database.close();
  }

  runApp(
    ProviderScope(
      overrides: appAudioProviderOverrides,
      child: const SpillrApp(),
    ),
  );
}
