import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../domain/profile_statistics.dart';
import '../../domain/user_info.dart';
import '../../providers/user_info_provider.dart';
import 'package:intl/intl.dart';

class ProfileHeaderWidget extends ConsumerStatefulWidget {
  final ProfileStatistics profileStats;
  final bool isDarkMode;

  const ProfileHeaderWidget({
    super.key,
    required this.profileStats,
    required this.isDarkMode,
  });

  @override
  ConsumerState<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends ConsumerState<ProfileHeaderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDarkMode 
        ? MnemonicsColors.darkSurface 
        : Colors.white;
    final textColor = widget.isDarkMode 
        ? MnemonicsColors.darkTextPrimary 
        : MnemonicsColors.textPrimary;
    final secondaryTextColor = widget.isDarkMode 
        ? MnemonicsColors.darkTextSecondary 
        : MnemonicsColors.textSecondary;
    
    final userInfoAsync = ref.watch(currentUserProvider);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(MnemonicsSpacing.m),
              padding: const EdgeInsets.all(MnemonicsSpacing.l),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                boxShadow: widget.isDarkMode 
                    ? MnemonicsColors.darkCardShadow 
                    : MnemonicsColors.cardShadow,
                border: widget.isDarkMode 
                    ? Border.all(
                        color: MnemonicsColors.darkBorder.withOpacity(0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Column(
                children: [
                  // Profile Avatar and Basic Info
                  Row(
                    children: [
                      _buildProfileAvatar(),
                      const SizedBox(width: MnemonicsSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getUserDisplayName(),
                              style: MnemonicsTypography.headingMedium.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: MnemonicsSpacing.xs),
                            Text(
                              _getJoinDateText(),
                              style: MnemonicsTypography.bodyRegular.copyWith(
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: MnemonicsSpacing.xs),
                            _buildStreakIndicator(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: MnemonicsSpacing.l),
                  
                  // Main Statistics Row
                  _buildMainStatistics(textColor, secondaryTextColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.rotate(
          angle: animation * 0.1,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MnemonicsColors.primaryGreen,
                  MnemonicsColors.primaryGreen.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: MnemonicsColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getUserInitials(),
                style: MnemonicsTypography.headingLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreakIndicator() {
    if (widget.profileStats.currentStreak == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MnemonicsSpacing.s,
          vertical: MnemonicsSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.whatshot,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: MnemonicsSpacing.xs),
            Text(
              'Start your streak!',
              style: MnemonicsTypography.bodyRegular.copyWith(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * animation),
          child: Container(
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
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                  '${widget.profileStats.currentStreak} day streak!',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainStatistics(Color textColor, Color secondaryTextColor) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Words Learned',
            widget.profileStats.totalWordsLearned.toString(),
            Icons.school,
            MnemonicsColors.primaryGreen,
            textColor,
            secondaryTextColor,
          ),
        ),
        _buildStatDivider(),
        Expanded(
          child: _buildStatItem(
            'Study Time',
            _formatStudyTime(widget.profileStats.totalStudyTimeMinutes),
            Icons.access_time,
            MnemonicsColors.secondaryOrange,
            textColor,
            secondaryTextColor,
          ),
        ),
        _buildStatDivider(),
        Expanded(
          child: _buildStatItem(
            'Accuracy',
            '${(widget.profileStats.averageAccuracy * 100).toStringAsFixed(1)}%',
            Icons.track_changes,
            _getAccuracyColor(widget.profileStats.averageAccuracy),
            textColor,
            secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Column(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(height: MnemonicsSpacing.xs),
            Text(
              value,
              style: MnemonicsTypography.headingMedium.copyWith(
                color: iconColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: secondaryTextColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: widget.isDarkMode 
          ? MnemonicsColors.darkBorder.withOpacity(0.3) 
          : MnemonicsColors.surface,
    );
  }

  String _getUserDisplayName() {
    final userInfoAsync = ref.watch(currentUserProvider);
    return userInfoAsync.when(
      data: (userInfo) => userInfo.displayName,
      loading: () => 'Loading...',
      error: (error, stack) => 'Vocabulary Learner',
    );
  }

  String _getUserInitials() {
    final userInfoAsync = ref.watch(currentUserProvider);
    return userInfoAsync.when(
      data: (userInfo) => userInfo.initials,
      loading: () => 'VL',
      error: (error, stack) => 'VL',
    );
  }

  String _getJoinDateText() {
    final userInfoAsync = ref.watch(currentUserProvider);
    return userInfoAsync.when(
      data: (userInfo) {
        final formatter = DateFormat('MMMM yyyy');
        return 'Learning since ${formatter.format(userInfo.joinedDate)}';
      },
      loading: () => 'Loading...',
      error: (error, stack) {
        if (widget.profileStats.joinDate != null) {
          final formatter = DateFormat('MMMM yyyy');
          return 'Learning since ${formatter.format(widget.profileStats.joinDate!)}';
        }
        return 'Welcome to Mnemonics!';
      },
    );
  }

  String _formatStudyTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      }
      return '${hours}h ${remainingMinutes}m';
    }
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.9) return Colors.green;
    if (accuracy >= 0.8) return MnemonicsColors.primaryGreen;
    if (accuracy >= 0.7) return MnemonicsColors.secondaryOrange;
    return Colors.red;
  }
}