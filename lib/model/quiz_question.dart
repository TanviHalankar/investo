class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String category;
  final String lessonId; // Which lesson this quiz belongs to

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.category,
    required this.lessonId,
  });

  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }
}

