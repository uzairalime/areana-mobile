import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../model/booking_filter_tab.dart';
import '../model/user_booking.dart';

class BookingsState extends Equatable {
  const BookingsState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.tab = .upcoming,
    this.bookings = const [],
    this.reviewSubmittingId = '',
    this.managingBookingId = '',
  });

  final AppLoading status;
  final String errorMessage;
  final BookingFilterTab tab;
  final List<UserBooking> bookings;
  final String reviewSubmittingId;

  /// Cancel / manage in-flight booking id.
  final String managingBookingId;

  bool isManaging(String bookingId) => managingBookingId == bookingId;

  List<UserBooking> get _upcomingSorted {
    final list = [
      for (final b in bookings)
        if (b.isUpcoming) b,
    ]..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    return list;
  }

  List<UserBooking> get _pastSorted {
    final list = [
      for (final b in bookings)
        if (b.isPast) b,
    ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return list;
  }

  /// Nearest upcoming booking — featured card.
  UserBooking? get featuredUpcoming {
    final list = _upcomingSorted;
    if (list.isEmpty) return null;
    return list.first;
  }

  /// Remaining upcoming after the featured card.
  List<UserBooking> get alsoComingUp {
    final list = _upcomingSorted;
    if (list.length <= 1) return const [];
    return list.sublist(1);
  }

  List<PastBookingYearGroup> get pastByYear {
    final sorted = _pastSorted;
    if (sorted.isEmpty) return const [];

    final groups = <PastBookingYearGroup>[];
    int? currentYear;
    var bucket = <UserBooking>[];

    for (final booking in sorted) {
      if (currentYear != booking.year) {
        if (currentYear != null && bucket.isNotEmpty) {
          groups.add(
            PastBookingYearGroup(year: currentYear, bookings: bucket),
          );
        }
        currentYear = booking.year;
        bucket = [booking];
      } else {
        bucket.add(booking);
      }
    }
    if (currentYear != null && bucket.isNotEmpty) {
      groups.add(PastBookingYearGroup(year: currentYear, bookings: bucket));
    }
    return groups;
  }

  /// Reviews tab: completed only, pending reviews first.
  List<UserBooking> get reviewBookings {
    final list = [
      for (final b in bookings)
        if (b.status == .completed) b,
    ]..sort((a, b) {
      final pending = (a.canAddReview ? 0 : 1).compareTo(b.canAddReview ? 0 : 1);
      if (pending != 0) return pending;
      return b.occurredAt.compareTo(a.occurredAt);
    });
    return list;
  }

  bool get isEmptyForTab => switch (tab) {
    .upcoming => _upcomingSorted.isEmpty,
    .past => _pastSorted.isEmpty,
    .reviews => reviewBookings.isEmpty,
  };

  UserBooking? bookingById(String id) {
    for (final booking in bookings) {
      if (booking.id == id) return booking;
    }
    return null;
  }

  BookingsState copyWith({
    AppLoading? status,
    String? errorMessage,
    BookingFilterTab? tab,
    List<UserBooking>? bookings,
    String? reviewSubmittingId,
    String? managingBookingId,
  }) {
    return BookingsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      tab: tab ?? this.tab,
      bookings: bookings ?? this.bookings,
      reviewSubmittingId: reviewSubmittingId ?? this.reviewSubmittingId,
      managingBookingId: managingBookingId ?? this.managingBookingId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    tab,
    bookings,
    reviewSubmittingId,
    managingBookingId,
  ];
}
