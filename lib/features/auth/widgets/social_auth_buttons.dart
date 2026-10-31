import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../cubit/auth_cubit.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return Row(
      children: [
        AppButton.outlined(
          label: 'Google',
          icon: Icons.g_mobiledata,
          onPressed: () {
            AppHaptics.medium();
            cubit.signInWithGoogle();
          },
        ).expand(),
        10.w,
        AppButton.outlined(
          label: 'Apple',
          icon: Icons.apple,
          onPressed: () {
            AppHaptics.medium();
            cubit.signInWithApple();
          },
        ).expand(),
      ],
    );
  }
}
