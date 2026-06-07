import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../common/design/design_system.dart';
import '../../providers/study_plan_providers.dart';
import '../../domain/study_plan.dart';
import '../widgets/study_calendar.dart';
import 'create_plan_dialog.dart';
import 'day_detail_screen.dart';

class StudyPlanScreen extends ConsumerWidget {
  const StudyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(studyPlanListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: MnemonicsColors.primaryGreen)),
        error: (err, _) => _ErrorView(onRetry: () => ref.invalidate(studyPlanListProvider)),
        data: (plans) {
          if (plans.isEmpty) return _EmptyState(onCreatePlan: () => _showCreatePlanDialog(context));
          final activePlan = plans.firstWhere((p) => p.status == 'active', orElse: () => plans.first);
          return _PlanView(plan: activePlan, allPlans: plans);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePlanDialog(context),
        backgroundColor: MnemonicsColors.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Plan', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showCreatePlanDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePlanDialog(),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: MnemonicsColors.textSecondary),
        const SizedBox(height: 16),
        const Text('Failed to load study plans', style: MnemonicsTypography.bodyLarge),
        TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Retry')),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreatePlan;
  const _EmptyState({required this.onCreatePlan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MnemonicsColors.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_month_outlined, size: 72,
                color: MnemonicsColors.primaryGreen.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),
          Text('No Study Plans Yet', style: MnemonicsTypography.headingMedium.copyWith(
              color: isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Create a study plan to organize your\nvocabulary learning journey',
              textAlign: TextAlign.center,
              style: MnemonicsTypography.bodyRegular.copyWith(
                  color: isDark ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onCreatePlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: MnemonicsColors.primaryGreen, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Create Your First Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }
}

class _PlanView extends ConsumerWidget {
  final StudyPlan plan;
  final List<StudyPlan> allPlans;
  const _PlanView({required this.plan, required this.allPlans});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planDetailAsync = ref.watch(activeStudyPlanProvider(plan.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return planDetailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: MnemonicsColors.primaryGreen)),
      error: (err, _) => Center(child: TextButton.icon(
          onPressed: () => ref.invalidate(activeStudyPlanProvider(plan.id)),
          icon: const Icon(Icons.refresh), label: const Text('Retry'))),
      data: (fullPlan) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _PlanHeader(plan: fullPlan),
          const SizedBox(height: 24),
          StudyCalendar(
            plan: fullPlan,
            onDayTapped: (day) => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => DayDetailScreen(
                planId: fullPlan.id, dayNumber: day.dayNumber,
                theme: day.theme ?? 'Day ${day.dayNumber}', scheduledDate: day.scheduledDate,
              ),
            )),
          ),
          const SizedBox(height: 24),
          _Legend(isDark: isDark),
          if (allPlans.length > 1) ...[
            const SizedBox(height: 24),
            _PlanSwitcher(plans: allPlans, currentPlanId: plan.id),
          ],
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  final StudyPlan plan;
  const _PlanHeader({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final startDate = DateTime.parse(plan.startDate);
    final endDate = startDate.add(Duration(days: plan.totalDays - 1));
    final completedDays = plan.days.where((d) => d.status == 'completed').length;
    final progress = plan.totalDays > 0 ? completedDays / plan.totalDays : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1B5E3E), const Color(0xFF0D3320)]
              : [MnemonicsColors.primaryGreen.withValues(alpha: 0.15), MnemonicsColors.primaryGreen.withValues(alpha: 0.05)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MnemonicsColors.primaryGreen.withValues(alpha: isDark ? 0.3 : 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_stories, color: MnemonicsColors.primaryGreen, size: 28),
          const SizedBox(width: 8),
          Expanded(child: Text(
            '${DateFormat('MMM d').format(startDate)} – ${DateFormat('MMM d').format(endDate)}',
            style: MnemonicsTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold,
                color: isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary),
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: plan.status == 'completed' ? MnemonicsColors.primaryGreen : MnemonicsColors.secondaryOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(plan.status.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _statChip('${plan.totalWords}', 'Words', Icons.abc, isDark),
          const SizedBox(width: 8),
          _statChip('${plan.wordsPerDay}', '/Day', Icons.today, isDark),
          const SizedBox(width: 8),
          _statChip('$completedDays/${plan.totalDays}', 'Days', Icons.check_circle_outline, isDark),
        ]),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress, minHeight: 6,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(MnemonicsColors.primaryGreen)),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).toInt()}% complete',
            style: TextStyle(fontSize: 12, color: isDark ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary)),
      ]),
    );
  }

  Widget _statChip(String value, String label, IconData icon, bool isDark) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 16, color: MnemonicsColors.primaryGreen),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
            color: isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary)),
        const SizedBox(width: 2),
        Text(label, style: TextStyle(fontSize: 11,
            color: isDark ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary)),
      ]),
    ));
  }
}

class _Legend extends StatelessWidget {
  final bool isDark;
  const _Legend({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _item(isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0), 'Not Started'),
      const SizedBox(width: 16),
      _item(const Color(0xFFFFC107), 'In Progress'),
      const SizedBox(width: 16),
      _item(MnemonicsColors.primaryGreen, 'Completed'),
    ]);
  }

  Widget _item(Color color, String label) => Row(children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color.withValues(alpha: 0.5)))),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12,
            color: isDark ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary)),
      ]);
}

class _PlanSwitcher extends ConsumerWidget {
  final List<StudyPlan> plans;
  final int currentPlanId;
  const _PlanSwitcher({required this.plans, required this.currentPlanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('All Plans', style: MnemonicsTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold,
          color: isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary)),
      const SizedBox(height: 8),
      ...plans.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () { ref.invalidate(studyPlanListProvider); },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.id == currentPlanId
                  ? MnemonicsColors.primaryGreen.withValues(alpha: 0.1)
                  : isDark ? MnemonicsColors.darkSurface : MnemonicsColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.id == currentPlanId
                  ? MnemonicsColors.primaryGreen.withValues(alpha: 0.3) : Colors.transparent),
            ),
            child: Row(children: [
              Icon(p.status == 'completed' ? Icons.check_circle : Icons.schedule, size: 20,
                  color: p.status == 'completed' ? MnemonicsColors.primaryGreen : MnemonicsColors.secondaryOrange),
              const SizedBox(width: 8),
              Expanded(child: Text('${p.totalWords} words · ${p.totalDays} days · ${p.startDate}',
                  style: TextStyle(fontSize: 13,
                      color: isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary))),
            ]),
          ),
        ),
      )),
    ]);
  }
}
