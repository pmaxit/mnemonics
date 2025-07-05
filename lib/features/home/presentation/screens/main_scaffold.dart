import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/widgets/bottom_nav.dart';
import '../../providers.dart';
import 'home_screen.dart';
import '../../../practice/presentation/screens/practice_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../practice/presentation/screens/timer_screen.dart';

class MainScaffold extends ConsumerWidget {
  final Widget? child;
  const MainScaffold({super.key, this.child});

  static const List<Widget> _tabBodies = [
    HomeScreen(),
    PracticeScreen(),
    TimerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(homeTabIndexProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mnemonics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: child ?? IndexedStack(
        index: tabIndex,
        children: _tabBodies,
      ),
      bottomNavigationBar: MnemonicsBottomNav(
        currentIndex: tabIndex,
        onTap: (index) {
          ref.read(homeTabIndexProvider.notifier).state = index;
        },
      ),
    );
  }
} 