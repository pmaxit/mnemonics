import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = [
    (label: 'Dashboard', icon: Icons.dashboard_rounded, path: '/'),
    (label: 'Activity', icon: Icons.history_rounded, path: '/activity'),
    (label: 'Compose', icon: Icons.send_rounded, path: '/compose'),
    (label: 'Agent', icon: Icons.auto_awesome_rounded, path: '/agent'),
    (label: 'Notifications', icon: Icons.notifications_rounded, path: '/notifications'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    return Scaffold(
      body: Row(children: [
        Container(
          width: 260,
          decoration: BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: Colors.black.withValues(alpha: 0.06)))),
          child: Column(children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Mnemonics', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text('Admin', style: TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                ])),
              ]),
            ),
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ..._tabs.map((t) {
              final selected = loc == t.path || (t.path != '/' && loc.startsWith(t.path));
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.go(t.path),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primarySoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      Icon(t.icon, size: 20, color: selected ? AppTheme.primary : AppTheme.muted),
                      const SizedBox(width: 10),
                      Text(t.label, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? AppTheme.primary : AppTheme.text)),
                    ]),
                  ),
                ),
              );
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(12)),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.muted),
                  SizedBox(width: 8),
                  Expanded(child: Text('Agentic: reads activity logs → suggests next study step', style: TextStyle(fontSize: 11, color: AppTheme.muted))),
                ]),
              ),
            ),
          ]),
        ),
        Expanded(child: child),
      ]),
    );
  }
}
