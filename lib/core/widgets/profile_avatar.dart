import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../utils/name_initials.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.username,
    this.url,
    this.size = 44,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = AppColors.accent,
    this.fontSize,
  });

  final String username;
  final String? url;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;
  final double? fontSize;

  bool get _hasImage => url != null && url!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final initials = NameInitials.from(username);
    final textSize = fontSize ?? (size * 0.34).clamp(11.0, 22.0);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: .circle,
        ),
        child: ClipOval(
          child: _hasImage
              ? Image.network(
                  url!.trim(),
                  width: size,
                  height: size,
                  fit: .cover,
                  errorBuilder: (_, _, _) => _Initials(
                    initials: initials,
                    color: foregroundColor,
                    fontSize: textSize,
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }
                    return _Initials(
                      initials: initials,
                      color: foregroundColor,
                      fontSize: textSize,
                    );
                  },
                )
              : _Initials(
                  initials: initials,
                  color: foregroundColor,
                  fontSize: textSize,
                ),
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({
    required this.initials,
    required this.color,
    required this.fontSize,
  });

  final String initials;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: .w800,
          height: 1,
        ),
      ),
    );
  }
}
