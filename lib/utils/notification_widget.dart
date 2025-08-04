import 'package:flutter/material.dart';

class NotificationIconWithBadge extends StatelessWidget {
  final int notificationCount; // Count of notifications to display on the badge

  NotificationIconWithBadge({required this.notificationCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Allow overflow to show the badge
      children: [
        IconButton(
          icon: Icon(
            size: 34,
            Icons.notifications,
            color: Colors.white, // Change this to your desired icon color
          ),
          onPressed: () {
            // Handle the notification icon press
          },
        ),
        if (notificationCount > 0) // Show badge only if there are notifications
          Positioned(
            right: 6, // Adjust position
            top: 6, // Adjust position
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple, // Badge color
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              constraints: BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                '$notificationCount', // Display the notification count
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
