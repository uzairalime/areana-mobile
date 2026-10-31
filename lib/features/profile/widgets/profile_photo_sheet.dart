import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';

Future<XFile?> showProfilePhotoSheet(BuildContext context) async {
  AppHaptics.light();
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: .vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const .fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: .min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: const SizedBox(width: 40, height: 4),
              ),
              16.h,
              Text(
                'Change profile photo',
                style: sheetContext.textTheme.titleMedium?.copyWith(
                  fontWeight: .w800,
                ),
              ),
              16.h,
              _PhotoOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from gallery',
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
              10.h,
              _PhotoOption(
                icon: Icons.photo_camera_outlined,
                label: 'Take a photo',
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              8.h,
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text(
                  'Cancel',
                  style: sheetContext.textTheme.labelLarge?.copyWith(
                    fontWeight: .w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (source == null) return null;
  final picker = ImagePicker();
  return picker.pickImage(
    source: source,
    maxWidth: 1200,
    maxHeight: 1200,
    imageQuality: 88,
  );
}

class _PhotoOption extends StatelessWidget {
  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const .symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: .circle,
                ),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
              ),
              12.w,
              Text(
                label,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w700,
                ),
              ).expand(),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
