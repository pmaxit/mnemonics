import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../common/design/design_system.dart';
import '../../providers/study_plan_providers.dart';

class CreatePlanDialog extends ConsumerStatefulWidget {
  const CreatePlanDialog({super.key});

  @override
  ConsumerState<CreatePlanDialog> createState() => _CreatePlanDialogState();
}

class _CreatePlanDialogState extends ConsumerState<CreatePlanDialog> {
  int _totalWords = 50;
  int _wordsPerDay = 10;
  DateTime _startDate = DateTime.now();
  bool _isCreating = false;

  int get _totalDays => (_totalWords / _wordsPerDay).ceil();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Handle bar
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),

          Text('Create Study Plan', style: MnemonicsTypography.headingMedium.copyWith(
              color: isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary)),
          const SizedBox(height: 8),
          Text('AI will create an optimized study schedule', style: TextStyle(fontSize: 14,
              color: isDark ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary)),
          const SizedBox(height: 24),

          // Total words
          _buildSliderField('Total Words', _totalWords, 10, 200, (v) => setState(() => _totalWords = v.round()), isDark),
          const SizedBox(height: 16),

          // Words per day
          _buildSliderField('Words Per Day', _wordsPerDay, 3, 30, (v) => setState(() => _wordsPerDay = v.round()), isDark),
          const SizedBox(height: 16),

          // Start date
          _buildDatePicker(isDark),
          const SizedBox(height: 16),

          // Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MnemonicsColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MnemonicsColors.primaryGreen.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, color: MnemonicsColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(
                '$_totalWords words over $_totalDays days ($_wordsPerDay/day) starting ${DateFormat('MMM d').format(_startDate)}',
                style: TextStyle(fontSize: 13, color: isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary),
              )),
            ]),
          ),
          const SizedBox(height: 24),

          // Create button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isCreating ? null : _createPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: MnemonicsColors.primaryGreen, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              child: _isCreating
                  ? const Row(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      SizedBox(width: 12),
                      Text('AI is planning...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ])
                  : const Text('Create Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _buildSliderField(String label, int value, double min, double max,
      ValueChanged<double> onChanged, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
            color: isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: MnemonicsColors.primaryGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('$value', style: const TextStyle(fontWeight: FontWeight.bold,
              fontSize: 16, color: MnemonicsColors.primaryGreen)),
        ),
      ]),
      Slider(
        value: value.toDouble(), min: min, max: max, divisions: (max - min).toInt(),
        activeColor: MnemonicsColors.primaryGreen,
        inactiveColor: MnemonicsColors.primaryGreen.withValues(alpha: 0.2),
        onChanged: onChanged,
      ),
    ]);
  }

  Widget _buildDatePicker(bool isDark) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context, initialDate: _startDate,
          firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _startDate = picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? MnemonicsColors.darkSurface : MnemonicsColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today, color: MnemonicsColors.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Start Date', style: TextStyle(fontSize: 12,
                color: isDark ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary)),
            Text(DateFormat('EEEE, MMM d, y').format(_startDate),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                    color: isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary)),
          ]),
          const Spacer(),
          Icon(Icons.chevron_right,
              color: isDark ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary),
        ]),
      ),
    );
  }

  Future<void> _createPlan() async {
    setState(() => _isCreating = true);
    try {
      final notifier = ref.read(studyPlanNotifierProvider.notifier);
      await notifier.createPlan(
        totalWords: _totalWords,
        wordsPerDay: _wordsPerDay,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create plan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }
}
