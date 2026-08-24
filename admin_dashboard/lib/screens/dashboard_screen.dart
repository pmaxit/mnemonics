import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../widgets/stat_card.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final notifs = ref.watch(notificationsProvider);
    final suggestions = ref.watch(suggestionsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () {
            ref.invalidate(statsProvider);
            ref.invalidate(notificationsProvider);
            ref.invalidate(suggestionsProvider);
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          stats.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Stats error: $e'))),
            data: (s) => LayoutBuilder(builder: (context, c) {
              final w = c.maxWidth;
              final cols = w > 900 ? 4 : w > 600 ? 2 : 1;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.6,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                children: [
                  StatCard(label: 'Total notifications', value: '${s.totalNotifications}', icon: Icons.mail_rounded, accent: AppTheme.primary),
                  StatCard(label: 'Sent today', value: '${s.sentToday}', icon: Icons.check_circle_rounded, accent: const Color(0xFF0EA5E9)),
                  StatCard(label: 'Pending', value: '${s.pendingNotifications}', icon: Icons.schedule_rounded, accent: const Color(0xFFF59E0B)),
                  StatCard(label: 'Active users (24h)', value: '${s.activeUsersToday}', icon: Icons.people_rounded, accent: const Color(0xFF10B981)),
                  StatCard(label: 'Pending suggestions', value: '${s.pendingSuggestions}', icon: Icons.lightbulb_rounded, accent: const Color(0xFF8B5CF6)),
                  StatCard(label: 'Failed', value: '${s.failedNotifications}', icon: Icons.error_rounded, accent: const Color(0xFFEF4444)),
                ],
              );
            }),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Quick actions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(spacing: 10, runSpacing: 10, children: [
                FilledButton.icon(onPressed: () => context.go('/compose'), icon: const Icon(Icons.send_rounded, size: 18), label: const Text('Send to all users')),
                OutlinedButton.icon(onPressed: () => context.go('/agent'), icon: const Icon(Icons.auto_awesome_rounded, size: 18), label: const Text('Run agent analysis')),
                OutlinedButton.icon(onPressed: () => context.go('/activity'), icon: const Icon(Icons.history_rounded, size: 18), label: const Text('View activity')),
              ]),
              const SizedBox(height: 10),
              Text('API: ${ref.read(apiBaseUrlProvider)}', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            ])))),
          ]),
          const SizedBox(height: 18),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Recent notifications', style: TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                TextButton(onPressed: () => context.go('/notifications'), child: const Text('View all')),
              ]),
              const SizedBox(height: 8),
              notifs.when(
                loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                data: (list) {
                  if (list.isEmpty) return const Text('No notifications yet', style: TextStyle(color: AppTheme.muted));
                  return Column(children: list.take(5).map((n) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundColor: AppTheme.primarySoft, child: Icon(n.schemeType.name == 'general' ? Icons.campaign_rounded : n.schemeType.name == 'personalized' ? Icons.person_rounded : Icons.edit_rounded, color: AppTheme.primary, size: 18)),
                    title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    subtitle: Text(n.body, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: n.status.name == 'sent' ? const Color(0xFFDEF7EC) : const Color(0xFFFFF7D6), borderRadius: BorderRadius.circular(8)),
                      child: Text(n.status.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: n.status.name == 'sent' ? const Color(0xFF047857) : const Color(0xFF92400E))),
                    ),
                  )).toList());
                },
              ),
            ])))),
            const SizedBox(width: 14),
            Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Agent suggestions', style: TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                TextButton(onPressed: () => context.go('/agent'), child: const Text('Open')),
              ]),
              const SizedBox(height: 8),
              suggestions.when(
                loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                data: (list) {
                  final pending = list.where((s) => !s.applied).toList();
                  if (pending.isEmpty) return const Text('No pending suggestions — run the agent', style: TextStyle(color: AppTheme.muted, fontSize: 12));
                  return Column(children: pending.take(3).map((s) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(12)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(s.reasoning, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                      const SizedBox(height: 6),
                      Row(children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: Text(s.suggestedScheme.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
                        const SizedBox(width: 6),
                        Text('${(s.confidence * 100).toStringAsFixed(0)}% confidence', style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
                      ]),
                    ]),
                  )).toList());
                },
              ),
            ])))),
          ]),
        ]),
      ),
    );
  }
}
