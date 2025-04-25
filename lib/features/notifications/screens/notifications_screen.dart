// screens/notifications_screen.dart
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications, size: 80, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Notifications Screen',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
