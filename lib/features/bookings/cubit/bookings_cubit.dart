import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../model/booking_filter_tab.dart';
import 'bookings_repository.dart';
import 'bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit(this._repository) : super(const BookingsState()) {
    load();
  }

  final BookingsRepository _repository;
  var _requestId = 0;

  String get _filter =>
      state.tab == .upcoming ? 'upcoming' : 'past';

  Future<void> load() async {
    final id = ++_requestId;
    emit(
      state.copyWith(
        status: AppLoading.loading,
        errorMessage: '',
        bookings: const [],
        page: 1,
        hasMore: true,
      ),
    );
    final result = await _repository.fetchBookings(filter: _filter);
    if (isClosed || id != _requestId) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            bookings: page.items,
            page: page.page,
            hasMore: page.hasMore,
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
    final result = await _repository.fetchBookings(filter: _filter);
    if (isClosed || id != _requestId) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            bookings: page.items,
            page: page.page,
            hasMore: page.hasMore,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(errorMessage: error.message));
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    final nextPage = state.page + 1;
    emit(state.copyWith(isLoadingMore: true));
    final result = await _repository.fetchBookings(
      filter: _filter,
      page: nextPage,
    );
    if (isClosed) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            bookings: [...state.bookings, ...page.items],
            page: page.page,
            hasMore: page.hasMore,
            isLoadingMore: false,
          ),
        );
      },
      failure: (_) {
        emit(state.copyWith(isLoadingMore: false));
      },
    );
  }

  void setTab(BookingFilterTab tab) {
    if (tab == state.tab) return;
    emit(state.copyWith(tab: tab));
    load();
  }

  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    if (state.reviewSubmittingId.isNotEmpty) return false;

    final index = state.bookings.indexWhere((e) => e.id == bookingId);
    if (index < 0) return false;
    final current = state.bookings[index];
    if (!current.canAddReview) return false;

    emit(state.copyWith(reviewSubmittingId: bookingId, errorMessage: ''));

    final result = await _repository.submitReview(
      bookingId: bookingId,
      rating: rating,
      comment: comment,
    );
    if (isClosed) return false;

    return result.when(
      success: (_) {
        final next = [...state.bookings];
        next[index] = current.copyWith(hasReviewed: true);
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

  Future<bool> requestReschedule({
    required String bookingId,
    required String date,
    required int startMinutes,
  }) async {
    if (state.managingBookingId.isNotEmpty) return false;
    emit(state.copyWith(managingBookingId: bookingId, errorMessage: ''));
    final result = await _repository.requestReschedule(
      bookingId: bookingId,
      date: date,
      startMinutes: startMinutes,
    );
    if (isClosed) return false;
    return result.when(
      success: (_) {
        emit(state.copyWith(managingBookingId: '', errorMessage: ''));
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

  Future<bool> withdrawReschedule(String bookingId) async {
    if (state.managingBookingId.isNotEmpty) return false;
    emit(state.copyWith(managingBookingId: bookingId, errorMessage: ''));
    final result = await _repository.withdrawReschedule(bookingId);
    if (isClosed) return false;
    return result.when(
      success: (_) {
        emit(state.copyWith(managingBookingId: '', errorMessage: ''));
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
