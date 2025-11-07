import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/quiz_question.dart';
import '../services/quiz_service.dart';
import '../services/achievement_service.dart';
import '../services/portfolio_service.dart';

class QuizScreen extends StatefulWidget {
  final String lessonTitle;
  final String category;

  const QuizScreen({
    super.key,
    required this.lessonTitle,
    required this.category,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  final AchievementService _achievementService = AchievementService();
  final PortfolioService _portfolioService = PortfolioService();

  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;
  int _correctAnswers = 0;
  bool _quizCompleted = false;

  // Color scheme
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color cardLight = Color(0xFF242424);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentOrangeDim = Color(0xFFCC7700);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textTertiary = Color(0xFF666666);
  static const Color borderColor = Color(0xFF2A2A2A);
  static const Color positiveGreen = Color(0xFF00E676);
  static const Color negativeRed = Color(0xFFFF5252);

  @override
  void initState() {
    super.initState();
    _questions = _quizService.getQuizForLesson(widget.lessonTitle);
  }

  void _selectAnswer(int index) {
    if (_showExplanation) return;

    setState(() {
      _selectedAnswer = index;
      _showExplanation = true;

      if (_questions[_currentQuestionIndex].isCorrect(index)) {
        _correctAnswers++;
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showExplanation = false;
      });
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    setState(() {
      _quizCompleted = true;
    });

    final score = (_correctAnswers / _questions.length * 100).round();
    final pointsEarned = score >= 80 ? 50 : score >= 60 ? 30 : 10;

    // Award points
    try {
      await _portfolioService.awardPoints(pointsEarned, reason: 'quiz:${widget.lessonTitle}');
    } catch (e) {
      debugPrint('Error awarding quiz points: $e');
    }

    // Update achievement progress
    try {
      await _achievementService.updateProgress('lessons_5', 1);
    } catch (e) {
      debugPrint('Error updating achievement: $e');
    }

    HapticFeedback.mediumImpact();
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _showExplanation = false;
      _correctAnswers = 0;
      _quizCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: cardDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Quiz',
            style: TextStyle(color: textPrimary),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz, size: 64, color: textTertiary),
                const SizedBox(height: 16),
                const Text(
                  'No quiz available',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quiz questions are coming soon for this lesson',
                  style: TextStyle(color: textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_quizCompleted) {
      return _buildResultsScreen();
    }

    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: cardDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quiz',
              style: TextStyle(color: textPrimary, fontSize: 18),
            ),
            Text(
              '${_currentQuestionIndex + 1} / ${_questions.length}',
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: cardLight,
            valueColor: AlwaysStoppedAnimation<Color>(accentOrange),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentOrange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.help_outline,
                            color: accentOrange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question.question,
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Answer Options
              ...question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = _selectedAnswer == index;
                final isCorrect = question.isCorrect(index);
                final showResult = _showExplanation;

                Color? backgroundColor;
                Color? borderColor;
                Color? textColor = textPrimary;

                if (showResult) {
                  if (isCorrect) {
                    backgroundColor = positiveGreen.withOpacity(0.2);
                    borderColor = positiveGreen;
                  } else if (isSelected && !isCorrect) {
                    backgroundColor = negativeRed.withOpacity(0.2);
                    borderColor = negativeRed;
                  } else {
                    backgroundColor = cardDark;
                    borderColor = _QuizScreenState.borderColor;
                    textColor = textSecondary;
                  }
                } else {
                  backgroundColor = isSelected ? accentOrange.withOpacity(0.2) : cardDark;
                  borderColor = isSelected ? accentOrange : _QuizScreenState.borderColor;
                }

                return GestureDetector(
                  onTap: () => _selectAnswer(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: borderColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Center(
                            child: showResult && isCorrect
                                ? Icon(Icons.check, color: borderColor, size: 20)
                                : showResult && isSelected && !isCorrect
                                    ? Icon(Icons.close, color: borderColor, size: 20)
                                    : Text(
                                        String.fromCharCode(65 + index),
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Explanation
              if (_showExplanation)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _questions[_currentQuestionIndex].isCorrect(_selectedAnswer!)
                        ? positiveGreen.withOpacity(0.1)
                        : accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _questions[_currentQuestionIndex].isCorrect(_selectedAnswer!)
                          ? positiveGreen.withOpacity(0.3)
                          : accentOrange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _questions[_currentQuestionIndex].isCorrect(_selectedAnswer!)
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color: _questions[_currentQuestionIndex].isCorrect(_selectedAnswer!)
                            ? positiveGreen
                            : accentOrange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _questions[_currentQuestionIndex].isCorrect(_selectedAnswer!)
                                  ? 'Correct!'
                                  : 'Incorrect',
                              style: TextStyle(
                                color: _questions[_currentQuestionIndex].isCorrect(_selectedAnswer!)
                                    ? positiveGreen
                                    : accentOrange,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.explanation,
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Next Button
              if (_showExplanation)
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentOrange,
                    foregroundColor: darkBg,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentQuestionIndex < _questions.length - 1
                        ? 'Next Question'
                        : 'View Results',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final score = (_correctAnswers / _questions.length * 100).round();
    final pointsEarned = score >= 80 ? 50 : score >= 60 ? 30 : 10;
    final isPassing = score >= 60;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: cardDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quiz Results',
          style: TextStyle(color: textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Score Circle
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isPassing
                        ? [positiveGreen, positiveGreen.withOpacity(0.7)]
                        : [accentOrange, accentOrangeDim],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score%',
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Score',
                        style: TextStyle(
                          color: textPrimary.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Results Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Correct',
                          '$_correctAnswers',
                          positiveGreen,
                          Icons.check_circle,
                        ),
                        _buildStatItem(
                          'Wrong',
                          '${_questions.length - _correctAnswers}',
                          negativeRed,
                          Icons.cancel,
                        ),
                        _buildStatItem(
                          'Total',
                          '${_questions.length}',
                          accentOrange,
                          Icons.quiz,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentOrange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stars, color: accentOrange, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            '+$pointsEarned Points',
                            style: TextStyle(
                              color: accentOrange,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Message
              Text(
                isPassing
                    ? score >= 80
                        ? 'Excellent work! 🎉\nYou mastered this lesson!'
                        : 'Good job! 👍\nYou passed the quiz!'
                    : 'Keep learning! 📚\nReview the lesson and try again.',
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _restartQuiz,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textPrimary,
                        side: BorderSide(color: borderColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retake Quiz'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentOrange,
                        foregroundColor: darkBg,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

