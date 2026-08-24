import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key});
  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController(text: '🎉 New update for all learners');
  final _body = TextEditingController(text: 'New words and spaced-repetition improvements are live. Open the app and keep your streak!');
  NotificationSchemeType _scheme = NotificationSchemeType.general;
  NotificationPriority _priority = NotificationPriority.high;
  final _targetUserId = TextEditingController();
  final _targetSegment = TextEditingController();
  bool _sending = false;
  String? _result;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _targetUserId.dispose();
    _targetSegment.dispose();
    super.dispose();
  }

  Future<void> _submit({bool andSend = false}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _sending = true; _result = null; });
    try {
      final api = ref.read(apiServiceProvider);
      final n = await api.createNotification(
        title: _title.text.trim(),
        body: _body.text.trim(),
        schemeType: _scheme,
        priority: _priority,
        targetUserId: _scheme == NotificationSchemeType.personalized ? _targetUserId.text.trim() : null,
        targetUserSegment: _targetSegment.text.trim().isEmpty ? null : _targetSegment.text.trim(),
      );
      if (andSend) await api.sendNotification(n.id);
      if (!mounted) return;
      setState(() => _result = andSend ? 'Sent to ${n.schemeType.name} (id ${n.id}) ✓' : 'Created as pending (id ${n.id}) — app clients will fetch on next poll.');
      ref.invalidate(notificationsProvider);
      ref.invalidate(statsProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_result!), backgroundColor: const Color(0xFF10B981)));
    } catch (e) {
      setState(() => _result = 'Error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showUserId = _scheme == NotificationSchemeType.personalized;
    final hint = _scheme == NotificationSchemeType.general
        ? 'All users will receive this (leave User ID empty). Uses GET /api/notifications?status=sent polling.'
        : _scheme == NotificationSchemeType.custom
            ? 'Custom message — leave User ID empty for broadcast.'
            : 'Personalized — enter a userId (e.g. user_1) to target one learner.';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Compose Notification', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Send to all users', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(hint, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<NotificationSchemeType>(
                        initialValue: _scheme,
                        decoration: const InputDecoration(labelText: 'Scheme'),
                        items: const [
                          DropdownMenuItem(value: NotificationSchemeType.general, child: Text('General — broadcast to all')),
                          DropdownMenuItem(value: NotificationSchemeType.custom, child: Text('Custom — admin message')),
                          DropdownMenuItem(value: NotificationSchemeType.personalized, child: Text('Personalized — one user')),
                        ],
                        onChanged: (v) => setState(() => _scheme = v!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<NotificationPriority>(
                        initialValue: _priority,
                        decoration: const InputDecoration(labelText: 'Priority'),
                        items: NotificationPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                        onChanged: (v) => setState(() => _priority = v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                      const SizedBox(height: 12),
                      TextFormField(controller: _body, decoration: const InputDecoration(labelText: 'Body'), maxLines: 4, validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                      const SizedBox(height: 12),
                      if (showUserId) ...[
                        TextFormField(controller: _targetUserId, decoration: const InputDecoration(labelText: 'Target User ID', hintText: 'e.g. user_1'), validator: (v) => _scheme == NotificationSchemeType.personalized && (v == null || v.trim().isEmpty) ? 'User ID required for personalized' : null),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(controller: _targetSegment, decoration: const InputDecoration(labelText: 'Target Segment (optional)', hintText: 'e.g. streak_7_days')),
                      const SizedBox(height: 18),
                      Row(children: [
                        Expanded(child: FilledButton.icon(
                          onPressed: _sending ? null : () => _submit(andSend: true),
                          icon: _sending ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded, size: 18),
                          label: Text(_scheme == NotificationSchemeType.general ? 'Send to all users' : 'Create & Send'),
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: OutlinedButton(onPressed: _sending ? null : () => _submit(andSend: false), child: const Text('Save as pending'))),
                      ]),
                      if (_result != null) ...[
                        const SizedBox(height: 12),
                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _result!.startsWith('Error') ? const Color(0xFFFEE2E2) : const Color(0xFFDEF7EC), borderRadius: BorderRadius.circular(10)), child: Text(_result!, style: TextStyle(fontSize: 12, color: _result!.startsWith('Error') ? const Color(0xFF991B1B) : const Color(0xFF065F46)))),
                      ],
                    ]),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('How delivery works', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      const SizedBox(height: 8),
                      const Text('1. This creates a notification at POST /api/notifications (status: pending).\n2. Send marks it sent (POST /api/notifications/:id/send).\n3. Your Flutter app polls GET /api/notifications?status=sent to show an in-app banner. For real push (FCM), wire FCM next.', style: TextStyle(fontSize: 11, color: AppTheme.muted, height: 1.5)),
                      const SizedBox(height: 10),
                      SelectableText('API: ${ref.read(apiServiceProvider).baseUrl}', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
