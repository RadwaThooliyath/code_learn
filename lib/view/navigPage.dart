import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/view/homePage.dart';
import 'package:uptrail/view/my_courses.dart';
import 'package:uptrail/view/enrolled_courses.dart';
import 'package:uptrail/view/my_teams.dart';
import 'package:uptrail/view/profile.dart';
import 'package:flutter/material.dart';

class Navigpage extends StatefulWidget {
  final int initialIndex;
  const Navigpage({super.key, this.initialIndex = 0});

  @override
  State<Navigpage> createState() => _NavigpageState();
}

class _NavigpageState extends State<Navigpage> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  final List<Widget> pages = [
    Homepage(),
    SelectedCoursesPage(),
    EnrolledCoursesPage(),
    MyTeamsPage(),
    UserProfilePage()
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.champagnePink,
      body: pages[selectedIndex],
      extendBody: true,
      bottomNavigationBar: Container(
        height: 90,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.card2.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.9),
              spreadRadius: 0,
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHotstarNavItem(Icons.home_filled, "Home", 0),
              _buildHotstarNavItem(Icons.library_books, "My List", 1),
              _buildHotstarNavItem(Icons.monetization_on, "Payments", 2),
              _buildHotstarNavItem(Icons.group, "Teams", 3),
              _buildHotstarNavItem(Icons.person, "Profile", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotstarNavItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemTapped(index),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Container(
            height: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with animated indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background glow for selected item
                    if (isSelected)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                    // Main icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : Colors.grey[400],
                        size: isSelected ? 28 : 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Label with fade animation
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isSelected ? 1.0 : 0.7,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Bottom indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isSelected ? 24 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
