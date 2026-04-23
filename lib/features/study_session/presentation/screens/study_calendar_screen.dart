import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/study_plan.dart';
import '../../domain/study_plan_day.dart';
import '../../providers/study_session_providers.dart';
import '../widgets/calendar_heatmap_widget.dart';
import '../../theme/mnemonics_theme.dart';

class StudyCalendarScreen extends ConsumerWidget {
  const StudyCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(activePlansProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? MnemonicsColors.darkBackground : MnemonicsColors.surface,
      body: plansAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: MnemonicsColors.primaryIndigo),
        ),
        error: (e, _) => _buildError(context, e.toString()),
        data: (plans) =>
            plans.isEmpty ? _buildEmpty(context) : _buildPlanView(context, ref, plans.first),
      ),
      floatingActionButton: plansAsync.maybeWhen(
        data: (plans) => plans.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: () => context.push('/study-plan/create'),
                backgroundColor: MnemonicsColors.primaryGreen,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text('New Plan',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
        orElse: () => null,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty state — no active plan
  // ---------------------------------------------------------------------------
  Widget _buildEmpty(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MnemonicsColors.primaryGreen, Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL * 2),
                boxShadow: [
                  BoxShadow(
                    color: MnemonicsColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Icon(Icons.calendar_month_rounded,
                  size: 56, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const Text(
              'No active study plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create a personalized study plan and let\nGemini AI assign the perfect words for each day.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => context.push('/study-plan/create'),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Create Study Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Plan view — heatmap + stats
  // ---------------------------------------------------------------------------
  Widget _buildPlanView(
      BuildContext context, WidgetRef ref, StudyPlan plan) {
    final doneDays = plan.days.where((d) => d.status == DayStatus.done).length;
    final inProgressDays =
        plan.days.where((d) => d.status == DayStatus.inProgress).length;
    final progress = plan.numDays > 0 ? doneDays / plan.numDays : 0.0;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180,
          floating: false,
          pinned: true,
          backgroundColor: isDarkMode ? MnemonicsColors.darkBackground : Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? MnemonicsColors.darkBackground : Colors.white,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFF6366F1).withOpacity(0.4)),
                            ),
                            child: const Text(
                              '📅  Active Plan',
                              style: TextStyle(
                                color: Color(0xFF818CF8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        plan.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _statBadge('$doneDays done', const Color(0xFF22C55E)),
                          const SizedBox(width: 8),
                          _statBadge(
                              '$inProgressDays in progress', const Color(0xFFEAB308)),
                          const SizedBox(width: 8),
                          _statBadge(
                              '${plan.numDays - doneDays - inProgressDays} left',
                              const Color(0xFF64748B)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progress',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    Text('${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF1E293B),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF6366F1)),
                  ),
                ),
                const SizedBox(height: 28),
                const Text('Daily Calendar',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 16),
                // Heatmap
                CalendarHeatmapWidget(
                  plan: plan,
                  onDayTap: (day) => _openDay(context, ref, day),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openDay(BuildContext context, WidgetRef ref, StudyPlanDay day) {
    // Mark as in-progress when opened (if not already started/done)
    if (day.status == DayStatus.notAttempted) {
      ref
          .read(dayStatusNotifierProvider.notifier)
          .markInProgress(day.dayNumber);
    }
    context.push('/study-plan/day/${day.dayNumber}', extra: day);
  }

  Widget _statBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 16),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
