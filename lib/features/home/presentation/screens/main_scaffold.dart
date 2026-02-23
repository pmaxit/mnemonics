import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../common/widgets/bottom_nav.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/widgets/animated_wave_background.dart';
import '../../../../common/design/design_system.dart';

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
    final isWordListScreen =
        RegExp(r'^/main/word-list/[^/]+').hasMatch(location);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Background covers the entire screen
        const Positioned.fill(
          child: AnimatedWaveBackground(height: double.infinity),
        ),
        Scaffold(
          appBar: AppBar(
            systemOverlayStyle: isDarkMode
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            title: isWordListScreen
                ? const Text('Word List',
                    style: MnemonicsTypography.headingMedium)
                : Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(MnemonicsSpacing.radiusS),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(MnemonicsSpacing.radiusS),
                          child: Image.asset(
                            'assets/images/logo.jpg',
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: MnemonicsSpacing.s),
                      Text(
                        'Mnemonics',
                        style: MnemonicsTypography.headingMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
            automaticallyImplyLeading: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
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
            showNotificationDot:
                currentIndex != 3, // Example: show dot unless on Profile
          ),
        ),
      ],
    );
  }
}
