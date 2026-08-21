import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/widgets/animated_tab_header_card.dart';
import '../../domain/user_info.dart';
import '../../domain/user_statistics.dart';
import '../../providers/user_info_provider.dart';
import 'package:intl/intl.dart';

class ProfileHeaderWidget extends ConsumerWidget {
  final UserStatistics profileStats;
  final bool isDarkMode;

  const ProfileHeaderWidget({
    super.key,
    required this.profileStats,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoAsync = ref.watch(currentUserProvider);

    return AnimatedTabHeaderCard(
      isDarkMode: isDarkMode,
      leading: TabHeaderBadge(
        child: Text(
          userInfoAsync.when(
            data: (userInfo) => userInfo.initials,
            loading: () => 'VL',
            error: (error, stack) => 'VL',
          ),
          style: MnemonicsTypography.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: userInfoAsync.when(
        data: (userInfo) => userInfo.displayName,
        loading: () => 'Loading...',
        error: (error, stack) => 'Vocabulary Learner',
      ),
      subtitle: _joinDateText(userInfoAsync),
      trailing: _buildStreakIndicator(),
    );
  }

  String _joinDateText(AsyncValue<UserInfo> userInfoAsync) {
    return userInfoAsync.when(
      data: (userInfo) {
        final formatter = DateFormat('MMMM yyyy');
        return 'Learning since ${formatter.format(userInfo.joinedDate)}';
      },
      loading: () => 'Loading your profile',
      error: (error, stack) {
        if (profileStats.joinDate != null) {
          final formatter = DateFormat('MMMM yyyy');
          return 'Learning since ${formatter.format(profileStats.joinDate!)}';
        }
        return 'Welcome to Mnemonics!';
      },
    );
  }

  Widget _buildStreakIndicator() {
    if (profileStats.currentStreak == 0) {
      return const TabHeaderTrailingIcon(
        icon: Icons.whatshot,
        color: Colors.grey,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MnemonicsSpacing.s,
        vertical: MnemonicsSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.8),
            Colors.red.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.whatshot,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: MnemonicsSpacing.xs),
          Text(
            '${profileStats.currentStreak}d',
            style: MnemonicsTypography.bodyRegular.copyWith(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
