import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/profile_avatar.dart';

class EditProfileAvatar extends StatelessWidget {
  const EditProfileAvatar({
    super.key,
    required this.name,
    required this.onCameraTap,
    this.networkUrl,
    this.localPath,
    this.heroTag,
  });

  final String name;
  final String? networkUrl;
  final String? localPath;
  final String? heroTag;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    final hasLocal = localPath != null && localPath!.isNotEmpty;
    final displayName = name.isEmpty ? 'Player' : name;

    Widget avatar = hasLocal
        ? ClipOval(
            child: Image.file(
              File(localPath!),
              width: 96,
              height: 96,
              fit: .cover,
            ),
          )
        : ProfileAvatar(
            username: displayName,
            url: networkUrl,
            size: 96,
            fontSize: 32,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.accent,
          );

    if (heroTag != null && !hasLocal) {
      avatar = Hero(
        tag: heroTag!,
        createRectTween: (begin, end) =>
            MaterialRectArcTween(begin: begin, end: end),
        child: Material(type: .transparency, child: avatar),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            clipBehavior: .none,
            children: [
              avatar,
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: AppColors.accent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      AppHaptics.selection();
                      onCameraTap();
                    },
                    child: const SizedBox(
                      width: 34,
                      height: 34,
                      child: Icon(
                        Icons.photo_camera_rounded,
                        size: 18,
                        color: AppColors.onAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        12.h,
        Text(
          'Tap the camera to change your photo',
          textAlign: .center,
          style: context.textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: .w500,
          ),
        ),
      ],
    );
  }
}
