import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/enums/app_loading.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/money_format.dart';
import '../cubit/games_cubit.dart';
import '../cubit/games_state.dart';
import '../model/game_post.dart';

class GameDetailScreen extends StatelessWidget {
  const GameDetailScreen({super.key, required this.game});

  final GamePost game;

  static GamePost? resolve(GoRouterState state) {
    final extra = state.extra;
    if (extra is GamePost) return extra;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamesCubit, GamesState>(
      buildWhen: (p, c) =>
          p.detail != c.detail ||
          p.detailStatus != c.detailStatus ||
          p.managingId != c.managingId ||
          p.errorMessage != c.errorMessage,
      builder: (context, state) {
        final detail = state.detail;
        final game = detail?.post ?? this.game;
        final cubit = context.read<GamesCubit>();
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text(game.sport)),
          body: ListView(
            padding: const .fromLTRB(
              AppSizes.pagePadding,
              16,
              AppSizes.pagePadding,
              32,
            ),
            children: [
              Text(
                game.placeLine,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: .w800,
                ),
              ),
              8.h,
              Text(
                '${game.date} · ${game.timeLabel}',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              8.h,
              Text(
                game.playersLine,
                style: context.textTheme.bodyMedium,
              ),
              if (game.level != null && game.level!.isNotEmpty) ...[
                8.h,
                Text('Level: ${game.level}'),
              ],
              if (game.courtName != null) ...[
                8.h,
                Text('Court: ${game.courtName}'),
              ],
              if (game.pricePerPlayer != null) ...[
                8.h,
                Text(
                  '${MoneyFormat.pkr(game.pricePerPlayer!.toInt())} per player · pay at ground',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: .w700,
                  ),
                ),
              ],
              if (game.note != null && game.note!.isNotEmpty) ...[
                16.h,
                Text(game.note!),
              ],
              if (state.detailStatus.isLoading) ...[
                24.h,
                const Center(child: CircularProgressIndicator()),
              ],
              if (detail != null && detail.participants.isNotEmpty) ...[
                24.h,
                Text(
                  'Players',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: .w800,
                  ),
                ),
                8.h,
                for (final participant in detail.participants)
                  Padding(
                    padding: const .symmetric(vertical: 4),
                    child: Text(participant.name),
                  ),
              ],
              24.h,
              if (game.canJoin)
                FilledButton(
                  onPressed: state.isManaging(game.id)
                      ? null
                      : () => cubit.joinGame(game.id),
                  child: const Text('Join game'),
                ),
              if (game.canLeave)
                OutlinedButton(
                  onPressed: state.isManaging(game.id)
                      ? null
                      : () => cubit.leaveGame(game.id),
                  child: const Text('Leave game'),
                ),
              if (game.isJoined || game.isPending)
                Text(
                  game.isJoined
                      ? 'You joined this game'
                      : 'Join request sent — awaiting the host',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: .w700,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
