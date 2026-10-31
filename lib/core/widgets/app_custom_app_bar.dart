import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';
import '../extensions/extensions.dart';
import '../services/session_cubit.dart';
import '../services/session_state.dart';
import 'profile_avatar.dart';

/// Shared top bar: [ProfileAvatar] + greeting + trailing action icons.
class AppCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppCustomAppBar({
    super.key,
    required this.onAvatarTap,
    required this.onNotifications,
    this.onMessages,
    this.showNotificationDot = true,
    this.backgroundColor = AppColors.background,
  });

  final VoidCallback onAvatarTap;
  final VoidCallback onNotifications;
  final VoidCallback? onMessages;
  final bool showNotificationDot;
  final Color backgroundColor;

  static const double _toolbarHeight = 68;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  static String greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _toolbarHeight,
          child: Padding(
            padding: const .symmetric(horizontal: AppSizes.pagePadding),
            child: BlocBuilder<SessionCubit, SessionState>(
              buildWhen: (previous, current) => previous.user != current.user,
              builder: (context, session) {
                final user = session.user;
                final isAuthed = session.isAuthenticated;
                final rawName = user?.name.trim() ?? '';
                final firstName = rawName.isEmpty
                    ? (isAuthed ? 'Player' : 'Guest')
                    : rawName.split(' ').first;
                final greeting = greetingFor(DateTime.now());

                return Row(
                  children: [
                    ProfileAvatar(
                      username: rawName.isEmpty ? firstName : rawName,
                      url: user?.avatarUrl,
                      size: 46,
                      fontSize: 15,
                    ).onTap(onAvatarTap),
                    12.w,
                    Column(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          greeting,
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: .w600,
                            fontSize: 12,
                            letterSpacing: 0.15,
                          ),
                        ),
                        3.h,
                        Text(
                          isAuthed ? firstName : 'Sign in',
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: .w800,
                            letterSpacing: -0.35,
                            height: 1.1,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ).onTap(onAvatarTap).expand(),
                    if (onMessages != null) ...[
                      AppBarIconButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        onTap: onMessages!,
                      ),
                      8.w,
                    ],
                    AppBarIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: onNotifications,
                      showDot: showNotificationDot && isAuthed,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class AppBarIconButton extends StatelessWidget {
  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: .circle,
          border: Border.all(color: AppColors.outline),
        ),
        child: Stack(
          clipBehavior: .none,
          children: [
            Icon(icon, size: 20, color: AppColors.text).center(),
            if (showDot)
              Positioned(
                top: 10,
                right: 11,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: .circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: const SizedBox(width: 9, height: 9),
                ),
              ),
          ],
        ),
      ),
    ).onTap(onTap);
  }
}
