#!/usr/bin/env dart

/// Script to send a test notification to the notification server
/// 
/// This script demonstrates how to create and send a notification
/// to test the complete notification flow in the Mnemonics app.

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Send a test notification
Future<void> main() async {
  print('Sending test notification to notification server...');
  
  // Configuration - adjust these as needed
  final serverUrl = 'http://localhost:8080'; // Notification server URL
  
  try {
    // Step 1: Create a test notification
    print('\n1. Creating test notification...');
    final createResponse = await http.post(
      Uri.parse('$serverUrl/api/notifications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': 'Test Notification',
        'body': 'This is a test notification sent from our test script',
        'schemeType': 'general',
        'priority': 'medium',
      }),
    );
    
    if (createResponse.statusCode != 201) {
      print('Failed to create notification: ${createResponse.statusCode}');
      print(createResponse.body);
      return;
    }
    
    final notificationData = jsonDecode(createResponse.body);
    final notificationId = notificationData['id'];
    print('✓ Created notification with ID: $notificationId');
    
    print('\n2. Notification created successfully!');
    print('Title: ${notificationData['title']}');
    print('Body: ${notificationData['body']}');
    print('Status: ${notificationData['deliveryStatus']}');
    
    print('\n3. To send this notification to a device:');
    print('   a. Get your device FCM token from the app');
    print('   b. Set it as an environment variable: TEST_DEVICE_TOKEN');
    print('   c. Run: dart send_test_notification.dart --send-to-device');
    
    // Check if we should send to device
    if (Platform.environment['TEST_DEVICE_TOKEN'] != null) {
      final deviceToken = Platform.environment['TEST_DEVICE_TOKEN']!;
      print('\n4. Sending notification to device...');
      
      final sendResponse = await http.post(
        Uri.parse('$serverUrl/api/notifications/$notificationId/send-fcm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': deviceToken,
        }),
      );
      
      if (sendResponse.statusCode == 200) {
        print('✓ Successfully sent notification to device via FCM');
        
        // Mark as sent in database
        await http.post(
          Uri.parse('$serverUrl/api/notifications/$notificationId/send'),
        );
        print('✓ Marked notification as sent in database');
      } else {
        print('✗ Failed to send notification via FCM: ${sendResponse.statusCode}');
        print(sendResponse.body);
      }
    } else {
      print('\nNote: No device token provided. Set TEST_DEVICE_TOKEN environment variable to send to device.');
    }
    
    print('\nTest notification workflow completed!');
    
  } catch (e) {
    print('Error during notification test: $e');
  }
}

/// Send notification to device if requested
Future<void> sendToDevice(String serverUrl, String notificationId) async {
  final deviceToken = Platform.environment['TEST_DEVICE_TOKEN'];
  
  if (deviceToken == null || deviceToken.isEmpty) {
    print('No device token provided. Skipping device send.');
    return;
  }
  
  print('Sending notification to device...');
  final sendResponse = await http.post(
    Uri.parse('$serverUrl/api/notifications/$notificationId/send-fcm'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'token': deviceToken,
    }),
  );
  
  if (sendResponse.statusCode == 200) {
    print('Successfully sent notification to device');
  } else {
    print('Failed to send notification to device: ${sendResponse.statusCode}');
    print(sendResponse.body);
  }
}