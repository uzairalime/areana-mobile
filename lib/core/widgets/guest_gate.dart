import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/session_cubit.dart';
import '../services/session_state.dart';
import 'account_required_card.dart';

/// Shows [guest] (or default account card) when signed out; otherwise [child].
class GuestGate extends StatelessWidget {
  const GuestGate({
    super.key,
    required this.child,
    this.guest,
    this.title,
    this.message,
  });

  final Widget child;
  final Widget? guest;
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      buildWhen: (previous, current) =>
          previous.isAuthenticated != current.isAuthenticated,
      builder: (context, session) {
        if (session.isAuthenticated) {
          return child;
        }
        if (guest != null) {
          return guest!;
        }
        return GuestGateScreen(
          title: title ?? 'Account required',
          message:
              message ??
              'Sign in to unlock bookings, offers, and a profile that stays with you across devices.',
        );
      },
    );
  }
}
