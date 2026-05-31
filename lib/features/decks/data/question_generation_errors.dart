abstract class QuestionGenerationException implements Exception {
  const QuestionGenerationException({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  String toString() => message;
}

final class QuestionGenerationOfflineException
    extends QuestionGenerationException {
  const QuestionGenerationOfflineException()
    : super(
        title: 'No Internet Connection',
        message: 'You need an internet connection to generate a question.',
      );
}

final class QuestionGenerationApiException extends QuestionGenerationException {
  const QuestionGenerationApiException({
    super.title = 'Unable to Generate Question',
    required super.message,
  });
}
