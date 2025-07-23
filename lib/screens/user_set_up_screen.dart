import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memory_hack_app/screens/goal_screen.dart';
import 'package:memory_hack_app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key});

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _nameController = TextEditingController();
  String? _selectedRole;
  final List<String> _roles = ['Beginner', 'Hobbyist', 'Student'];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  Future<void> _saveUserInfo() async {
    if (_nameController.text.isEmpty || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text.trim());
      await prefs.setString('userRole', _selectedRole!);

      debugPrint('Saved name: ${_nameController.text.trim()}');

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const GoalScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error saving user info: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save profile'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.secondary], // ✅ Updated
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Complete Your Profile',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textLight, // ✅ Updated
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15), // ✅ Improved visibility
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(
                              color: AppColors.textLight, // ✅ Input text
                            ),
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              labelStyle: const TextStyle(
                                color: AppColors.textLight, // ✅ Label text
                              ),
                              prefixIcon: const Icon(Icons.person_outline,
                                  color: AppColors.textLight),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AppColors.textLight),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AppColors.primaryCTA),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "I'm a...",
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: AppColors.textLight, // ✅ Updated
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: _roles.map((role) {
                              return ChoiceChip(
                                label: Text(
                                  role,
                                  style: const TextStyle(
                                    color: AppColors.textLight, // ✅ Chip label
                                  ),
                                ),
                                selectedColor: AppColors.primaryCTA, // ✅ Selected chip
                                backgroundColor:
                                    Colors.white.withOpacity(0.1), // ✅ Unselected chip
                                selected: _selectedRole == role,
                                onSelected: (val) =>
                                    setState(() => _selectedRole = role),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _saveUserInfo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryCTA, // ✅ Updated
                              foregroundColor: AppColors.textLight,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSaving
                                ? const CircularProgressIndicator(
                                    color: AppColors.textLight,
                                  )
                                : const Text('Continue'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
