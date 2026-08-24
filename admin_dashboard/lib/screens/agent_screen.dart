import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class AgentScreen extends ConsumerStatefulWidget {
  const AgentScreen({super.key});
  @override
  ConsumerState<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends ConsumerState<AgentScreen> {
  bool _running = false;
  String? _msg;

  Future<void> _runAgent() async {
    setState(() {
      _running = true;
      _msg = null;
    });
    try {
      final list = await ref.read(apiServiceProvider).triggerAgent();
      ref.invalidate(suggestionsProvider);
      ref.invalidate(statsProvider);
      setState(
          () => _msg = 'Agent created ${list.length} new suggestion(s).');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_msg!),
              backgroundColor: const Color(0xFF10B981)),
        );
      }
    } catch (e) {
      setState(() => _msg = 'Agent failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Widget _suggestionCard(AgentSuggestion s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppTheme.primarySoft,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(s.suggestedScheme.name,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppTheme.bg,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(s.priority.name,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                Text('${(s.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Text(s.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 6),
            Text(s.body,
                style: const TextStyle(fontSize: 12, color: AppTheme.text)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_rounded,
                      size: 14, color: AppTheme.muted),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(s.reasoning,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.muted))),
                ],
              ),
            ),
            if (s.targetUserId != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Target: ${s.targetUserId}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.muted)),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      await ref
                          .read(apiServiceProvider)
                          .applySuggestion(s.id);
                      ref.invalidate(suggestionsProvider);
                      ref.invalidate(notificationsProvider);
                      ref.invalidate(statsProvider);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Applied — notification created'),
                                backgroundColor: Color(0xFF10B981)));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed: $e'),
                            backgroundColor: Colors.red));
                      }
                    }
                  },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Apply'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(apiServiceProvider)
                          .discardSuggestion(s.id);
                      ref.invalidate(suggestionsProvider);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Discarded')));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed: $e'),
                            backgroundColor: Colors.red));
                      }
                    }
                  },
                  child: const Text('Discard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ref.watch(suggestionsProvider);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Agent Suggestions',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _running ? null : _runAgent,
              icon: _running
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(_running ? 'Analyzing…' : 'Run analysis'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_msg != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _msg!.startsWith('Agent failed')
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFDEF7EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_msg!,
                  style: TextStyle(
                      fontSize: 12,
                      color: _msg!.startsWith('Agent failed')
                          ? const Color(0xFF991B1B)
                          : const Color(0xFF065F46))),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.smart_toy_rounded,
                        color: AppTheme.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Agentic: reads activity logs → suggests the next study step per user (scheme: personalized / general / custom). Apply to create a notification, then Send.',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.muted,
                            height: 1.4),
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: () =>
                            ref.invalidate(suggestionsProvider)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: suggestions.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.red, size: 40),
                      const SizedBox(height: 12),
                      Text('Error loading suggestions:\n$e',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppTheme.text, fontSize: 13)),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () =>
                            ref.invalidate(suggestionsProvider),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              size: 48,
                              color: AppTheme.primary.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text('No suggestions yet',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16)),
                          const SizedBox(height: 8),
                          const Text(
                            'Run the agent analysis to inspect user activity logs\nand generate intelligent study reminders.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppTheme.muted, fontSize: 12),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _running ? null : _runAgent,
                            icon: _running
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.auto_awesome_rounded,
                                    size: 18),
                            label: Text(_running
                                ? 'Analyzing…'
                                : 'Run AI analysis now'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final pending = list.where((s) => !s.applied).toList();
                final applied = list.where((s) => s.applied).toList();
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Pending · ${pending.length}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppTheme.muted)),
                    const SizedBox(height: 8),
                    if (pending.isEmpty)
                      const Card(
                          child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                  child: Text('All caught up',
                                      style: TextStyle(
                                          color: AppTheme.muted))))),
                    for (final s in pending) _suggestionCard(s),
                    if (applied.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text('Applied · ${applied.length}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: AppTheme.muted)),
                      const SizedBox(height: 8),
                      for (final s in applied)
                        Card(
                          child: ListTile(
                            leading: const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF10B981)),
                            title: Text(s.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                            subtitle: Text(s.suggestedScheme.name,
                                style: const TextStyle(
                                    fontSize: 11, color: AppTheme.muted)),
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
