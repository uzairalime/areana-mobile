import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';
import '../consts/app_strings.dart';
import '../enums/app_loading.dart';
import '../extensions/extensions.dart';
import 'app_button.dart';

class AppLoadingHandler extends StatelessWidget {
  const AppLoadingHandler({
    super.key,
    required this.status,
    required this.child,
    this.loading,
    this.errorMessage = '',
    this.onRetry,
  });

  final AppLoading status;
  final Widget child;
  final Widget? loading;
  final String errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      AppLoading.loading =>
        loading ?? const CircularProgressIndicator().center(),
      AppLoading.error => _AppLoadingError(
        message: errorMessage.isEmpty
            ? AppStrings.somethingWentWrong
            : errorMessage,
        onRetry: onRetry,
      ),
      AppLoading.initial || AppLoading.success => child,
    };
  }
}

class _AppLoadingError extends StatelessWidget {
  const _AppLoadingError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      crossAxisAlignment: .center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
        AppSizes.spaceMd.h,
        Text(
          message,
          style: context.textTheme.bodyLarge?.copyWith(color: AppColors.text),
          textAlign: .center,
        ).paddingSymmetric(horizontal: AppSizes.pagePadding),
        if (onRetry != null) ...[
          AppSizes.spaceLg.h,
          AppButton(
            label: AppStrings.retry,
            onPressed: onRetry,
            showArrow: false,
            minimumSize: const Size(0, AppSizes.buttonHeight),
          ),
        ],
      ],
    );
  }
}
