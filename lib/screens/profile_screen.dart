import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:memory_hack_app/theme/app_theme.dart';
import 'package:memory_hack_app/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String userName = "New User";
  String userRole = "Morse Learner";
  int currentLevel = 1;
  int totalXP = 0;
  double xpProgress = 0.0;
  int dailyGoal = 15;
  int dayStreak = 0;
  bool _isLoading = true;

  List<String> unlockedLetters = [];
  List<String> weakLetters = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadUserData();
    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userName = prefs.getString('userName') ?? "New User";
        userRole = prefs.getString('userRole') ?? "Morse Learner";
        currentLevel = prefs.getInt('currentLevel') ?? 1;
        xpProgress = prefs.getDouble('xpProgress') ?? 0.0;
        dailyGoal = prefs.getInt('dailyGoal') ?? 15;
        dayStreak = prefs.getInt('dayStreak') ?? 0;
        totalXP = (xpProgress * 100).toInt();
        final letters = prefs.getString('unlockedLetters');
        unlockedLetters = letters?.isNotEmpty == true ? letters!.split(',') : [];
        final weak = prefs.getString('weakLetters');
        weakLetters = weak?.isNotEmpty == true ? weak!.split(',') : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading) {
      _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF161825),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF3CC45B)),
              const SizedBox(height: 16),
              Text('Loading your profile...',
                  style: GoogleFonts.montserrat(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF161825),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(color: AppColors.primary),
                  child: SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 2),
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/profile_avatar.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Iconsax.user,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(userName,
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600)),
                          Text(userRole,
                              style: GoogleFonts.montserrat(
                                  color: Colors.white70, fontSize: 14)),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Iconsax.setting_2),
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()));
                    _loadUserData();
                  },
                  color: Colors.white,
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.6,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    padding: EdgeInsets.zero,
                    children: [
                      _buildStatItem(Iconsax.clock, '$dailyGoal min',
                          'Daily Goal'),
                      _buildStatItem(Iconsax.flash, '$totalXP', 'XP Points'),
                      _buildStatItem(Iconsax.book,
                          '${unlockedLetters.length}', 'Letters'),
                      _buildStatItem(Iconsax.calendar, '$dayStreak',
                          'Day Streak'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (weakLetters.isNotEmpty)
                    Card(
                      color: const Color(0xFF3A3C51),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Iconsax.warning_2,
                                    color: Color(0xFFF9C244)),
                                const SizedBox(width: 8),
                                Text('Need Practice',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFF9C244))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: weakLetters.map((letter) {
                                return Chip(
                                  label: Text(letter,
                                      style: GoogleFonts.montserrat(
                                          color: Colors.white)),
                                  deleteIcon: const Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                  onDeleted: () =>
                                      _removeWeakLetter(letter),
                                  backgroundColor: const Color(0xFF4F516A),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Card(
                    color: const Color(0xFF3A3C51),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Practice Goal',
                              style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [5, 10, 15, 20, 30, 45].map((minutes) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text('$minutes min'),
                                    selected: dailyGoal == minutes,
                                    onSelected: (selected) =>
                                        _updateDailyGoal(minutes),
                                    selectedColor: const Color(0xFF3CC45B),
                                    backgroundColor: Colors.grey.shade700,
                                    labelStyle: GoogleFonts.montserrat(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Iconsax.share),
                        label: const Text('Share Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3CC45B),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _shareProfile,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Iconsax.refresh),
                        label: const Text('Reset Progress'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF9C244),
                          side: const BorderSide(color: Color(0xFFF9C244)),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _showResetDialog,
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Card(
      color: const Color(0xFF3A3C51),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: const Color(0xFF3CC45B)),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.montserrat(
                    fontSize: 12, color: Colors.grey.shade300)),
          ],
        ),
      ),
    );
  }

  Future<void> _updateDailyGoal(int minutes) async {
    setState(() => dailyGoal = minutes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoal', dailyGoal);
  }

  Future<void> _removeWeakLetter(String letter) async {
    setState(() => weakLetters.remove(letter));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weakLetters', weakLetters.join(','));
  }

  void _shareProfile() {
    Share.share(
      '''
🚀 My Morse Code Progress 🚀

Name: $userName
Level: $currentLevel
XP: ${(xpProgress * 100).toInt()}%
Daily Goal: $dailyGoal mins
Streak: $dayStreak days

#MorseCodeMaster''',
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('This will clear all your learning data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetProgress();
            },
            child: const Text('Reset',
                style: TextStyle(color: Color(0xFFF9C244))),
          ),
        ],
      ),
    );
  }

  Future<void> _resetProgress() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        await _loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Progress reset successfully'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to reset progress'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
