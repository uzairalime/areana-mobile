import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../../../core/services/session_aware_cubit.dart';
import '../../../core/services/session_cubit.dart';
import '../model/booking_filter_tab.dart';
import 'bookings_repository.dart';
import 'bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState>
    with SessionAwareCubit<BookingsState> {
  BookingsCubit(this._repository, [this.authSession])
    : super(const BookingsState()) {
    bindAuth(onSignedIn: () { load(); }, onSignedOut: reset);
  }

  final BookingsRepository _repository;
  @override
  final SessionCubit? authSession;
  var _requestId = 0;
  bool _isRefreshing = false;

  String get _filter => state.tab == .upcoming ? 'upcoming' : 'past';

  Future<void> load() => _loadFirstPage(showLoading: true);

  Future<void> refresh() => _loadFirstPage(showLoading: false);

  void reset() {
    _requestId++;
    _isRefreshing = false;
    if (!isClosed) emit(const BookingsState());
  }

  Future<void> _loadFirstPage({required bool showLoading}) async {
    if (!canUseAuthedApi) {
      reset();
      return;
    }
    final id = ++_requestId;
    _isRefreshing = true;
    emit(
      state.copyWith(
        status: showLoading ? AppLoading.loading : state.status,
        errorMessage: '',
        bookings: showLoading ? const [] : state.bookings,
        page: showLoading ? 1 : state.page,
        hasMore: showLoading ? true : state.hasMore,
        isLoadingMore: false,
      ),
    );
    final result = await _repository.fetchBookings(filter: _filter);
    if (isClosed || id != _requestId) return;
    _isRefreshing = false;
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
            status: showLoading ? AppLoading.error : state.status,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!canUseAuthedApi) return;
    if (_isRefreshing || state.isLoadingMore || !state.hasMore) return;
    final requestId = _requestId;
    final nextPage = state.page + 1;
    emit(state.copyWith(isLoadingMore: true));
    final result = await _repository.fetchBookings(
      filter: _filter,
      page: nextPage,
    );
    if (isClosed || requestId != _requestId) return;
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

  @override
  Future<void> close() async {
    await unbindAuth();
    return super.close();
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
        final currentIndex = next.indexWhere(
          (booking) => booking.id == bookingId,
        );
        if (currentIndex >= 0) {
          next[currentIndex] = next[currentIndex].copyWith(hasReviewed: true);
        }
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
          state.copyWith(reviewSubmittingId: '', errorMessage: error.message),
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
        final currentIndex = next.indexWhere(
          (booking) => booking.id == bookingId,
        );
        if (currentIndex >= 0) next[currentIndex] = updated;
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
          state.copyWith(managingBookingId: '', errorMessage: error.message),
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
          state.copyWith(managingBookingId: '', errorMessage: error.message),
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
          state.copyWith(managingBookingId: '', errorMessage: error.message),
        );
        return false;
      },
    );
  }
}
