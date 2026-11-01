import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/in_app_review_service.dart';
import '../../../core/services/locator.dart';
import '../../../core/services/session_cubit.dart';
import '../../../core/services/session_state.dart';
import '../../auth/cubit/auth_repository.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../../../core/widgets/guest_gate.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../model/profile_overview.dart';
import '../model/profile_stats.dart';
import '../widgets/profile_hub_shimmer.dart';
import '../widgets/profile_logout_dialog.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_sliver_header.dart';
import '../../auth/model/user_model.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GuestGate(
      title: 'Account required',
      message:
          'Log in to open your profile. Save your details once and book faster every time you play.',
      child: BlocBuilder<SessionCubit, SessionState>(
        buildWhen: (p, c) => p.user?.id != c.user?.id,
        builder: (context, session) {
          final cubit = getIt<ProfileCubit>()..load();
          return BlocProvider.value(
            key: ValueKey('profile-${session.user?.id}'),
            value: cubit,
            child: const _ProfileHub(),
          );
        },
      ),
    );
  }
}

class _ProfileHub extends StatelessWidget {
  const _ProfileHub();

  Future<void> _logout(BuildContext context) async {
    final ok = await showProfileLogoutDialog(context);
    if (!ok || !context.mounted) return;
    // Server revoke + local clear, same as auth switch-account.
    // AuthRepository.logout clears locally even if the revoke fails.
    await getIt<AuthRepository>().logout();
    if (!context.mounted) return;
    context.go(AppRoutes.splash);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final ok = await showDeleteAccountDialog(context);
    if (!ok || !context.mounted) return;
    final cubit = context.read<ProfileCubit>();
    final deleted = await cubit.deleteAccount();
    if (!context.mounted) return;
    if (deleted) {
      context.go(AppRoutes.splash);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cubit.state.errorMessage.isEmpty
              ? 'Could not delete account'
              : cubit.state.errorMessage,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          final overview = state.overview;
          final user =
              overview?.user ?? context.read<SessionCubit>().state.user;

          return AppLoadingHandler(
            status: state.status,
            errorMessage: state.errorMessage,
            onRetry: cubit.load,
            loading: const ProfileHubShimmer(),
            child: user == null
                ? const SizedBox.shrink()
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      ProfileSliverHeader(
                        user: user,
                        stats: overview?.stats ?? const ProfileStats(),
                        onEdit: () => context.push(AppRoutes.editProfile),
                        onBookings: () => context.go(AppRoutes.bookings),
                        onNotifications: () =>
                            context.push(AppRoutes.notifications),
                      ),
                      SliverPadding(
                        padding: const .fromLTRB(20, 22, 20, 110),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _ProfileMenus(
                              user: user,
                              overview: overview,
                              onLogout: () => _logout(context),
                              onDeleteAccount: () => _deleteAccount(context),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _ProfileMenus extends StatelessWidget {
  const _ProfileMenus({
    required this.user,
    required this.overview,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  final UserModel user;
  final ProfileOverview? overview;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        const ProfileSectionTitle('General'),
        10.h,
        ProfileMenuCard(
          children: [
            ProfileMenuTile(
              icon: Icons.event_available_outlined,
              label: 'My bookings',
              onTap: () => context.go(AppRoutes.bookings),
            ),
            ProfileMenuTile(
              icon: Icons.favorite_border_rounded,
              label: 'Saved venues',
              trailing: overview == null
                  ? null
                  : '${overview!.stats.savedVenuesCount}',
              onTap: () => context.push(AppRoutes.savedVenues),
            ),
            ProfileMenuTile(
              icon: Icons.rate_review_outlined,
              label: 'My reviews',
              trailing: overview == null
                  ? null
                  : '${overview!.stats.reviewsCount}',
              onTap: () => context.push(AppRoutes.myReviews),
            ),
            ProfileMenuTile(
              icon: Icons.star_border_rounded,
              label: 'Rate us',
              onTap: () {
                AppHaptics.selection();
                getIt<InAppReviewService>().openFromMenu();
              },
            ),
          ],
        ),
        22.h,
        const ProfileSectionTitle('Settings'),
        10.h,
        ProfileMenuCard(
          children: [
            ProfileMenuTile(
              icon: Icons.manage_accounts_outlined,
              label: 'Account controls',
              onTap: () => context.push(AppRoutes.accountControls),
            ),
            ProfileMenuTile(
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              onTap: () => context.push(AppRoutes.notificationSettings),
            ),
            ProfileMenuTile(
              icon: Icons.language_rounded,
              label: 'Language',
              trailing: user.languageLabel,
              onTap: () => context.push(AppRoutes.language),
            ),
            ProfileMenuTile(
              icon: Icons.payments_outlined,
              label: 'Payment preference',
              trailing: user.paymentLabel,
              onTap: () => context.push(AppRoutes.paymentPreference),
            ),
          ],
        ),
        22.h,
        const ProfileSectionTitle('About app'),
        10.h,
        ProfileMenuCard(
          children: [
            ProfileMenuTile(
              icon: Icons.gavel_outlined,
              label: 'Legal and information',
              onTap: () => context.push(AppRoutes.legal),
            ),
            ProfileMenuTile(
              icon: Icons.help_outline_rounded,
              label: 'Help and support',
              onTap: () => context.push(AppRoutes.helpSupport),
            ),
          ],
        ),
        16.h,
        ProfileMenuCard(
          children: [
            ProfileMenuTile(
              icon: Icons.logout_rounded,
              label: 'Log out',
              destructive: true,
              onTap: onLogout,
            ),
            ProfileMenuTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete account',
              destructive: true,
              onTap: onDeleteAccount,
            ),
          ],
        ),
        16.h,
        Text(
          overview?.versionFooter ?? 'Pitchside v1.4.0 (build 214)',
          textAlign: .center,
          style: context.textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
