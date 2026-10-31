import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../auth/model/user_model.dart';
import '../model/profile_stats.dart';

/// Shared Hero tag for profile → edit-profile avatar flight.
String profileAvatarHeroTag(String userId) => 'profile-avatar-$userId';

class ProfileSliverHeader extends StatelessWidget {
  const ProfileSliverHeader({
    super.key,
    required this.user,
    required this.stats,
    required this.onEdit,
    required this.onBookings,
    required this.onNotifications,
  });

  final UserModel user;
  final ProfileStats stats;
  final VoidCallback onEdit;
  final VoidCallback onBookings;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: ProfileHeaderDelegate(
        user: user,
        stats: stats,
        topInset: MediaQuery.paddingOf(context).top,
        onEdit: onEdit,
        onBookings: onBookings,
        onNotifications: onNotifications,
      ),
    );
  }
}

class ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  ProfileHeaderDelegate({
    required this.user,
    required this.stats,
    required this.topInset,
    required this.onEdit,
    required this.onBookings,
    required this.onNotifications,
  });

  final UserModel user;
  final ProfileStats stats;
  final double topInset;
  final VoidCallback onEdit;
  final VoidCallback onBookings;
  final VoidCallback onNotifications;

  static const _statsPanel = Color(0xFF0A2F22);
  static const _avatarRing = Color(0xFF0C3326);
  static const _memberChip = Color(0xFF0C3326);

  /// Title row + identity + stats + CTAs + paddings.
  static const expandedBodyHeight = 352.0;
  static const collapsedBodyHeight = 66.0;

  @override
  double get maxExtent => topInset + expandedBodyHeight;

  @override
  double get minExtent => topInset + collapsedBodyHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = math.max(maxExtent - minExtent, 1.0);
    final t = (shrinkOffset / range).clamp(0.0, 1.0);
    final eased = Curves.easeInOutCubic.transform(t);
    final height = math.max(maxExtent - shrinkOffset, minExtent);

    final expandedFade = (1.0 - eased * 1.4).clamp(0.0, 1.0);
    final collapsedFade = ((eased - 0.5) / 0.5).clamp(0.0, 1.0);
    final avatarSize = lerpDouble(72, 36, eased)!;
    final name = user.name.isEmpty ? 'Player' : user.name;
    final contact = user.phone.isEmpty ? user.email : user.phone;
    final hasMember = user.memberSinceLabel.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: .light,
      child: SizedBox(
        height: height,
        child: Material(
          color: AppColors.primary,
          elevation: collapsedFade > 0.2 ? 2 * collapsedFade : 0,
          shadowColor: Colors.black.withValues(alpha: 0.35),
          child: Stack(
            fit: .expand,
            clipBehavior: .hardEdge,
            children: [
              Positioned(
                top: -40 + (eased * 24),
                right: -50,
                child: Opacity(
                  opacity: (1 - eased * 0.7).clamp(0.15, 1),
                  child: const _HeroRings(),
                ),
              ),
              // Stats + action buttons (scroll away)
              Positioned(
                left: 0,
                right: 0,
                top: topInset,
                child: IgnorePointer(
                  ignoring: expandedFade < 0.25,
                  child: Opacity(
                    opacity: expandedFade,
                    child: Transform.translate(
                      offset: Offset(0, -18 * eased),
                      child: Padding(
                        padding: const .fromLTRB(20, 8, 20, 24),
                        child: Column(
                          crossAxisAlignment: .stretch,
                          children: [
                            const SizedBox(height: 42),
                            20.h,
                            SizedBox(height: hasMember ? 102 : 74),
                            16.h,
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: _statsPanel,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const .symmetric(
                                  vertical: 16,
                                  horizontal: 8,
                                ),
                                child: Row(
                                  children: [
                                    _Stat(
                                      value: '${stats.bookingsCount}',
                                      label: 'Bookings',
                                    ).expand(),
                                    _Stat(
                                      value: stats.hoursLabel,
                                      label: 'Played',
                                    ).expand(),
                                    _Stat(
                                      value: '${stats.reviewsCount}',
                                      label: 'Reviews',
                                    ).expand(),
                                  ],
                                ),
                              ),
                            ),
                            14.h,
                            Row(
                              spacing: 12,
                              children: [
                                _HeroButton(
                                  label: 'Edit profile',
                                  icon: Icons.edit_outlined,
                                  filled: true,
                                  onTap: onEdit,
                                ).expand(),
                                _HeroButton(
                                  label: 'My bookings',
                                  icon: Icons.calendar_today_outlined,
                                  filled: false,
                                  onTap: onBookings,
                                ).expand(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Sticky morphing identity
              Positioned(
                left: 20,
                right: 20,
                top: topInset + lerpDouble(70, 12, eased)!,
                child: Row(
                  crossAxisAlignment: .center,
                  children: [
                    _StickyAvatar(
                      userId: user.id,
                      name: name,
                      url: user.avatarUrl,
                      size: avatarSize,
                      ringWidth: lerpDouble(3, 2, eased)!,
                    ),
                    SizedBox(width: lerpDouble(14, 12, eased)!),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        mainAxisSize: .min,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: .ellipsis,
                            style: context.textTheme.titleLarge?.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: .w800,
                              fontSize: lerpDouble(22, 16, eased),
                              letterSpacing: -0.3,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: lerpDouble(4, 2, eased)!),
                          Text(
                            contact,
                            maxLines: 1,
                            overflow: .ellipsis,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onPrimary.withValues(
                                alpha: lerpDouble(0.78, 0.68, eased)!,
                              ),
                              fontWeight: .w500,
                              fontSize: lerpDouble(13, 12, eased),
                              height: 1.2,
                            ),
                          ),
                          if (hasMember)
                            ClipRect(
                              child: Align(
                                alignment: .topLeft,
                                heightFactor: expandedFade,
                                child: Opacity(
                                  opacity: expandedFade,
                                  child: Padding(
                                    padding: const .only(top: 8),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: _memberChip,
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.radiusPill,
                                        ),
                                      ),
                                      child: Text(
                                        user.memberSinceLabel,
                                        style: context
                                            .textTheme.labelSmall
                                            ?.copyWith(
                                          color: AppColors.accent,
                                          fontWeight: .w700,
                                          fontSize: 11,
                                        ),
                                      ).paddingSymmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Opacity(
                      opacity: collapsedFade,
                      child: IgnorePointer(
                        ignoring: collapsedFade < 0.45,
                        child: _NotifyButton(onTap: onNotifications),
                      ),
                    ),
                  ],
                ),
              ),
              // Expanded title + notifications
              Positioned(
                left: 20,
                right: 20,
                top: topInset + 8,
                child: Opacity(
                  opacity: expandedFade,
                  child: IgnorePointer(
                    ignoring: expandedFade < 0.35,
                    child: Row(
                      children: [
                        Text(
                          'Profile',
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: AppColors.onPrimary,
                            fontSize: 26,
                            fontWeight: .w800,
                            letterSpacing: -0.4,
                          ),
                        ).expand(),
                        _NotifyButton(onTap: onNotifications),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant ProfileHeaderDelegate oldDelegate) {
    return oldDelegate.user != user ||
        oldDelegate.stats != stats ||
        oldDelegate.topInset != topInset;
  }
}

class _StickyAvatar extends StatelessWidget {
  const _StickyAvatar({
    required this.userId,
    required this.name,
    required this.url,
    required this.size,
    required this.ringWidth,
  });

  final String userId;
  final String name;
  final String? url;
  final double size;
  final double ringWidth;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: profileAvatarHeroTag(userId),
      createRectTween: (begin, end) =>
          MaterialRectArcTween(begin: begin, end: end),
      flightShuttleBuilder: (
        flightContext,
        animation,
        direction,
        fromContext,
        toContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final curved = Curves.easeInOutCubic.transform(animation.value);
            final s = direction == .push
                ? lerpDouble(size, 96, curved)!
                : lerpDouble(96, size, curved)!;
            return Center(
              child: Material(
                type: .transparency,
                child: _AvatarShell(
                  name: name,
                  url: url,
                  size: s,
                  ringWidth: ringWidth,
                ),
              ),
            );
          },
        );
      },
      child: Material(
        type: .transparency,
        child: _AvatarShell(
          name: name,
          url: url,
          size: size,
          ringWidth: ringWidth,
        ),
      ),
    );
  }
}

class _AvatarShell extends StatelessWidget {
  const _AvatarShell({
    required this.name,
    required this.url,
    required this.size,
    required this.ringWidth,
  });

  final String name;
  final String? url;
  final double size;
  final double ringWidth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: .circle,
        border: Border.all(
          color: ProfileHeaderDelegate._avatarRing,
          width: ringWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ProfileAvatar(
        username: name,
        url: url,
        size: size,
        fontSize: size * 0.36,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
      ).paddingAll(1),
    );
  }
}

class _NotifyButton extends StatelessWidget {
  const _NotifyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.onPrimary.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            Icons.notifications_none_rounded,
            color: AppColors.onPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? AppColors.accent : Colors.transparent;
    final fg = filled ? AppColors.onAccent : AppColors.onPrimary;

    return SizedBox(
      height: 48,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: filled
              ? BorderSide.none
              : BorderSide(
                  color: AppColors.onPrimary.withValues(alpha: 0.55),
                ),
        ),
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            onTap();
          },
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              Icon(icon, size: 18, color: fg),
              8.w,
              Text(
                label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: .w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: .w800,
            fontSize: 22,
            letterSpacing: -0.3,
          ),
        ),
        4.h,
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: AppColors.onPrimary.withValues(alpha: 0.62),
            fontWeight: .w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _HeroRings extends StatelessWidget {
  const _HeroRings();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(painter: _RingsPainter()),
    );
  }
}

class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.55, size.height * 0.45);
    final paint = Paint()
      ..style = .stroke
      ..strokeWidth = 1.4
      ..color = AppColors.onPrimary.withValues(alpha: 0.08);

    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, 28.0 * i, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
