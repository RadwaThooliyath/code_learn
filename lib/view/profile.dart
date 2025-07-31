import 'package:code_learn/app_constants/button.dart';
import 'package:flutter/material.dart';
import 'package:code_learn/app_constants/colors.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white24,
                backgroundImage: AssetImage(
                  'assets/images/profile_placeholder.png',
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileRow("Name", "John Doe"),
            _buildProfileRow("Email", "john.doe@example.com"),
            _buildProfileRow("Phone", "+91 9876543210"),
            _buildProfileRow("Enrolled Courses", "Flutter, Python"),
            _buildProfileRow("Total Fee", "₹15,000"),
            _buildProfileRow("Pending Fee", "₹5,000"),

            const SizedBox(height: 40),
            Button(text: "Edit Details", onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
