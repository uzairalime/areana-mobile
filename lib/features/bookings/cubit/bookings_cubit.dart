import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../model/booking_filter_tab.dart';
import '../model/booking_review_status.dart';
import 'bookings_repository.dart';
import 'bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit(this._repository) : super(const BookingsState()) {
    load();
  }

  final BookingsRepository _repository;
  var _requestId = 0;

  Future<void> load() async {
    final id = ++_requestId;
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.fetchBookings();
    if (isClosed || id != _requestId) return;
    result.when(
      success: (bookings) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            bookings: bookings,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  Future<void> refresh() async {
    final id = ++_requestId;
    final result = await _repository.fetchBookings();
    if (isClosed || id != _requestId) return;
    result.when(
      success: (bookings) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            bookings: bookings,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(errorMessage: error.message));
      },
    );
  }

  void setTab(BookingFilterTab tab) {
    if (tab == state.tab) return;
    emit(state.copyWith(tab: tab));
  }

  Future<bool> submitReview({
    required String bookingId,
    required bool recommended,
  }) async {
    if (state.reviewSubmittingId.isNotEmpty) return false;

    final index = state.bookings.indexWhere((e) => e.id == bookingId);
    if (index < 0) return false;
    final current = state.bookings[index];
    if (!current.canAddReview) return false;

    emit(state.copyWith(reviewSubmittingId: bookingId, errorMessage: ''));

    final result = await _repository.submitReview(
      bookingId: bookingId,
      recommended: recommended,
    );
    if (isClosed) return false;

    return result.when(
      success: (updated) {
        final next = [...state.bookings];
        next[index] = updated.copyWith(
          reviewStatus: recommended
              ? BookingReviewStatus.recommended
              : BookingReviewStatus.notRecommended,
        );
        emit(
          state.copyWith(
            bookings: next,
            reviewSubmittingId: '',
            errorMessage: '',
          ),
        );
        return true;
      },
      failure: (error) {
        emit(
          state.copyWith(
            reviewSubmittingId: '',
            errorMessage: error.message,
          ),
        );
        return false;
      },
    );
  }

  Future<bool> cancelBooking(String bookingId) async {
    if (state.managingBookingId.isNotEmpty) return false;

    final index = state.bookings.indexWhere((e) => e.id == bookingId);
    if (index < 0) return false;
    final current = state.bookings[index];
    if (!current.canModify) return false;

    emit(state.copyWith(managingBookingId: bookingId, errorMessage: ''));

    final result = await _repository.cancelBooking(bookingId);
    if (isClosed) return false;

    return result.when(
      success: (updated) {
        final next = [...state.bookings];
        next[index] = updated;
        emit(
          state.copyWith(
            bookings: next,
            managingBookingId: '',
            errorMessage: '',
          ),
        );
        return true;
      },
      failure: (error) {
        emit(
          state.copyWith(
            managingBookingId: '',
            errorMessage: error.message,
          ),
        );
        return false;
      },
    );
  }
}
