import 'package:flutter/material.dart';

import '../consts/app_strings.dart';
import '../enums/app_loading.dart';
import 'app_error_dialog.dart';
import 'app_loader.dart';

class AppFormListener extends StatefulWidget {
  const AppFormListener({
    super.key,
    required this.status,
    required this.errorMessage,
    required this.loadingTitle,
    required this.errorTitle,
    required this.child,
    this.onSuccess,
    this.onErrorDismissed,
  });

  final AppLoading status;
  final String errorMessage;
  final String loadingTitle;
  final String errorTitle;
  final Widget child;
  final VoidCallback? onSuccess;
  final VoidCallback? onErrorDismissed;

  @override
  State<AppFormListener> createState() => _AppFormListenerState();
}

class _AppFormListenerState extends State<AppFormListener> {
  @override
  void didUpdateWidget(AppFormListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status == widget.status &&
        oldWidget.errorMessage == widget.errorMessage) {
      return;
    }
    _sync();
  }

  @override
  void dispose() {
    AppLoader.instance.hide();
    super.dispose();
  }

  void _sync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      AppLoader.instance.hide();
      switch (widget.status) {
        case .loading:
          AppLoader.instance.show(
            context,
            title: widget.loadingTitle,
            text: AppStrings.pleaseWait,
          );
        case .error:
          final message = widget.errorMessage;
          if (message.isEmpty) {
            return;
          }
          showAppErrorDialog(
            context,
            title: widget.errorTitle,
            message: message,
          ).then((_) {
            if (!mounted) {
              return;
            }
            widget.onErrorDismissed?.call();
          });
        case .success:
          widget.onSuccess?.call();
        case .initial:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
