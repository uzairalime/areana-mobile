import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/services/session_cubit.dart';
import '../../../core/services/session_state.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/profile_avatar.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Home · Bookings · Explore · Messages · Profile
  static const homeIndex = 0;
  static const bookingsIndex = 1;
  static const exploreIndex = 2;
  static const messagesIndex = 3;
  static const accountIndex = 4;

  static const _items = <_NavItem>[
    _NavItem(
      icon: Icons.stadium_outlined,
      selectedIcon: Icons.stadium_rounded,
    ),
    _NavItem(
      icon: Icons.event_available_outlined,
      selectedIcon: Icons.event_available_rounded,
    ),
    _NavItem(
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
    ),
    _NavItem(
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
    ),
    _NavItem(
      icon: Icons.account_circle_outlined,
      selectedIcon: Icons.account_circle_rounded,
      isProfile: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottom == 0 ? 12 : bottom),
      child: _NavTrack(
        currentIndex: currentIndex,
        items: _items,
        onTap: onTap,
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    this.isProfile = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool isProfile;
}

class _NavTrack extends StatefulWidget {
  const _NavTrack({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  @override
  State<_NavTrack> createState() => _NavTrackState();
}

class _NavTrackState extends State<_NavTrack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;
  late Animation<double> _slide;
  late int _tabIndex;

  static const _radius = 30.0;
  static const _trackHeight = 56.0;
  static const _innerPad = 4.0;
  static const _iconSize = 24.0;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.currentIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _curved = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = AlwaysStoppedAnimation(_tabIndex.toDouble());
    if (_tabIndex != 0) {
      _slide = Tween<double>(
        begin: 0,
        end: _tabIndex.toDouble(),
      ).animate(_curved);
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant _NavTrack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex == _tabIndex) {
      return;
    }
    _slide = Tween<double>(
      begin: _tabIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(_curved);
    _controller.forward(from: 0);
    _tabIndex = widget.currentIndex;
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabCount = widget.items.length;
    final radius = BorderRadius.circular(_radius);

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: AppColors.surface.withValues(alpha: 0.55),
                ),
                gradient: LinearGradient(
                  begin: .topCenter,
                  end: .bottomCenter,
                  colors: [
                    AppColors.surface.withValues(alpha: 0.78),
                    AppColors.surface.withValues(alpha: 0.58),
                  ],
                ),
              ),
              child: Padding(
                padding: const .all(_innerPad),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tabWidth = constraints.maxWidth / tabCount;
                    return AnimatedBuilder(
                      animation: _slide,
                      child: Row(
                        children: [
                          for (var i = 0; i < tabCount; i++)
                            SizedBox(
                              height: _trackHeight - _innerPad * 2,
                              child: _NavIcon(
                                item: widget.items[i],
                                selected: widget.currentIndex == i,
                              ),
                            ).onTap(() {
                              AppHaptics.light();
                              widget.onTap(i);
                            }).expand(),
                        ],
                      ),
                      builder: (context, child) {
                        return SizedBox(
                          height: _trackHeight - _innerPad * 2,
                          child: Stack(
                            children: [
                              Positioned(
                                left: _slide.value * tabWidth,
                                top: 0,
                                width: tabWidth,
                                height: _trackHeight - _innerPad * 2,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.94,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      _radius - 2,
                                    ),
                                    border: Border.all(
                                      color: AppColors.accent.withValues(
                                        alpha: 0.18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              child!,
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.item, required this.selected});

  final _NavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textSecondary;

    if (item.isProfile) {
      return BlocBuilder<SessionCubit, SessionState>(
        buildWhen: (previous, current) => previous.user != current.user,
        builder: (context, session) {
          final user = session.user;
          if (user == null) {
            return Icon(
              selected ? item.selectedIcon : item.icon,
              size: _NavTrackState._iconSize,
              color: color,
            ).center();
          }
          return ProfileAvatar(
            username: user.name.isEmpty ? 'Player' : user.name,
            url: user.avatarUrl,
            size: 28,
            fontSize: 10,
            backgroundColor: selected
                ? AppColors.accent
                : AppColors.primarySoft,
            foregroundColor: selected
                ? AppColors.onAccent
                : AppColors.primary,
          ).center();
        },
      );
    }

    return Icon(
      selected ? item.selectedIcon : item.icon,
      size: _NavTrackState._iconSize,
      color: color,
    ).center();
  }
}
