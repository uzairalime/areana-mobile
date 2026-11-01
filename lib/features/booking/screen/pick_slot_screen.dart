import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../widgets/booking_auth_sheet.dart';
import '../widgets/booking_sticky_bar.dart';
import '../widgets/pick_slot_sections.dart';
import '../widgets/pick_slot_shimmer.dart';

/// Court-first slot picker (user-web booking flow): court, date,
/// consecutive slots, then checkout. Sections live in
/// `pick_slot_sections.dart` so this file stays under 500 lines.
class PickSlotScreen extends StatelessWidget {
  const PickSlotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          final venue = state.venue;
          return AppLoadingHandler(
            status: state.status,
            errorMessage: state.errorMessage,
            loading: const PickSlotShimmer(),
            onRetry: venue == null
                ? null
                : () => context.read<BookingCubit>().start(venue),
            child: venue == null
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: PickSlotHeroHeader(
                                venueId: venue.id,
                                color: venue.heroColor,
                                onBack: () {
                                  AppHaptics.selection();
                                  context.pop();
                                },
                                onSave: () => showBookingAuthSheet(
                                  context,
                                  title: 'Save your favourite venues',
                                  body:
                                      'Log in to save venues and get alerts when your usual courts open up.',
                                  onLogin: () => context.push(
                                    '${AppRoutes.login}?next=home',
                                  ),
                                  onSignup: () => context.push(
                                    '${AppRoutes.signup}?next=home',
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Transform.translate(
                                offset: const Offset(0, -26),
                                child: DecoratedBox(
                                  decoration: const BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(26),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const .fromLTRB(20, 22, 20, 28),
                                    child: Column(
                                      crossAxisAlignment: .start,
                                      children: [
                                        PickSlotVenueIntro(state: state),
                                        AppSizes.spaceLg.h,
                                        const PickSlotPayGroundCallout(),
                                        AppSizes.spaceLg.h,
                                        PickSlotCourtPicker(state: state),
                                        AppSizes.spaceLg.h,
                                        PickSlotDatePicker(state: state),
                                        AppSizes.spaceLg.h,
                                        PickSlotCountPicker(state: state),
                                        AppSizes.spaceLg.h,
                                        PickSlotGrid(state: state),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      BookingStickyBar(
                        enabled: state.canContinue,
                        meta: state.canContinue
                            ? '${state.selectedCourt?.name} · ${state.summaryLine}'
                            : null,
                        total: state.canContinue ? state.total : null,
                        ctaLabel: 'Continue',
                        onPressed: () {
                          AppHaptics.medium();
                          context.push(AppRoutes.checkout);
                        },
                      ),
                    ],
                  ),
          );
        },
      ),
    ).annotatedRegion(.dark);
  }
}
