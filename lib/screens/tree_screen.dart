import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memory_hack_app/theme/app_theme.dart';

class TreeScreen extends StatefulWidget {
  const TreeScreen({super.key});

  @override
  State<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends State<TreeScreen> 
    with SingleTickerProviderStateMixin {
  String _morseInput = '';
  String _decodedLetter = '';
  late AnimationController _highlightController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, String> _morseToLetter = {
    '.': 'E', '-': 'T',
    '..': 'I', '.-': 'A', '-.': 'N', '--': 'M',
    '...': 'S', '..-': 'U', '.-.': 'R', '.--': 'W',
    '-..': 'D', '-.-': 'K', '--.': 'G', '---': 'O',
    '....': 'H', '...-': 'V', '..-.': 'F', '.--.': 'P',
    '-...': 'B', '-..-': 'X', '-.-.': 'C', '-.--': 'Y',
    '--..': 'Z', '--.-': 'Q', '---.': 'Ö', '----': 'CH'
  };

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _highlightController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String type) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/dot.wav'));
    } catch (e) {
      debugPrint('Audio error: $e');
      HapticFeedback.heavyImpact();
    }
  }

  void _addInput(String symbol) async {
    HapticFeedback.lightImpact();
    await _playSound(symbol == '.' ? 'dot' : 'dash');
    
    setState(() {
      _morseInput += symbol;
      _decodedLetter = _morseToLetter[_morseInput] ?? '';
      _highlightController.forward(from: 0);
    });
  }

  void _reset() async {
    await _playSound('flip');
    setState(() {
      _morseInput = '';
      _decodedLetter = '';
    });
  }

  void _showEnhancedGuide() {
    int currentPage = 0;
    final pageController = PageController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.93,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: PageView(
                      controller: pageController,
                      onPageChanged: (index) => setState(() => currentPage = index),
                      children: [
                        _buildColorfulPage(
                          title: 'Morse Code & ETIAN Tree',
                          color: AppColors.secondaryCTA,
                          sections: [
                            _guideCard(
                              Icons.school,
                              'Morse Basics',
                              'Morse represents letters with dots (•) and dashes (−). Each letter has a unique pattern.',
                            ),
                            _guideCard(
                              Icons.account_tree,
                              'ETIAN Tree',
                              'It helps you decode letters by branching left (dot) or right (dash).',
                            ),
                            _guideCard(
                              Icons.flash_on, 
                              'Why It Works',
                              'It taps into spatial memory — making it easier to recall.',
                            ),
                          ],
                        ),
                        _buildColorfulPage(
                          title: 'Learning Goals & Tips',
                          color: AppColors.secondaryCTA,
                          sections: [
                            _guideCard(
                              Icons.flag, 
                              'Goals',
                              '✓ Recognize top 10 letters\n✓ Complete A–Z test\n✓ Decode short words',
                            ),
                            _guideCard(
                              Icons.psychology,
                              'Pro Tips',
                              'Say it aloud. Tap daily. Visualize the tree. Use mnemonics like “ETIAN the Alien”.',
                            ),
                          ],
                        ),
                        _buildColorfulPage(
                          title: 'Practice & Challenges',
                          color: AppColors.secondaryCTA,
                          sections: [
                            _guideCard(
                              Icons.extension, 
                              'Challenges',
                              '• •− → ?\n• −−•− → ?\n• Find "K" in the tree',
                            ),
                            _guideCard(
                              Icons.lightbulb, 
                              'Solo Practice', 
                              'Trace tree in your mind. Tap with eyes closed.',
                            ),
                            _guideCard(
                              Icons.check_circle_outline, 
                              'Answers',
                              '• •− = A\n• −−•− = Q\n• K = level 3: right-left-right',
                            ),
                          ],
                          isLastPage: true,
                          onLastPageButtonPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  if (currentPage > 0)
                    Positioned(
                      left: 10,
                      top: MediaQuery.of(context).size.height * 0.4,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: AppColors.textLight),
                        onPressed: () {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                      ),
                    ),
                  if (currentPage < 2)
                    Positioned(
                      right: 10,
                      top: MediaQuery.of(context).size.height * 0.4,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: AppColors.textLight),
                        onPressed: () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildColorfulPage({
    required String title,
    required Color color,
    required List<Widget> sections,
    bool isLastPage = false,
    VoidCallback? onLastPageButtonPressed,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...sections,
          if (isLastPage) ...[
            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }

  Widget _guideCard(IconData icon, String title, String content) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textLight, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textLight.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 60,
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.textLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ETIAN Tree Explorer'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
      ),
      body: Stack(
        children: [
          _buildBackgroundPattern(isTablet),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: 16,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: isTablet ? 300 : 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/etian_tree.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Placeholder(),
                      ),
                      _buildInteractiveTree(isTablet),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Input',
                        style: GoogleFonts.montserrat(
                          color: AppColors.textLight.withOpacity(0.8),
                          fontSize: isTablet ? 18 : 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _morseInput.isEmpty ? '⏳ Tap the tree' : _morseInput,
                        style: GoogleFonts.robotoMono(
                          fontSize: isTablet ? 36 : 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                      ),
                      if (_decodedLetter.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '→ $_decodedLetter',
                          style: TextStyle(
                            fontSize: isTablet ? 28 : 22,
                            color: AppColors.primaryCTA,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildControlButtons(isTablet),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showEnhancedGuide,
        icon: Icon(Icons.help_outline, color: AppColors.textLight),
        label: Text('Guide', style: TextStyle(color: AppColors.textLight)),
        backgroundColor: AppColors.primary,
        elevation: 4,
      ),
    );
  }

  Widget _buildInteractiveTree(bool isTablet) {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHotspot('.', 'E', isTablet, level: 1),
              SizedBox(width: isTablet ? 160 : 100),
              _buildHotspot('-', 'T', isTablet, level: 1),
            ],
          ),
          SizedBox(height: isTablet ? 40 : 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHotspot('..', 'I', isTablet, level: 2),
              SizedBox(width: isTablet ? 80 : 50),
              _buildHotspot('.-', 'A', isTablet, level: 2),
              SizedBox(width: isTablet ? 80 : 50),
              _buildHotspot('-.', 'N', isTablet, level: 2),
              SizedBox(width: isTablet ? 80 : 50),
              _buildHotspot('--', 'M', isTablet, level: 2),
            ],
          ),
          SizedBox(height: isTablet ? 40 : 30),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: isTablet ? 60 : 40,
            children: [
              _buildHotspot('...', 'S', isTablet, level: 3),
              _buildHotspot('..-', 'U', isTablet, level: 3),
              _buildHotspot('.-.', 'R', isTablet, level: 3),
              _buildHotspot('.--', 'W', isTablet, level: 3),
              _buildHotspot('-..', 'D', isTablet, level: 3),
              _buildHotspot('-.-', 'K', isTablet, level: 3),
              _buildHotspot('--.', 'G', isTablet, level: 3),
              _buildHotspot('---', 'O', isTablet, level: 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotspot(String path, String letter, bool isTablet, {required int level}) {
    final isActive = _morseInput == path;
    final size = isTablet ? 50.0 - (level * 5) : 40.0 - (level * 4);

    return GestureDetector(
      onTap: () => _addInput(path.endsWith('.') ? '.' : '-'),
      child: AnimatedBuilder(
        animation: _highlightController,
        builder: (context, child) {
          return Transform.scale(
            scale: isActive ? 1.1 + (_highlightController.value * 0.2) : 1.0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: isActive 
                    ? AppColors.primaryCTA.withOpacity(0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive 
                      ? AppColors.primaryCTA
                      : AppColors.primaryCTA.withOpacity(0.3),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: GoogleFonts.montserrat(
                    color: AppColors.primaryCTA,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButtons(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton('.', Icons.circle, isTablet),
        SizedBox(width: isTablet ? 24 : 16),
        _buildControlButton('-', Icons.remove, isTablet),
        SizedBox(width: isTablet ? 24 : 16),
        IconButton(
          icon: Icon(Icons.refresh, size: isTablet ? 28 : 24),
          onPressed: _reset,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.secondary,
            padding: EdgeInsets.all(isTablet ? 12 : 8),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(String symbol, IconData icon, bool isTablet) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: isTablet ? 22 : 18),
      label: Text(
        symbol == '.' ? 'Dot' : 'Dash',
        style: GoogleFonts.montserrat(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () => _addInput(symbol),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondaryCTA,
        foregroundColor: AppColors.textDark,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 16,
          vertical: isTablet ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern(bool isTablet) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.03,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: isTablet ? 80 : 60,
          ),
          itemBuilder: (context, index) {
            return Center(
              child: Text(
                '· –',
                style: TextStyle(
                  fontSize: isTablet ? 28 : 24,
                  color: AppColors.textLight,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}