import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class OnboardingIntroContent extends StatelessWidget {
  const OnboardingIntroContent({
    required this.titlePrimary,
    required this.titleAccent,
    required this.subtitle,
    required this.stepIndex,
    super.key,
  });

  final String titlePrimary;
  final String titleAccent;
  final String subtitle;
  final int stepIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 28),
        Expanded(
          child: SizedBox(
            key: ValueKey('onboarding-art-placeholder-$stepIndex'),
            child: const Center(
              child: SizedBox(width: 280, height: 320),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            Text(
              titlePrimary,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: AppColors.neutral700,
                fontSize: 58,
                height: 0.98,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              titleAccent,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: AppColors.teal500,
                fontSize: 58,
                height: 0.98,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.neutral400,
            fontSize: 16,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
