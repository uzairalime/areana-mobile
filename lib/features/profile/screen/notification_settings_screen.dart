import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/notification_settings_shimmer.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_subpage_scaffold.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadNotificationPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        final prefs = state.notificationPrefs;
        return ProfileSubpageScaffold(
          title: 'Notifications',
          body: AppLoadingHandler(
            status: state.status,
            errorMessage: state.errorMessage,
            onRetry: cubit.loadNotificationPrefs,
            loading: const NotificationSettingsShimmer(),
            child: ListView(
              padding: const .fromLTRB(20, 8, 20, 28),
              children: [
                const ProfileSectionTitle('Push notifications'),
                6.h,
                Text(
                  'What lands on your lock screen',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                10.h,
                ProfileMenuCard(
                  children: [
                    _Toggle(
                      title: 'Booking reminders',
                      subtitle: 'Upcoming slots and changes',
                      value: prefs.pushBooking,
                      onChanged: (v) => cubit.updateNotificationPrefs(
                        prefs.copyWith(pushBooking: v),
                      ),
                    ),
                    _Toggle(
                      title: 'Offers',
                      subtitle: 'Deals near you',
                      value: prefs.pushOffers,
                      onChanged: (v) => cubit.updateNotificationPrefs(
                        prefs.copyWith(pushOffers: v),
                      ),
                    ),
                    _Toggle(
                      title: 'Chat messages',
                      subtitle: 'Replies from venues and support',
                      value: prefs.pushChat,
                      onChanged: (v) => cubit.updateNotificationPrefs(
                        prefs.copyWith(pushChat: v),
                      ),
                    ),
                  ],
                ),
                22.h,
                const ProfileSectionTitle('Email'),
                6.h,
                Text(
                  'Receipts and updates in your inbox',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                10.h,
                ProfileMenuCard(
                  children: [
                    _Toggle(
                      title: 'Receipts',
                      subtitle: 'Booking confirmations',
                      value: prefs.emailReceipts,
                      onChanged: (v) => cubit.updateNotificationPrefs(
                        prefs.copyWith(emailReceipts: v),
                      ),
                    ),
                    _Toggle(
                      title: 'Product updates',
                      subtitle: 'What’s new from Pitchside',
                      value: prefs.emailUpdates,
                      onChanged: (v) => cubit.updateNotificationPrefs(
                        prefs.copyWith(emailUpdates: v),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: const .symmetric(horizontal: 14),
      title: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(fontWeight: .w700),
      ),
      subtitle: Text(
        subtitle,
        style: context.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      value: value,
      activeThumbColor: AppColors.accent,
      activeTrackColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}
