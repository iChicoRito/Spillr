import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/app_audio_controller.dart';

Future<T?> showSpillrDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  unawaited(
    ProviderScope.containerOf(
      context,
      listen: false,
    ).read(appAudioControllerProvider).playDialogSfx(),
  );

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    builder: builder,
  );
}
