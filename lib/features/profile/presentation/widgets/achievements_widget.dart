import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';
import '../../domain/user_statistics.dart';

class AchievementsWidget extends StatelessWidget {
  final List<Milestone> milestones;
  final bool isDarkMode;

  const AchievementsWidget({
    super.key,
    required this.milestones,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode 
        ? MnemonicsColors.darkSurface 
        : Colors.white;
    final textColor = isDarkMode 
        ? MnemonicsColors.darkTextPrimary 
        : MnemonicsColors.textPrimary;
    final secondaryTextColor = isDarkMode 
        ? MnemonicsColors.darkTextSecondary 
        : MnemonicsColors.textSecondary;

    final unlockedMilestones = milestones.where((m) => m.isUnlocked).toList();
    final nextMilestones = milestones.where((m) => !m.isUnlocked).take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: MnemonicsSpacing.m,
        vertical: MnemonicsSpacing.s,
      ),
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: isDarkMode 
            ? MnemonicsColors.darkCardShadow 
            : MnemonicsColors.cardShadow,
        border: isDarkMode 
            ? Border.all(
                color: MnemonicsColors.darkBorder.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Achievements',
                style: MnemonicsTypography.headingMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MnemonicsSpacing.s,
                  vertical: MnemonicsSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: MnemonicsColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
                ),
                child: Text(
                  '${unlockedMilestones.length}/${milestones.length}',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: MnemonicsColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          
          if (unlockedMilestones.isNotEmpty) ...[
            Text(
              'Recent Achievements',
              style: MnemonicsTypography.bodyLarge.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.s),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: unlockedMilestones.length,
                itemBuilder: (context, index) {
                  final milestone = unlockedMilestones[index];
                  return _buildAchievementCard(
                    milestone,
                    true,
                    textColor,
                    secondaryTextColor,
                  );
                },
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.m),
          ],
          
          if (nextMilestones.isNotEmpty) ...[
            Text(
              'Next Goals',
              style: MnemonicsTypography.bodyLarge.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.s),
            Column(
              children: nextMilestones.map((milestone) => 
                _buildProgressMilestone(milestone, textColor, secondaryTextColor)
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    Milestone milestone,
    bool isUnlocked,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: MnemonicsSpacing.s),
      padding: const EdgeInsets.all(MnemonicsSpacing.s),
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MnemonicsColors.primaryGreen,
                  MnemonicsColors.primaryGreen.withOpacity(0.7),
                ],
              )
            : null,
        color: isUnlocked ? null : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        border: isUnlocked
            ? null
            : Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            milestone.type.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: MnemonicsSpacing.xs),
          Text(
            milestone.title,
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isUnlocked ? Colors.white : textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isUnlocked) ...[
            const SizedBox(height: MnemonicsSpacing.xs),
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressMilestone(
    Milestone milestone,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final progress = milestone.currentValue / milestone.targetValue;
    final progressClamped = progress.clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
      padding: const EdgeInsets.all(MnemonicsSpacing.s),
      decoration: BoxDecoration(
        color: milestone.type.icon == '🔥' 
            ? Colors.orange.withOpacity(0.1)
            : MnemonicsColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                milestone.type.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title,
                      style: MnemonicsTypography.bodyLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      milestone.description,
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${milestone.currentValue}/${milestone.targetValue}',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          LinearProgressIndicator(
            value: progressClamped,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              milestone.type.icon == '🔥' 
                  ? Colors.orange
                  : MnemonicsColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}