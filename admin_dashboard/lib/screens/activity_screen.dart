import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});
  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(activityLogsProvider);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Activity Logs', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => ref.invalidate(activityLogsProvider)),
          const SizedBox(width: 6),
        ],
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) {
          final types = logs.map((e) => e.activityType).toSet().toList()..sort();
          final filtered = selectedType == null ? logs : logs.where((l) => l.activityType == selectedType).toList();
          return Column(children: [
            FutureBuilder<Map<String, int>>(
              future: ref.read(apiServiceProvider).fetchLogTypes(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox();
                final counts = snap.data!;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Wrap(spacing: 8, children: counts.entries.map((e) => Chip(
                    label: Text('${e.key} · ${e.value}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                  )).toList()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                const Text('Filter:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(width: 10),
                DropdownButton<String?>(
                  value: selectedType,
                  hint: const Text('All types', style: TextStyle(fontSize: 12)),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All', style: TextStyle(fontSize: 12))),
                    ...types.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))),
                  ],
                  onChanged: (v) => setState(() => selectedType = v),
                ),
                const Spacer(),
                Text('${filtered.length} / ${logs.length}', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final l = filtered[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: AppTheme.primarySoft, child: Text(l.userId.split('_').last, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary))),
                      title: Text(l.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const SizedBox(height: 2),
                        Row(children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(6)), child: Text(l.activityType, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
                          const SizedBox(width: 8),
                          Text(DateFormat('MMM d, HH:mm').format(l.timestamp), style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                        ]),
                        if (l.context.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(l.context.toString(), style: const TextStyle(fontSize: 10, color: AppTheme.muted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ]);
        },
      ),
    );
  }
}
