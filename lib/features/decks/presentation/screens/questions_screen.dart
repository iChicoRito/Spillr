// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/fallback_state_view.dart';
import '../../../../shared/widgets/show_spillr_dialog.dart';
import '../../../../shared/widgets/spillr_bottom_sheet_scaffold.dart';
import '../../../../shared/widgets/spillr_confirm_dialog.dart';
import '../../../game/domain/spillr_deck.dart';
import '../../data/question_generation_service.dart';
import '../../domain/deck_question_item.dart';
import '../providers/deck_providers.dart';

class QuestionsScreen extends ConsumerWidget {
  const QuestionsScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckAsync = ref.watch(resolvedDeckProvider(deckId));
    final questionsAsync = ref.watch(deckQuestionsProvider(deckId));

    if (deckAsync.hasError) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: FallbackStateView.error(message: 'Unable to load this deck.'),
        ),
      );
    }
    if (questionsAsync.hasError) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: FallbackStateView.error(message: 'Unable to load questions.'),
        ),
      );
    }
    if (deckAsync.isLoading || questionsAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(child: FallbackStateView.loading()),
      );
    }

    return Scaffold(
      key: const ValueKey('questions-page'),
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: _QuestionsContent(
          deckId: deckId,
          deck: deckAsync.requireValue,
          questions: questionsAsync.requireValue,
        ),
      ),
    );
  }
}

class _QuestionsContent extends ConsumerWidget {
  const _QuestionsContent({
    required this.deckId,
    required this.deck,
    required this.questions,
  });

  final String deckId;
  final SpillrDeck deck;
  final List<DeckQuestionItem> questions;

  bool get _canAddQuestion => deckId.startsWith('custom-');
  bool get _canMutateRows => deckId != 'wildcard-tea';

  Future<void> _openCreateQuestionFlow(
    BuildContext context,
    WidgetRef ref, {
    String initialQuestion = '',
  }) async {
    final result = await showModalBottomSheet<_CreateQuestionSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.38),
      builder: (context) =>
          _CreateQuestionSheet(deck: deck, initialQuestion: initialQuestion),
    );

    if (!context.mounted || result is! _CreateQuestionSheetAiRequest) {
      return;
    }

    await _runAiGenerationFlow(context, ref, draftQuestion: result.draft);
  }

  Future<void> _runAiGenerationFlow(
    BuildContext context,
    WidgetRef ref, {
    required String draftQuestion,
  }) async {
    final rejectedQuestions = <String>[
      if (draftQuestion.trim().isNotEmpty) draftQuestion.trim(),
    ];

    while (context.mounted) {
      showSpillrDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.black.withValues(alpha: 0.42),
        builder: (context) => _QuestionGenerationLoadingDialog(deck: deck),
      );
      await WidgetsBinding.instance.endOfFrame;

      late final String generatedQuestion;
      try {
        generatedQuestion = await ref
            .read(questionGenerationControllerProvider.notifier)
            .generateQuestion(deck: deck, excludedQuestions: rejectedQuestions);
      } on QuestionGenerationException catch (error) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          await _showQuestionGenerationErrorDialog(context, error);
          _scheduleCreateQuestionSheet(
            context,
            ref,
            initialQuestion: draftQuestion,
          );
        }
        return;
      } catch (_) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          await _showQuestionGenerationErrorDialog(
            context,
            const QuestionGenerationApiException(
              message:
                  'We could not generate a question right now. Please try again.',
            ),
          );
          _scheduleCreateQuestionSheet(
            context,
            ref,
            initialQuestion: draftQuestion,
          );
        }
        return;
      }

      if (!context.mounted) {
        return;
      }
      Navigator.of(context, rootNavigator: true).pop();

      final usageState = await ref.read(questionGenerationUsageProvider.future);
      final usageMessage = _questionGenerationUsageMessage(usageState);

      final action = await showSpillrDialog<_QuestionGenerationReviewAction>(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.black.withValues(alpha: 0.42),
        builder: (context) => _QuestionGenerationReadyDialog(
          question: generatedQuestion,
          usageMessage: usageMessage,
        ),
      );

      if (!context.mounted) {
        return;
      }
      if (action == _QuestionGenerationReviewAction.accept) {
        _scheduleCreateQuestionSheet(
          context,
          ref,
          initialQuestion: generatedQuestion,
        );
        return;
      }

      if (action != _QuestionGenerationReviewAction.regenerate) {
        return;
      }

      rejectedQuestions.add(generatedQuestion);
    }
  }

  void _scheduleCreateQuestionSheet(
    BuildContext context,
    WidgetRef ref, {
    required String initialQuestion,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        _openCreateQuestionFlow(context, ref, initialQuestion: initialQuestion);
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            key: const ValueKey('questions-back-button'),
            onPressed: () => Navigator.of(context).maybePop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.neutral700,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.chevron_left, size: 20),
            label: const Text(
              'Back',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Lists of tea's for ",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral700,
                ),
              ),
              Text(
                deck.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: deck.badgeTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.neutral100),
              ),
              child: questions.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No tea here yet.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.neutral400,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      itemCount: questions.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: AppColors.neutral100),
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return _QuestionRow(
                          deckId: deckId,
                          question: question,
                          displayNumber: index + 1,
                          canMutate: _canMutateRows,
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: FilledButton.icon(
              key: const ValueKey('questions-add-button'),
              onPressed: _canAddQuestion
                  ? () => _openCreateQuestionFlow(context, ref)
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal500,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.teal500.withValues(
                  alpha: 0.35,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Question'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({
    required this.deckId,
    required this.question,
    required this.displayNumber,
    required this.canMutate,
  });

  final String deckId;
  final DeckQuestionItem question;
  final int displayNumber;
  final bool canMutate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question No. $displayNumber',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<_QuestionMenuAction>(
            key: ValueKey('questions-row-menu-$deckId-${displayNumber - 1}'),
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (action) => _handleAction(context, action),
            itemBuilder: (context) {
              final items = <PopupMenuEntry<_QuestionMenuAction>>[
                const PopupMenuItem<_QuestionMenuAction>(
                  value: _QuestionMenuAction.view,
                  child: Text('View Question'),
                ),
              ];
              if (canMutate) {
                items.addAll([
                  const PopupMenuItem<_QuestionMenuAction>(
                    value: _QuestionMenuAction.edit,
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem<_QuestionMenuAction>(
                    value: _QuestionMenuAction.delete,
                    child: Text(
                      'Delete',
                      style: TextStyle(color: AppColors.red500),
                    ),
                  ),
                ]);
              }
              return items;
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(
                Icons.more_vert,
                size: 20,
                color: AppColors.neutral400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, _QuestionMenuAction action) {
    switch (action) {
      case _QuestionMenuAction.view:
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: AppColors.black.withValues(alpha: 0.38),
          builder: (context) => _ViewQuestionSheet(
            displayNumber: displayNumber,
            question: question,
          ),
        );
      case _QuestionMenuAction.edit:
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: AppColors.black.withValues(alpha: 0.38),
          builder: (context) => _EditQuestionSheet(
            displayNumber: displayNumber,
            question: question,
          ),
        );
      case _QuestionMenuAction.delete:
        showSpillrDialog<void>(
          context: context,
          barrierColor: AppColors.black.withValues(alpha: 0.34),
          builder: (context) => _DeleteQuestionDialog(question: question),
        );
    }
  }
}

enum _QuestionMenuAction { view, edit, delete }

class _CreateQuestionSheet extends ConsumerStatefulWidget {
  const _CreateQuestionSheet({
    required this.deck,
    required this.initialQuestion,
  });

  final SpillrDeck deck;
  final String initialQuestion;

  @override
  ConsumerState<_CreateQuestionSheet> createState() =>
      _CreateQuestionSheetState();
}

class _CreateQuestionSheetState extends ConsumerState<_CreateQuestionSheet> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuestion);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(questionMutationControllerProvider.notifier)
        .addQuestion(deckId: widget.deck.id, rawText: _controller.text);
    if (mounted && !ref.read(questionMutationControllerProvider).hasError) {
      Navigator.of(context).pop();
    }
  }

  void _requestAiGeneration() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(_CreateQuestionSheetAiRequest(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final mutationState = ref.watch(questionMutationControllerProvider);
    final isBusy = mutationState.isLoading;
    final usageAsync = ref.watch(questionGenerationUsageProvider);
    final usageState = usageAsync.maybeWhen(
      data: (state) => state,
      orElse: () => null,
    );
    final usageMessage = _questionGenerationUsageMessage(usageState);
    final isGenerationBlocked = usageAsync.when(
      data: (state) => state.isBlockedAt(DateTime.now()),
      loading: () => false,
      error: (error, stackTrace) => false,
    );

    return SpillrBottomSheetScaffold(
      title: 'Create Question',
      primaryActionLabel: 'Create',
      primaryActionKey: const ValueKey('question-sheet-save-button'),
      onPrimaryAction: _submit,
      isPrimaryActionEnabled: !isBusy,
      isPrimaryActionLoading: mutationState.isLoading,
      secondaryActionKey: const ValueKey('question-ai-generate-button'),
      secondaryActionLabel: 'Generate with AI',
      secondaryActionIcon: const Icon(Icons.auto_awesome, size: 20),
      onSecondaryAction: _requestAiGeneration,
      isSecondaryActionEnabled: !isBusy && !isGenerationBlocked,
      secondaryActionFooter: _QuestionGenerationUsageNotice(
        key: const ValueKey('question-ai-usage-indicator'),
        message: usageMessage,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const ValueKey('question-sheet-text-field'),
              controller: _controller,
              minLines: 2,
              maxLines: 3,
              enabled: !isBusy,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a question.';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'Drop the questions here....',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract class _CreateQuestionSheetResult {
  const _CreateQuestionSheetResult();
}

class _CreateQuestionSheetAiRequest extends _CreateQuestionSheetResult {
  const _CreateQuestionSheetAiRequest(this.draft);

  final String draft;
}

class _QuestionGenerationLoadingDialog extends StatelessWidget {
  const _QuestionGenerationLoadingDialog({required this.deck});

  final SpillrDeck deck;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const ValueKey('question-ai-loading-dialog'),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(26, 34, 26, 34),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _QuestionGenerationIcon(),
            const SizedBox(height: 22),
            Text(
              'Question Generating...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                text:
                    'Please be patient while the AI generating '
                    'the question for ',
                children: [
                  TextSpan(
                    text: deck.title,
                    style: TextStyle(
                      color: deck.badgeTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: AppColors.neutral400,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionGenerationReadyDialog extends StatelessWidget {
  const _QuestionGenerationReadyDialog({
    required this.question,
    required this.usageMessage,
  });

  final String question;
  final String usageMessage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const ValueKey('question-ai-ready-dialog'),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: _QuestionGenerationIcon()),
                const SizedBox(height: 22),
                Text(
                  'Question Ready!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "New question generated. Let's keep the chat moving.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: AppColors.neutral400,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.neutral200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Question Generated:',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: AppColors.neutral700,
                          height: 1.24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 58,
                  child: FilledButton(
                    key: const ValueKey('question-ai-accept-button'),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(_QuestionGenerationReviewAction.accept),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.teal500,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text("I'll take it"),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    key: const ValueKey('question-ai-generate-again-button'),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(_QuestionGenerationReviewAction.regenerate),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.teal500,
                      side: const BorderSide(color: AppColors.teal500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Re-Generate'),
                  ),
                ),
                const SizedBox(height: 14),
                _QuestionGenerationUsageNotice(
                  key: const ValueKey('question-ai-ready-usage-indicator'),
                  message: usageMessage,
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              key: const ValueKey('question-ai-close-button'),
              tooltip: 'Close',
              style: IconButton.styleFrom(
                foregroundColor: AppColors.neutral400,
              ),
              onPressed: () => Navigator.of(
                context,
              ).pop(_QuestionGenerationReviewAction.cancel),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionGenerationIcon extends StatelessWidget {
  const _QuestionGenerationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        color: AppColors.teal100,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.auto_awesome, size: 30, color: AppColors.teal500),
    );
  }
}

enum _QuestionGenerationReviewAction { accept, regenerate, cancel }

String _questionGenerationUsageMessage(QuestionGenerationUsageState? state) {
  if (state == null || state.attemptCount == 0) {
    return 'You can generate up to 15 times per hour';
  }

  if (state.isBlockedAt(DateTime.now()) || state.hasReachedLimit) {
    return "You've hit the 15-request hourly limit. Please wait until your quota resets.";
  }

  return 'You’ve used ${state.attemptCount} of 15 requests this hour';
}

class _QuestionGenerationUsageNotice extends StatelessWidget {
  const _QuestionGenerationUsageNotice({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: AppColors.neutral400,
          height: 1.25,
        ),
      ),
    );
  }
}

Future<void> _showQuestionGenerationErrorDialog(
  BuildContext context,
  QuestionGenerationException error,
) {
  return showSpillrDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.black.withValues(alpha: 0.42),
    builder: (context) => _QuestionGenerationErrorDialog(error: error),
  );
}

class _QuestionGenerationErrorDialog extends StatelessWidget {
  const _QuestionGenerationErrorDialog({required this.error});

  final QuestionGenerationException error;

  @override
  Widget build(BuildContext context) {
    final icon = switch (error) {
      QuestionGenerationOfflineException() => Icons.wifi_off_rounded,
      QuestionGenerationLimitExceededException() => Icons.lock_clock_rounded,
      _ => Icons.error_outline_rounded,
    };

    return Dialog(
      key: const ValueKey('question-ai-error-dialog'),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: AppColors.red100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.red500, size: 30),
            ),
            const SizedBox(height: 20),
            Text(
              error.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: AppColors.neutral400,
                height: 1.22,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal500,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Okay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditQuestionSheet extends ConsumerStatefulWidget {
  const _EditQuestionSheet({
    required this.displayNumber,
    required this.question,
  });

  final int displayNumber;
  final DeckQuestionItem question;

  @override
  ConsumerState<_EditQuestionSheet> createState() => _EditQuestionSheetState();
}

class _EditQuestionSheetState extends ConsumerState<_EditQuestionSheet> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.question.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(questionMutationControllerProvider.notifier)
        .updateQuestion(id: widget.question.id, rawText: _controller.text);
    if (mounted && !ref.read(questionMutationControllerProvider).hasError) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mutationState = ref.watch(questionMutationControllerProvider);

    return SpillrBottomSheetScaffold(
      title: 'Edit Question',
      primaryActionLabel: 'Save',
      primaryActionKey: const ValueKey('question-sheet-save-button'),
      onPrimaryAction: _submit,
      isPrimaryActionEnabled: !mutationState.isLoading,
      isPrimaryActionLoading: mutationState.isLoading,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question no. ${widget.displayNumber}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const ValueKey('question-sheet-text-field'),
              controller: _controller,
              minLines: 2,
              maxLines: 3,
              enabled: !mutationState.isLoading,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a question.';
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

class _ViewQuestionSheet extends StatelessWidget {
  const _ViewQuestionSheet({
    required this.displayNumber,
    required this.question,
  });

  final int displayNumber;
  final DeckQuestionItem question;

  @override
  Widget build(BuildContext context) {
    return SpillrBottomSheetScaffold(
      title: 'View Question',
      primaryActionLabel: 'Close',
      primaryActionColor: AppColors.neutral100,
      primaryActionForegroundColor: AppColors.neutral700,
      onPrimaryAction: () => Navigator.of(context).pop(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neutral100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question No. $displayNumber',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteQuestionDialog extends ConsumerWidget {
  const _DeleteQuestionDialog({required this.question});

  final DeckQuestionItem question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SpillrConfirmDialog(
      title: 'Delete This Tea?',
      message: 'This question will leave the deck for good.',
      onConfirm: () async {
        await ref
            .read(questionMutationControllerProvider.notifier)
            .deleteQuestion(question.id);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
