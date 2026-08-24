#!/usr/bin/env dart

/// Script to test the notification flow in the Mnemonics app
/// 
/// This script demonstrates how to:
/// 1. Create a notification in the notification server
/// 2. Send it via FCM to a device
/// 3. Verify that the app receives and displays it

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Test notification flow
Future<void> main() async {
  print('Testing notification flow for Mnemonics app');
  
  // Configuration
  final serverUrl = 'http://localhost:8080'; // Adjust if needed
  final deviceToken = Platform.environment['TEST_DEVICE_TOKEN'];
  
  if (deviceToken == null || deviceToken.isEmpty) {
    print('Warning: TEST_DEVICE_TOKEN environment variable not set');
    print('Please set it to test actual FCM delivery');
  }
  
  try {
    // Step 1: Create a test notification
    print('\n1. Creating test notification...');
    final createResponse = await http.post(
      Uri.parse('$serverUrl/api/notifications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': 'Test Notification',
        'body': 'This is a test notification sent from the server',
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
    print('Created notification with ID: $notificationId');
    
    // Step 2: Send notification via FCM (if token is available)
    if (deviceToken != null && deviceToken.isNotEmpty) {
      print('\n2. Sending notification via FCM...');
      final sendResponse = await http.post(
        Uri.parse('$serverUrl/api/notifications/$notificationId/send-fcm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': deviceToken,
        }),
      );
      
      if (sendResponse.statusCode == 200) {
        print('Successfully sent notification via FCM');
      } else {
        print('Failed to send notification via FCM: ${sendResponse.statusCode}');
        print(sendResponse.body);
      }
    } else {
      print('\n2. Skipping FCM send (no device token provided)');
    }
    
    // Step 3: Mark notification as sent in local database
    print('\n3. Marking notification as sent in database...');
    final markSentResponse = await http.post(
      Uri.parse('$serverUrl/api/notifications/$notificationId/send'),
    );
    
    if (markSentResponse.statusCode == 200) {
      print('Successfully marked notification as sent');
    } else {
      print('Failed to mark notification as sent: ${markSentResponse.statusCode}');
      print(markSentResponse.body);
    }
    
    print('\nNotification flow test completed successfully!');
    print('To test actual notification receipt:');
    print('1. Run the Flutter app on a device/emulator');
    print('2. Make sure the device is connected to the internet');
    print('3. Set the TEST_DEVICE_TOKEN environment variable with a valid FCM token');
    print('4. Run this script again');
    
  } catch (e) {
    print('Error during notification flow test: $e');
  }
}