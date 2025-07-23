import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memory_hack_app/screens/flash_card_screen.dart';
import 'package:memory_hack_app/screens/profile_screen.dart';
import 'package:memory_hack_app/screens/tree_screen.dart';
import 'package:memory_hack_app/theme/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  late TabController _tabController;

  final List<Widget> _screens = [
    const TreeScreen(),
    const FlashcardScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
            _tabController.animateTo(0);
          });
          return false;
        } else {
          final shouldExit = await _showExitConfirmation(context);
          return shouldExit ?? false;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),
        bottomNavigationBar: _buildAnimatedNavBar(),
      ),
    );
  }

  Widget _buildAnimatedNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
              _tabController.animateTo(index);
              HapticFeedback.lightImpact();
            },
            elevation: 10,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.secondary,
            selectedItemColor: AppColors.primaryCTA,
            unselectedItemColor: AppColors.textLight.withOpacity(0.6),
            selectedLabelStyle:
                GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.montserrat(),
            items: [
              BottomNavigationBarItem(
                icon: _AnimatedNavIcon(
                  icon: Icons.account_tree_outlined,
                  isActive: _selectedIndex == 0,
                ),
                label: 'Tree',
              ),
              BottomNavigationBarItem(
                icon: _AnimatedNavIcon(
                  icon: Icons.flash_on,
                  isActive: _selectedIndex == 1,
                ),
                label: 'Flashcards',
              ),
              BottomNavigationBarItem(
                icon: _AnimatedNavIcon(
                  icon: Icons.person,
                  isActive: _selectedIndex == 2,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Exit App?'),
        content: const Text('Do you want to exit Morse Memory Hack?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.secondaryCTA,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryCTA,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

class _AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _AnimatedNavIcon({
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.identity()..scale(isActive ? 1.2 : 1.0),
      child: Icon(
        icon,
        size: 26,
      ),
    );
  }
}
