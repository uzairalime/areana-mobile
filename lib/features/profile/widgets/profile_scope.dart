import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/locator.dart';
import '../cubit/profile_cubit.dart';

/// Shared [ProfileCubit] for hub + pushed account subpages.
class ProfileScope extends StatelessWidget {
  const ProfileScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ProfileCubit>(),
      child: child,
    );
  }
}
