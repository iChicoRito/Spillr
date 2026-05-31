import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SpillrBottomSheetScaffold extends StatelessWidget {
  const SpillrBottomSheetScaffold({
    required this.title,
    required this.child,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    super.key,
    this.primaryActionKey,
    this.primaryActionColor = AppColors.teal500,
    this.primaryActionForegroundColor = AppColors.white,
    this.isPrimaryActionEnabled = true,
    this.isPrimaryActionLoading = false,
    this.secondaryActionKey,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.secondaryActionFooter,
    this.secondaryActionBackgroundColor = AppColors.teal100,
    this.secondaryActionForegroundColor = AppColors.teal500,
    this.isSecondaryActionEnabled = true,
    this.isSecondaryActionLoading = false,
  });

  final String title;
  final Widget child;
  final String primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final Key? primaryActionKey;
  final Color primaryActionColor;
  final Color primaryActionForegroundColor;
  final bool isPrimaryActionEnabled;
  final bool isPrimaryActionLoading;
  final Key? secondaryActionKey;
  final String? secondaryActionLabel;
  final Widget? secondaryActionIcon;
  final VoidCallback? onSecondaryAction;
  final Widget? secondaryActionFooter;
  final Color secondaryActionBackgroundColor;
  final Color secondaryActionForegroundColor;
  final bool isSecondaryActionEnabled;
  final bool isSecondaryActionLoading;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(top: 120, bottom: mediaQuery.viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: ColoredBox(
          color: AppColors.white,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 96,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 22),
                  child,
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      key: primaryActionKey,
                      onPressed: isPrimaryActionEnabled
                          ? onPrimaryAction
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryActionColor,
                        foregroundColor: primaryActionForegroundColor,
                        disabledBackgroundColor: primaryActionColor.withValues(
                          alpha: 0.45,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: isPrimaryActionLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryActionForegroundColor,
                                ),
                              ),
                            )
                          : Text(primaryActionLabel),
                    ),
                  ),
                  if (secondaryActionLabel != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        key: secondaryActionKey,
                        onPressed: isSecondaryActionEnabled
                            ? onSecondaryAction
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: secondaryActionBackgroundColor,
                          foregroundColor: secondaryActionForegroundColor,
                          disabledBackgroundColor:
                              secondaryActionBackgroundColor.withValues(
                                alpha: 0.5,
                              ),
                          disabledForegroundColor:
                              secondaryActionForegroundColor.withValues(
                                alpha: 0.45,
                              ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0,
                        ),
                        icon: isSecondaryActionLoading
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    secondaryActionForegroundColor,
                                  ),
                                ),
                              )
                            : secondaryActionIcon ?? const SizedBox.shrink(),
                        label: Text(secondaryActionLabel!),
                      ),
                    ),
                    if (secondaryActionFooter != null) ...[
                      const SizedBox(height: 8),
                      secondaryActionFooter!,
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
