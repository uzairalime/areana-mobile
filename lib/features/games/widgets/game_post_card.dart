import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/money_format.dart';
import '../model/game_post.dart';

class GamePostCard extends StatelessWidget {
  const GamePostCard({
    super.key,
    required this.game,
    required this.onTap,
    this.onJoin,
    this.onLeave,
    this.managing = false,
  });

  final GamePost game;
  final VoidCallback onTap;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final bool managing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Padding(
          padding: const .all(16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  Text(
                    game.sport,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: .w800,
                    ),
                  ).expand(),
                  _StatusChip(status: game.status),
                ],
              ),
              4.h,
              Text(
                game.placeLine,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              8.h,
              Text(
                '${game.date} · ${game.timeLabel} · ${game.playersLine}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (game.level != null && game.level!.isNotEmpty) ...[
                4.h,
                Text(
                  'Level: ${game.level}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (game.pricePerPlayer != null) ...[
                4.h,
                Text(
                  '${MoneyFormat.pkr(game.pricePerPlayer!.toInt())} per player',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: .w700,
                  ),
                ),
              ],
              if (game.note != null && game.note!.isNotEmpty) ...[
                8.h,
                Text(game.note!, style: context.textTheme.bodyMedium),
              ],
              if (game.isJoined || game.isPending) ...[
                8.h,
                Text(
                  game.isJoined ? 'You joined this game' : 'Join request sent',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: .w700,
                  ),
                ),
              ],
              if (onJoin != null || onLeave != null) ...[
                12.h,
                Row(
                  children: [
                    if (onJoin != null)
                      Expanded(
                        child: FilledButton(
                          onPressed: managing ? null : onJoin,
                          child: const Text('Join game'),
                        ),
                      ),
                    if (onLeave != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: managing ? null : onLeave,
                          child: const Text('Leave'),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final GamePostStatus status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status == .open
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: 10, vertical: 4),
        child: Text(
          status.label,
          style: context.textTheme.labelSmall?.copyWith(
            fontWeight: .w800,
            color: status == .open ? AppColors.primary : null,
          ),
        ),
      ),
    );
  }
}
