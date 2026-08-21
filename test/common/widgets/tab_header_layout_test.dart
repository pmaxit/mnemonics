import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnemonics/common/design/design_system.dart';
import 'package:mnemonics/common/layout/tab_screen_layout.dart';
import 'package:mnemonics/common/widgets/animated_tab_header_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const statusBarHeight = 24.0;

  Future<void> setPhoneSurface(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(top: statusBarHeight);
    tester.view.viewPadding = const FakeViewPadding(top: statusBarHeight);
    addTearDown(tester.view.reset);
  }

  Widget wrapWithTabChrome(Widget body) {
    return MaterialApp(
      home: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          title: const Text('Mnemonics'),
          automaticallyImplyLeading: false,
        ),
        body: body,
      ),
    );
  }

  Widget header({
    required String title,
    required String subtitle,
    Widget? trailing,
    EdgeInsetsGeometry? margin,
  }) {
    return AnimatedTabHeaderCard(
      isDarkMode: false,
      margin: margin,
      leading: const TabHeaderBadge(
        child: Icon(Icons.school, color: Colors.white, size: 24),
      ),
      title: title,
      subtitle: subtitle,
      trailing: trailing ??
          const TabHeaderTrailingIcon(
            icon: Icons.auto_awesome,
            color: MnemonicsColors.secondaryOrange,
          ),
    );
  }

  Widget nextCard() {
    return Container(
      key: TabScreenLayout.nextCardKey,
      height: 80,
      width: double.infinity,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Text('Next card'),
    );
  }

  testWidgets('header cards have a fixed height for every tab variant',
      (tester) async {
    await setPhoneSurface(tester);

    final titles = [
      ('Good Morning, Puneet!', 'Ready to expand your vocabulary?'),
      ('Your Progress', 'Track your learning journey'),
      ('Learning Session', 'Enhance your vocabulary with smart flashcards'),
      ('Puneet Girdhar', 'Learning since January 2024'),
    ];

    final heights = <double>[];
    for (final entry in titles) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: header(title: entry.$1, subtitle: entry.$2),
          ),
        ),
      );
      await tester.pumpAndSettle();
      heights.add(tester.getSize(find.byKey(TabScreenLayout.headerKey)).height);
    }

    expect(heights, everyElement(TabScreenLayout.headerHeight));
    expect(heights.toSet(), hasLength(1));
  });

  testWidgets(
      'home, practice, learn, and profile headers land on the same Y and leave the same gap',
      (tester) async {
    await setPhoneSurface(tester);

    final results = <String,
        ({
          double headerTop,
          double headerHeight,
          double nextTop,
          double appBarBottom,
          double headerLeft,
        })>{};

    Future<void> capture(String tab, Widget body) async {
      await tester.pumpWidget(wrapWithTabChrome(body));
      await tester.pumpAndSettle();

      final appBar = tester.getRect(find.byType(AppBar));
      final headerRect = tester.getRect(find.byKey(TabScreenLayout.headerKey));
      final nextRect = tester.getRect(find.byKey(TabScreenLayout.nextCardKey));
      results[tab] = (
        headerTop: headerRect.top,
        headerHeight: headerRect.height,
        nextTop: nextRect.top,
        appBarBottom: appBar.bottom,
        headerLeft: headerRect.left,
      );
    }

    await capture(
      'home',
      Builder(
        builder: (context) => ListView(
          padding: TabScreenLayout.paddedScrollPadding(context),
          children: [
            header(
              title: 'Good Morning, Puneet!',
              subtitle: 'Ready to expand your vocabulary?',
              margin: EdgeInsets.zero,
            ),
            const SizedBox(height: TabScreenLayout.afterHeaderGap),
            nextCard(),
          ],
        ),
      ),
    );

    await capture(
      'practice',
      Builder(
        builder: (context) => SingleChildScrollView(
          padding: TabScreenLayout.paddedScrollPadding(context),
          child: Column(
            children: [
              header(
                title: 'Your Progress',
                subtitle: 'Track your learning journey',
                margin: EdgeInsets.zero,
                trailing: const TabHeaderTrailingIcon(
                  icon: Icons.analytics,
                  color: MnemonicsColors.secondaryOrange,
                ),
              ),
              const SizedBox(height: TabScreenLayout.afterHeaderGap),
              nextCard(),
            ],
          ),
        ),
      ),
    );

    await capture(
      'learn',
      Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            top: TabScreenLayout.contentTop(context),
            bottom: TabScreenLayout.bottomNavClearance,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: TabScreenLayout.horizontalPadding,
            ),
            child: Column(
              children: [
                header(
                  title: 'Learning Session',
                  subtitle: 'Enhance your vocabulary with smart flashcards',
                  margin: EdgeInsets.zero,
                  trailing: const TabHeaderTrailingIcon(
                    icon: Icons.play_arrow,
                    color: MnemonicsColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: TabScreenLayout.afterHeaderGap),
                nextCard(),
              ],
            ),
          ),
        ),
      ),
    );

    await capture(
      'profile',
      Builder(
        builder: (context) => Padding(
          padding: TabScreenLayout.paddedScrollPadding(context),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    header(
                      title: 'Puneet Girdhar',
                      subtitle: 'Learning since January 2024',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: MnemonicsSpacing.s,
                          vertical: MnemonicsSpacing.xs,
                        ),
                        child: const Text('3d'),
                      ),
                    ),
                    const SizedBox(height: TabScreenLayout.afterHeaderGap),
                  ],
                ),
              ),
              SliverToBoxAdapter(child: nextCard()),
            ],
          ),
        ),
      ),
    );

    final home = results['home']!;
    for (final tab in ['practice', 'learn', 'profile']) {
      final other = results[tab]!;
      expect(other.headerHeight, home.headerHeight,
          reason: '$tab header height should match home');
      expect(other.headerTop, home.headerTop,
          reason: '$tab header should land on the same Y as home');
      expect(other.nextTop, home.nextTop,
          reason: '$tab next card should start at the same Y as home');
      expect(other.headerLeft, home.headerLeft,
          reason: '$tab header left edge should match home');
    }

    expect(home.headerHeight, TabScreenLayout.headerHeight);
    expect(
      home.headerTop - home.appBarBottom,
      TabScreenLayout.topGap,
      reason: 'gap from app bar to header should be exactly topGap',
    );
    expect(
      home.nextTop - (home.headerTop + home.headerHeight),
      TabScreenLayout.afterHeaderGap,
      reason: 'gap from header to next card should be exactly afterHeaderGap',
    );
  });
}
