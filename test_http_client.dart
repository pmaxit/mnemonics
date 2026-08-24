import 'dart:io';
import 'dart:convert';

/// Simple HTTP client to test notification server endpoints
class TestHttpClient {
  final String baseUrl;
  final HttpClient _client;

  TestHttpClient(this.baseUrl) : _client = HttpClient();

  /// Create a test notification
  Future<Map<String, dynamic>> createNotification({
    String title = 'Test Notification',
    String body = 'This is a test notification',
    String schemeType = 'general',
    String priority = 'medium',
  }) async {
    final request = await _client.postUrl(Uri.parse('$baseUrl/api/notifications'));
    request.headers.set('Content-Type', 'application/json');
    
    final bodyJson = jsonEncode({
      'title': title,
      'body': body,
      'schemeType': schemeType,
      'priority': priority,
    });
    
    request.write(bodyJson);
    final response = await request.close();
    
    final responseBody = await response.transform(utf8.decoder).join();
    return jsonDecode(responseBody);
  }

  /// Send notification via FCM
  Future<bool> sendNotificationToFcm(String notificationId, String token) async {
    final request = await _client.postUrl(
      Uri.parse('$baseUrl/api/notifications/$notificationId/send-fcm'));
    request.headers.set('Content-Type', 'application/json');
    
    final bodyJson = jsonEncode({'token': token});
    request.write(bodyJson);
    final response = await request.close();
    
    return response.statusCode == 200;
  }

  /// Mark notification as sent
  Future<bool> markNotificationAsSent(String notificationId) async {
    final request = await _client.postUrl(
      Uri.parse('$baseUrl/api/notifications/$notificationId/send'));
    final response = await request.close();
    
    return response.statusCode == 200;
  }

  /// Close the HTTP client
  void close() {
    _client.close();
  }
}

/// Test the notification flow
Future<void> main() async {
  final client = TestHttpClient('http://localhost:8080');
  
  try {
    print('Testing notification flow...\n');
    
    // Create notification
    print('1. Creating test notification...');
    final notification = await client.createNotification(
      title: 'Mobile App Test Notification',
      body: 'This notification was sent from a Dart script to test the mobile app',
      schemeType: 'general',
      priority: 'high',
    );
    
    final notificationId = notification['id'];
    print('✓ Created notification: $notificationId');
    print('Title: ${notification['title']}');
    print('Body: ${notification['body']}');
    
    // Check for device token
    final deviceToken = Platform.environment['TEST_DEVICE_TOKEN'];
    if (deviceToken != null && deviceToken.isNotEmpty) {
      print('\n2. Sending notification to device...');
      final success = await client.sendNotificationToFcm(notificationId, deviceToken);
      if (success) {
        print('✓ Notification sent to device via FCM');
        
        // Mark as sent
        final marked = await client.markNotificationAsSent(notificationId);
        if (marked) {
          print('✓ Notification marked as sent in database');
        } else {
          print('✗ Failed to mark notification as sent');
        }
      } else {
        print('✗ Failed to send notification to device');
      }
    } else {
      print('\nNote: No device token provided. Set TEST_DEVICE_TOKEN environment variable to send to device.');
      print('Example: export TEST_DEVICE_TOKEN="your_device_fcm_token"');
    }
    
    print('\nTest completed successfully!');
    
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}