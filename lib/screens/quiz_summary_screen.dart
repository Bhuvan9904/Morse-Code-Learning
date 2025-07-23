import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memory_hack_app/screens/main_navigation_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';

class QuizSummaryScreen extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final List<String> weakLetters;

  const QuizSummaryScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.weakLetters,
  });

  @override
  State<QuizSummaryScreen> createState() => _QuizSummaryScreenState();
}

class _QuizSummaryScreenState extends State<QuizSummaryScreen> {
  late ConfettiController _confettiController;
  bool _showCelebration = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    if (widget.correctAnswers / widget.totalQuestions >= 0.8) {
      _showCelebration = true;
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _navigateToFlashcards(List<String>? letters) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainNavigationScreen(
          initialIndex: 1, // Flashcard tab
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scorePercentage = widget.correctAnswers / widget.totalQuestions;
    final isSuccess = scorePercentage >= 0.7;
    final Color primaryColor = isSuccess ? const Color(0xFF3CC45B) : const Color(0xFFF9C244);
    final scoreText = '${widget.correctAnswers}/${widget.totalQuestions}';

    return Scaffold(
      backgroundColor: const Color(0xFF161825),
      body: Stack(
        children: [
          _buildBackgroundPattern(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isSuccess ? '🎉 Quiz Complete!' : '📝 Quiz Results',
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You got $scoreText correct answers',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 100,
                        lineWidth: 14,
                        percent: scorePercentage,
                        progressColor: primaryColor,
                        backgroundColor: Colors.grey.shade200,
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                      Column(
                        children: [
                          Text(
                            '${(scorePercentage * 100).round()}%',
                            style: GoogleFonts.montserrat(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            'Score',
                            style: GoogleFonts.montserrat(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (widget.weakLetters.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3C51),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3CC45B),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Color(0xFF3CC45B)),
                              const SizedBox(width: 8),
                              Text(
                                'Letters to Review',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3CC45B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.weakLetters.map((letter) {
                              return Chip(
                                label: Text(
                                  letter,
                                  style: GoogleFonts.robotoMono(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: const Color(0xFF4F516A),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3C51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        LinearPercentIndicator(
                          lineHeight: 20,
                          percent: 0.65,
                          center: Text(
                            "65% to next level",
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          progressColor: const Color(0xFF3CC45B),
                          backgroundColor: Colors.grey.shade700,
                          barRadius: const Radius.circular(10),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Keep going to unlock new letters!",
                          style: GoogleFonts.montserrat(
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Column(
                    children: [
                      if (widget.weakLetters.isNotEmpty)
                        _buildActionButton(
                          'Practice Weak Letters',
                          const Color(0xFFF9C244),
                          Icons.flash_on,
                          () => _navigateToFlashcards(widget.weakLetters),
                        ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Try Again',
                        Colors.grey.shade800,
                        Icons.refresh,
                        () => _navigateToFlashcards(null),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Continue Learning',
                        const Color(0xFF3CC45B),
                        Icons.arrow_forward,
                        () => _navigateToFlashcards(null),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          if (_showCelebration)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.03,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 60,
          ),
          itemBuilder: (context, index) {
            return Center(
              child: Text(
                '· –',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey.shade400,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
