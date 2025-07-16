import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/widgets/bottom_nav.dart';
import '../../providers.dart';
import 'home_screen.dart';
import '../../../practice/presentation/screens/practice_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../practice/presentation/screens/timer_screen.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/widgets/animated_wave_background.dart';

class MainScaffold extends StatelessWidget {
  final Widget? child;
  const MainScaffold({super.key, this.child});

  static const List<String> _tabPaths = [
    '/main/home',
    '/main/practice',
    '/main/timer',
    '/main/profile',
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    for (int i = 0; i < _tabPaths.length; i++) {
      if (location.startsWith(_tabPaths[i])) {
        currentIndex = i;
        break;
      }
    }
    final isTopLevelTab = _tabPaths.any((path) => location == path);

    // Determine if we are on the word list screen
    final isWordListScreen = RegExp(r'^/main/word-list/[^/]+').hasMatch(location);

    return Stack(
      children: [
        // Background covers the entire screen
        const Positioned.fill(
          child: AnimatedWaveBackground(height: double.infinity),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text(isWordListScreen ? 'Word List' : 'Mnemonics'),
            automaticallyImplyLeading: false,
            leading: isTopLevelTab
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          body: child != null ? child! : const SizedBox.shrink(),
          bottomNavigationBar: CustomBottomNavBar(
            currentTab: AppTab.values[currentIndex],
            onTabSelected: (tab) {
              final index = AppTab.values.indexOf(tab);
              if (currentIndex != index) {
                context.go(_tabPaths[index]);
              }
            },
            showNotificationDot: currentIndex != 3, // Example: show dot unless on Profile
          ),
        ),
      ],
    );
  }
} 