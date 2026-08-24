import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationsProvider);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => ref.invalidate(notificationsProvider)),
          const SizedBox(width: 6),
        ],
      ),
      body: notifs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('No notifications', style: TextStyle(color: AppTheme.muted)));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = list[i];
              final isSent = n.status.name == 'sent';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.primarySoft, borderRadius: BorderRadius.circular(8)), child: Text(n.schemeType.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary))),
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isSent ? const Color(0xFFDEF7EC) : const Color(0xFFFFF7D6), borderRadius: BorderRadius.circular(8)), child: Text(n.status.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isSent ? const Color(0xFF065F46) : const Color(0xFF92400E)))),
                      const Spacer(),
                      Text(DateFormat('MMM d, HH:mm').format(n.createdAt), style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                    ]),
                    const SizedBox(height: 10),
                    Text(n.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(n.body, style: const TextStyle(fontSize: 12, color: AppTheme.text)),
                    if (n.targetUserId != null || n.targetUserSegment != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Target: ${n.targetUserId ?? n.targetUserSegment ?? '—'}', style: const TextStyle(fontSize: 11, color: AppTheme.muted))),
                    const SizedBox(height: 10),
                    if (!isSent)
                      FilledButton.icon(
                        onPressed: () async {
                          try {
                            await ref.read(apiServiceProvider).sendNotification(n.id);
                            ref.invalidate(notificationsProvider);
                            ref.invalidate(statsProvider);
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent ✓ — app clients will see it on next poll'), backgroundColor: Color(0xFF10B981)));
                          } catch (e) {
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
                          }
                        },
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: const Text('Send now'),
                      )
                    else
                      Text('Sent ${n.sentAt != null ? DateFormat('MMM d HH:mm').format(n.sentAt!) : ''}', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
