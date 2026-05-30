import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/fallback_state_view.dart';
import '../../../../shared/widgets/onboarding_intro_content.dart';
import '../../../../shared/widgets/onboarding_scaffold.dart';
import '../../../../shared/widgets/primary_action_button.dart';
import '../../../../shared/widgets/sequential_text_reveal.dart';
import '../../domain/onboarding_step.dart';
import '../providers/onboarding_providers.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _stepIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handlePrimaryAction() async {
    if (_stepIndex < onboardingIntroSteps.length) {
      setState(() {
        _stepIndex += 1;
      });
      return;
    }

    if (_stepIndex == onboardingIntroSteps.length) {
      final isValid = _formKey.currentState?.validate() ?? false;
      if (!isValid) {
        return;
      }

      await ref
          .read(onboardingControllerProvider.notifier)
          .submitName(_nameController.text);

      final submission = ref.read(onboardingControllerProvider);
      if (submission.hasError || !mounted) {
        return;
      }

      setState(() {
        _stepIndex += 1;
      });
      return;
    }

    if (_stepIndex == onboardingIntroSteps.length + 1 && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(onboardingControllerProvider);
    final currentName = ref.watch(onboardingDraftNameProvider);
    final isSubmitting = submissionState.isLoading;

    return OnboardingScaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: switch (_stepIndex) {
          0 || 1 || 2 => OnboardingIntroContent(
            key: ValueKey('intro-$_stepIndex'),
            titlePrimary: onboardingIntroSteps[_stepIndex].titlePrimary,
            titleAccent: onboardingIntroSteps[_stepIndex].titleAccent,
            subtitle: onboardingIntroSteps[_stepIndex].subtitle,
            stepIndex: _stepIndex,
          ),
          3 => _NameEntrySection(
            key: const ValueKey('name-input'),
            formKey: _formKey,
            controller: _nameController,
            enabled: !isSubmitting,
          ),
          4 => _NameConfirmationSection(
            key: const ValueKey('name-confirmation'),
            displayName: currentName,
          ),
          _ => const SizedBox.shrink(),
        },
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (submissionState.hasError)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: FallbackStateView.inline(
                message: 'Something went wrong while saving your name.',
              ),
            ),
          PrimaryActionButton(
            label: switch (_stepIndex) {
              0 || 1 || 2 => onboardingIntroSteps[_stepIndex].ctaLabel,
              3 => 'Submit',
              4 => "Let's Go!",
              _ => '',
            },
            onPressed: _handlePrimaryAction,
            isLoading: isSubmitting,
          ),
        ],
      ),
    );
  }
}

class _NameEntrySection extends StatelessWidget {
  const _NameEntrySection({
    required this.formKey,
    required this.controller,
    required this.enabled,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What should we call you?',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Your name personalized your Spillr',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: controller,
              enabled: enabled,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.neutral700,
              ),
              cursorColor: AppColors.neutral700,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(hintText: 'Enter your name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NameConfirmationSection extends StatelessWidget {
  const _NameConfirmationSection({required this.displayName, super.key});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.headlineLarge!;
    final subtitleStyle = theme.textTheme.bodyLarge!;

    return Center(
      child: SequentialTextReveal(
        key: const ValueKey('onboarding-confirmation-message'),
        textAlign: TextAlign.center,
        lines: [
          SequentialTextRevealLine(
            key: const ValueKey('onboarding-confirmation-headline-line-0'),
            spans: [
              SequentialTextRevealSpan(
                text: "Let's Start",
                style: headlineStyle,
              ),
            ],
          ),
          SequentialTextRevealLine(
            key: const ValueKey('onboarding-confirmation-headline-line-1'),
            spans: [
              SequentialTextRevealSpan(text: 'Spilling,', style: headlineStyle),
            ],
          ),
          SequentialTextRevealLine(
            key: const ValueKey('onboarding-confirmation-headline-line-2'),
            spans: [
              SequentialTextRevealSpan(
                text: displayName,
                style: headlineStyle.copyWith(color: AppColors.teal500),
              ),
            ],
          ),
          SequentialTextRevealLine(
            key: const ValueKey('onboarding-confirmation-subtitle-line-0'),
            gapBefore: 18,
            spans: [
              SequentialTextRevealSpan(
                text: 'Pull a card, answer with confidence,',
                style: subtitleStyle,
              ),
            ],
          ),
          SequentialTextRevealLine(
            key: const ValueKey('onboarding-confirmation-subtitle-line-1'),
            spans: [
              SequentialTextRevealSpan(
                text: 'and let the chaos begin.',
                style: subtitleStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
