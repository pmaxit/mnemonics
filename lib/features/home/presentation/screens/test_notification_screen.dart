import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mnemonics/core/services/notification_manager.dart';

class TestNotificationScreen extends ConsumerWidget {
  const TestNotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notifications'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Simulate receiving a notification
                final notificationManager = ref.read(notificationManagerProvider);
                notificationManager.showNotification(
                  title: 'Test Notification',
                  message: 'This is a test notification message',
                );
                
                // Show a snackbar as well
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Send Test Notification'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Try to get the FCM token
                try {
                  final token = await FirebaseMessaging.instance.getToken();
                  if (token != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('FCM Token: $token'),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to get FCM token'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error getting FCM token: $e'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Get FCM Token'),
            ),
          ],
        ),
      ),
    );
  }
}