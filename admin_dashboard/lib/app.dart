import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';
import 'screens/dashboard_screen.dart';
import 'screens/activity_screen.dart';
import 'screens/compose_screen.dart';
import 'screens/agent_screen.dart';
import 'screens/notifications_screen.dart';

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (c, s) => const DashboardScreen()),
        GoRoute(path: '/activity', builder: (c, s) => const ActivityScreen()),
        GoRoute(path: '/compose', builder: (c, s) => const ComposeScreen()),
        GoRoute(path: '/agent', builder: (c, s) => const AgentScreen()),
        GoRoute(path: '/notifications', builder: (c, s) => const NotificationsScreen()),
      ],
    ),
  ],
);

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mnemonics Admin',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
