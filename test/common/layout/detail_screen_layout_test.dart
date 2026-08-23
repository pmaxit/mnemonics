import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnemonics/common/design/design_system.dart';
import 'package:mnemonics/common/layout/detail_screen_layout.dart';

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

  Widget buildDetailScreen({
    required String appBarTitle,
    required DetailSummaryRow summaryRow,
  }) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: MnemonicsColors.surface,
        appBar: DetailScreenAppBar(
          title: appBarTitle,
          isDarkMode: false,
          onBack: () {},
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: DetailScreenLayout.summaryCardOuterPadding,
                child: DetailSummaryCard(
                  isDarkMode: false,
                  child: summaryRow,
                ),
              ),
              Padding(
                padding: DetailScreenLayout.scrollBodyPadding,
                child: Container(
                  key: DetailScreenLayout.nextBlockKey,
                  height: 80,
                  color: Colors.grey.shade200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('detail summary card matches My Words geometry', (tester) async {
    await setPhoneSurface(tester);

    await tester.pumpWidget(
      buildDetailScreen(
        appBarTitle: 'My Words',
        summaryRow: DetailSummaryRow(
          isDarkMode: false,
          title: '20 words • Beginner',
          subtitle: 'Tap a word to study it',
          actionLabel: 'Practice all',
          onAction: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final myWordsSummary =
        tester.getRect(find.byKey(DetailScreenLayout.summaryCardKey));
    final myWordsNext =
        tester.getRect(find.byKey(DetailScreenLayout.nextBlockKey));
    final myWordsAppBar = tester.getRect(find.byType(AppBar));

    await tester.pumpWidget(
      buildDetailScreen(
        appBarTitle: 'Study Plan',
        summaryRow: DetailSummaryRow(
          isDarkMode: false,
          title: 'My First SPEECH Plan',
          subtitle: '100 words • 20 days • 5/day',
          actionLabel: 'Practice',
          onAction: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final studySummary =
        tester.getRect(find.byKey(DetailScreenLayout.summaryCardKey));
    final studyNext =
        tester.getRect(find.byKey(DetailScreenLayout.nextBlockKey));

    expect(studySummary.top - myWordsAppBar.bottom,
        DetailScreenLayout.topGap);
    expect(studySummary.left, DetailScreenLayout.horizontalPadding);
    expect(studySummary.width, myWordsSummary.width);
    expect(studySummary.height, myWordsSummary.height);
    expect(studyNext.top - studySummary.bottom,
        DetailScreenLayout.afterSummaryGap);
    expect(studySummary.top, myWordsSummary.top);
    expect(studyNext.top, myWordsNext.top);
  });
}
