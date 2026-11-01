import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/booking/cubit/booking_cubit.dart';
import '../../features/home/model/venue.dart';
import '../router/app_router.dart';
import '../services/locator.dart';
import 'app_haptics.dart';

/// Single entry for venue → detail / book-slot flows.
abstract final class VenueNavigation {
  static void openDetail(BuildContext context, Venue venue) {
    AppHaptics.selection();
    context.push('${AppRoutes.venueDetail}/${venue.id}', extra: venue);
  }

  /// Skips detail — starts availability load and opens pick-slot → checkout → confirm.
  static void openBookSlot(
    BuildContext context,
    Venue venue, {
    String? preselectedCourtId,
  }) {
    AppHaptics.medium();
    getIt<BookingCubit>().start(venue, preselectedCourtId: preselectedCourtId);
    context.push(AppRoutes.pickSlot);
  }

  static void openCourtDetail(BuildContext context, String courtId) {
    AppHaptics.selection();
    context.push('${AppRoutes.courtDetail}/$courtId');
  }
}
