import 'dart:core';

void main() {
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));

  final activeDays = <DateTime>{};

  // mock user data
  activeDays.add(DateTime(now.year, now.month, now.day));
  activeDays.add(DateTime(yesterday.year, yesterday.month, yesterday.day));

  // mock review activities
  activeDays.add(DateTime(now.year, now.month, now.day));
  activeDays.add(DateTime(yesterday.year, yesterday.month, yesterday.day));

  final sortedDays = activeDays.toList()..sort();
  print('sortedDays: $sortedDays');

  int longestStreak = 1;
  int currentStreak = 1;

  for (int i = 1; i < sortedDays.length; i++) {
    final differenceInHours =
        sortedDays[i].difference(sortedDays[i - 1]).inHours;
    final differenceInDays = (differenceInHours / 24).round();

    print('Comparing ${sortedDays[i]} with ${sortedDays[i - 1]}');
    print('differenceInHours = $differenceInHours');
    print('differenceInDays = $differenceInDays');

    if (differenceInDays == 1) {
      currentStreak++;
      longestStreak =
          longestStreak > currentStreak ? longestStreak : currentStreak;
    } else if (differenceInDays > 1) {
      currentStreak = 1;
    }
  }

  print('longestStreak = $longestStreak');
}
