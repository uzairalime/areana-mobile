import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/enums/app_loading.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../cubit/games_cubit.dart';
import '../cubit/games_state.dart';
import '../model/game_post.dart';
import '../widgets/create_game_sheet.dart';
import '../widgets/game_post_card.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  Future<void> _create(BuildContext context) async {
    final cubit = context.read<GamesCubit>();
    await cubit.loadPostableBookings();
    if (!context.mounted) return;
    final result = await showCreateGameSheet(
      context,
      postableBookings: cubit.state.postableBookings,
    );
    if (result == null || !context.mounted) return;
    final ok = await cubit.createGame(
      bookingId: result.bookingId,
      playersNeeded: result.playersNeeded,
      squadSize: result.squadSize,
      level: result.level,
      note: result.note,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Your game is posted' : 'Could not post your game',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Games'),
        actions: [
          IconButton(
            onPressed: () => _create(context),
            icon: const Icon(Icons.add),
            tooltip: 'Post a game',
          ),
        ],
      ),
      body: BlocBuilder<GamesCubit, GamesState>(
        buildWhen: (p, c) =>
            p.status != c.status ||
            p.games != c.games ||
            p.errorMessage != c.errorMessage ||
            p.isLoadingMore != c.isLoadingMore,
        builder: (context, state) {
          if (state.status.isLoading) {
            return AppLoadingHandler(
              status: state.status,
              child: const SizedBox.shrink(),
            );
          }
          if (state.status.isError && state.games.isEmpty) {
            return _ErrorView(
              message: state.errorMessage,
              onRetry: () => context.read<GamesCubit>().load(),
            );
          }
          if (state.games.isEmpty) {
            return _EmptyView(onCreate: () => _create(context));
          }
          return RefreshIndicator(
            onRefresh: () => context.read<GamesCubit>().refresh(),
            child: ListView.separated(
              padding: const .fromLTRB(
                AppSizes.pagePadding,
                12,
                AppSizes.pagePadding,
                110,
              ),
              itemCount:
                  state.games.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (_, _) => 12.h,
              itemBuilder: (context, index) {
                if (index >= state.games.length) {
                  if (!state.isLoadingMore) {
                    context.read<GamesCubit>().loadMore();
                  }
                  return const Padding(
                    padding: .symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final game = state.games[index];
                final cubit = context.read<GamesCubit>();
                return GamePostCard(
                  game: game,
                  managing: state.isManaging(game.id),
                  onTap: () => context.push(
                    '/games/detail/${game.id}',
                    extra: game,
                  ),
                  onJoin: game.canJoin
                      ? () => cubit.joinGame(game.id)
                      : null,
                  onLeave: game.canLeave
                      ? () => cubit.leaveGame(game.id)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        48,
        AppSizes.pagePadding,
        110,
      ),
      children: [
        Text(
          'No open games yet',
          textAlign: .center,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: .w800,
          ),
        ),
        8.h,
        Text(
          'Post a game from one of your confirmed bookings and find players.',
          textAlign: .center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        20.h,
        FilledButton(onPressed: onCreate, child: const Text('Post a game')),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        48,
        AppSizes.pagePadding,
        110,
      ),
      children: [
        Text(
          message.isEmpty ? 'Could not load games' : message,
          textAlign: .center,
          style: context.textTheme.bodyMedium,
        ),
        20.h,
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
