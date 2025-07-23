import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memory_hack_app/screens/main_navigation_screen.dart';
import 'package:memory_hack_app/services/audio_service.dart';
import 'package:memory_hack_app/screens/quiz_summary_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashcardScreen extends StatefulWidget {
  final List<String>? reviewLetters;
  const FlashcardScreen({super.key, this.reviewLetters});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late ConfettiController _confettiController;
  bool _isFrontVisible = true;
  int _correctCount = 0;
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  String _correctAnswer = '';

  final Map<String, String> _morseMap = {
    'A': '.-',
    'B': '-...',
    'C': '-.-.',
    'D': '-..',
    'E': '.',
    'F': '..-.',
    'G': '--.',
    'H': '....',
    'I': '..',
    'J': '.---',
    'K': '-.-',
    'L': '.-..',
    'M': '--',
    'N': '-.',
    'O': '---',
    'P': '.--.',
    'Q': '--.-',
    'R': '.-.',
    'S': '...',
    'T': '-',
    'U': '..-',
    'V': '...-',
    'W': '.--',
    'X': '-..-',
    'Y': '-.--',
    'Z': '--..',
  };

  List<String> _currentOptions = [];
  List<String> _weakLetters = [];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _generateNewCard();
  }

  void _generateNewCard() {
    final letters = widget.reviewLetters ?? _morseMap.keys.toList();
    final rng = Random();
    _correctAnswer = letters[rng.nextInt(letters.length)];

    final options = <String>{_correctAnswer};
    while (options.length < 4) {
      options.add(letters[rng.nextInt(letters.length)]);
    }

    setState(() {
      _currentIndex++;
      _isFrontVisible = true;
      _showResult = false;
      _selectedAnswer = null;
      _currentOptions = options.toList()..shuffle();
    });
  }

  void _checkAnswer(String selected) {
    final isCorrect = selected == _correctAnswer;
    setState(() {
      _selectedAnswer = selected;
      _showResult = true;
      if (isCorrect)
        _correctCount++;
      else
        _weakLetters.add(_correctAnswer);
    });

    HapticFeedback.vibrate();
    if (isCorrect) {
      _confettiController.play();
      AudioService.playSuccessTone();
    } else {
      AudioService.playErrorTone();
    }

    if (_currentIndex >= 10) {
      Future.delayed(const Duration(seconds: 2), _navigateToQuizSummary);
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _generateNewCard();
      });
    }
  }

  Future<void> _saveSessionData() async {
    final prefs = await SharedPreferences.getInstance();

    double currentXP = prefs.getDouble('xpProgress') ?? 0.0;
    double sessionXP = _correctCount / 10;
    currentXP = (currentXP + sessionXP).clamp(0.0, 1.0);
    await prefs.setDouble('xpProgress', currentXP);

    int currentStreak = prefs.getInt('dayStreak') ?? 0;
    currentStreak++;
    await prefs.setInt('dayStreak', currentStreak);

    final existing = prefs.getString('unlockedLetters') ?? '';
    final unlocked = existing.isEmpty
        ? <String>{}
        : existing.split(',').toSet();
    unlocked.addAll(widget.reviewLetters ?? _morseMap.keys.toList());
    await prefs.setString('unlockedLetters', unlocked.join(','));

    final existingWeak = prefs.getString('weakLetters') ?? '';
    final weakSet = existingWeak.isEmpty
        ? <String>{}
        : existingWeak.split(',').toSet();
    weakSet.addAll(_weakLetters);
    await prefs.setString('weakLetters', weakSet.join(','));
  }

  void _navigateToQuizSummary() async {
    await _saveSessionData();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizSummaryScreen(
          correctAnswers: _correctCount,
          totalQuestions: 10,
          weakLetters: _weakLetters,
        ),
      ),
    );
  }

  void _flipCard() {
    if (_flipController.isCompleted || _flipController.isDismissed) {
      _isFrontVisible ? _flipController.forward() : _flipController.reverse();
      _isFrontVisible = !_isFrontVisible;
      AudioService.playFlipSound();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161825),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 26),
          onPressed: () => _showExitConfirmation(context),
        ),
        title: Text(
          'Flashcards',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3A3C51),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildBackgroundPattern(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _currentIndex / 10,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF3CC45B),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orange.shade400,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_correctCount Correct',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return Rotation3DTransition(
                        animation: animation,
                        child: child,
                      );
                    },
                    child: _isFrontVisible
                        ? _buildFrontCard()
                        : _buildBackCard(),
                  ),
                ),
                const SizedBox(height: 24),
                if (_showResult && _selectedAnswer != _correctAnswer)
                  Text(
                    'Wrong! Correct Answer: $_correctAnswer',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  )
                else if (_showResult && _selectedAnswer == _correctAnswer)
                  Text(
                    'Correct!',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  _isFrontVisible
                      ? 'What letter is this?'
                      : 'The Morse code for:',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    padding: const EdgeInsets.only(bottom: 20),
                    children: _currentOptions.map((option) {
                      final isCorrect = _showResult && option == _correctAnswer;
                      final isWrong =
                          _showResult &&
                          _selectedAnswer == option &&
                          option != _correctAnswer;

                      return ElevatedButton(
                        onPressed: _showResult
                            ? null
                            : () => _checkAnswer(option),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>((
                                states,
                              ) {
                                if (isCorrect)
                                  return const Color(
                                    0xFF3CC45B,
                                  ).withOpacity(0.2);
                                if (isWrong) return Colors.red.withOpacity(0.2);
                                return Colors.white;
                              }),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>((
                                states,
                              ) {
                                if (isCorrect) return const Color(0xFF3CC45B);
                                if (isWrong) return Colors.red;
                                return const Color(0xFFF9C244);
                              }),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                          elevation: MaterialStateProperty.all(6),
                          shadowColor: MaterialStateProperty.all(
                            Colors.black.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          option,
                          style: GoogleFonts.robotoMono(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
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

  Widget _buildFrontCard() {
    return Container(
      key: const ValueKey('front'),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          _morseMap[_correctAnswer] ?? '',
          style: GoogleFonts.robotoMono(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3CC45B),
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      key: const ValueKey('back'),
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3C51),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          _correctAnswer,
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.03,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 60,
          ),
          itemBuilder: (context, index) {
            return Center(
              child: Text(
                _morseMap.values.elementAt(index % _morseMap.length),
                style: const TextStyle(fontSize: 24),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Exit App?"),
        content: const Text("Are you sure you want to exit the app?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // dismiss dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop(); // Close app on Android
              } else {
                exit(0); // Close app on iOS
              }
            },
            child: const Text("Exit"),
          ),
        ],
      ),
    );
  }
}

class Rotation3DTransition extends AnimatedWidget {
  final Animation<double> animation;
  final Widget child;

  const Rotation3DTransition({
    super.key,
    required this.animation,
    required this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(animation.value * 3.141592),
      alignment: Alignment.center,
      child: child,
    );
  }
}
