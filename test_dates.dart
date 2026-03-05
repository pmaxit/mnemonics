import 'dart:core';

void main() {
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));

  final day1 = DateTime(yesterday.year, yesterday.month, yesterday.day);
  final day2 = DateTime(now.year, now.month, now.day);

  print('day1: $day1');
  print('day2: $day2');

  final duration = day2.difference(day1);
  print('duration in hours: ${duration.inHours}');
  print('duration in days: ${duration.inDays}');
}
