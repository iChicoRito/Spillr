import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/audio/app_audio_provider_overrides.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: appAudioProviderOverrides,
      child: const SpillrApp(),
    ),
  );
}
