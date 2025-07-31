import 'package:code_learn/app_constants/colors.dart';
import 'package:code_learn/view/homePage.dart';
import 'package:code_learn/view/my_courses.dart';
import 'package:code_learn/view/profile.dart';
import 'package:flutter/material.dart';

class Navigpage extends StatefulWidget {
  const Navigpage({super.key});

  @override
  State<Navigpage> createState() => _NavigpageState();
}

class _NavigpageState extends State<Navigpage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    Homepage(),
    SelectedCoursesPage(),
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
      backgroundColor: AppColors.background,
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.house),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: "My Courses",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
          selectedItemColor: AppColors.card1,
          unselectedItemColor: Colors.white,
          showUnselectedLabels: true,
          elevation: 0, // Removes shadow
        ),
      ),
    );
  }
}
