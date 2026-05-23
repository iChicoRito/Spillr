import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FallbackStateView extends StatelessWidget {
  const FallbackStateView.loading({super.key})
    : message = 'Loading Spillr...',
      icon = null;

  const FallbackStateView.error({required this.message, super.key})
    : icon = Icons.error_outline;

  const FallbackStateView.inline({required this.message, super.key})
    : icon = Icons.info_outline;

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    if (icon == null) {
      return Center(
        child: Text(message, style: textStyle, textAlign: TextAlign.center),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.red500, size: 18),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            message,
            style: textStyle?.copyWith(color: AppColors.red500),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
