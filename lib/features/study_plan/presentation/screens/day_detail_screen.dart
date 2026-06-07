import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../common/design/design_system.dart';
import '../../providers/study_plan_providers.dart';
import '../../domain/study_plan.dart';

class DayDetailScreen extends ConsumerWidget {
  final int planId;
  final int dayNumber;
  final String theme;
  final String scheduledDate;

  const DayDetailScreen({
    super.key,
    required this.planId,
    required this.dayNumber,
    required this.theme,
    required this.scheduledDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayAsync = ref.watch(studyPlanDayProvider((planId: planId, dayNum: dayNumber)));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateTime.tryParse(scheduledDate);

    return Scaffold(
      backgroundColor: isDark ? MnemonicsColors.darkBackground : MnemonicsColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        foregroundColor: isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Day $dayNumber', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (date != null)
            Text(DateFormat('EEEE, MMM d').format(date),
                style: TextStyle(fontSize: 12, color: isDark ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary)),
        ]),
      ),
      body: dayAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: MnemonicsColors.primaryGreen)),
        error: (err, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Error loading day: $err'),
          TextButton.icon(
            onPressed: () => ref.invalidate(studyPlanDayProvider((planId: planId, dayNum: dayNumber))),
            icon: const Icon(Icons.refresh), label: const Text('Retry'),
          ),
        ])),
        data: (dayDetail) => _buildDayContent(context, ref, dayDetail, isDark),
      ),
    );
  }

  Widget _buildDayContent(BuildContext context, WidgetRef ref, StudyPlanDayDetail dayDetail, bool isDark) {
    final words = dayDetail.words;
    final completedCount = words.where((w) => w.status == 'done').length;
    final progress = words.isNotEmpty ? completedCount / words.length : 0.0;

    return Column(children: [
      // Theme & progress header
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2A2040), const Color(0xFF1A1530)]
                : [const Color(0xFFF3E5F5), const Color(0xFFEDE7F6)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome, color: MnemonicsColors.secondaryOrange, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(dayDetail.theme ?? theme,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress, minHeight: 8,
                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(MnemonicsColors.primaryGreen)),
            )),
            const SizedBox(width: 12),
            Text('$completedCount/${words.length}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
                    color: isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary)),
          ]),
        ]),
      ),

      // Word list
      Expanded(
        child: words.isEmpty
            ? Center(child: Text('No words assigned', style: TextStyle(
                color: isDark ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: words.length,
                itemBuilder: (context, index) {
                  final word = words[index];
                  return _WordTile(
                    word: word,
                    isDark: isDark,
                    onStatusChanged: (newStatus) {
                      ref.read(studyPlanNotifierProvider.notifier).updateWordStatus(
                        planId: planId, dayNum: dayNumber, word: word.word, status: newStatus,
                      );
                    },
                  );
                },
              ),
      ),
    ]);
  }
}

class _WordTile extends StatelessWidget {
  final StudyPlanWord word;
  final bool isDark;
  final ValueChanged<String> onStatusChanged;

  const _WordTile({required this.word, required this.isDark, required this.onStatusChanged});

  String get _nextStatus {
    switch (word.status) {
      case 'not_started': return 'in_progress';
      case 'in_progress': return 'done';
      case 'done': return 'not_started';
      default: return 'in_progress';
    }
  }

  IconData get _statusIcon {
    switch (word.status) {
      case 'done': return Icons.check_circle;
      case 'in_progress': return Icons.radio_button_checked;
      default: return Icons.radio_button_unchecked;
    }
  }

  Color get _statusColor {
    switch (word.status) {
      case 'done': return MnemonicsColors.primaryGreen;
      case 'in_progress': return const Color(0xFFFFC107);
      default: return isDark ? const Color(0xFF666666) : const Color(0xFFBDBDBD);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? MnemonicsColors.darkSurface : Colors.white,
      elevation: word.status == 'done' ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: word.status == 'done'
            ? BorderSide(color: MnemonicsColors.primaryGreen.withValues(alpha: 0.3))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => onStatusChanged(_nextStatus),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            // Status icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(_statusIcon, key: ValueKey(word.status), color: _statusColor, size: 28),
            ),
            const SizedBox(width: 14),
            // Word details
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(word.word,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                      color: isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                      decoration: word.status == 'done' ? TextDecoration.lineThrough : null)),
              if (word.meaning != null && word.meaning!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(word.meaning!, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13,
                        color: isDark ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary)),
              ],
            ])),
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word.status == 'not_started' ? 'Todo' : word.status == 'in_progress' ? 'Learning' : 'Done',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
