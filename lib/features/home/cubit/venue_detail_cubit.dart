import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../model/areana_models.dart';
import 'home_repository.dart';

class VenueDetailState extends Equatable {
  const VenueDetailState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.detail,
    this.reviews = const [],
    this.hasMoreReviews = false,
  });

  final AppLoading status;
  final String errorMessage;
  final AreanaVenueDetail? detail;
  final List<AreanaReview> reviews;
  final bool hasMoreReviews;

  VenueDetailState copyWith({
    AppLoading? status,
    String? errorMessage,
    AreanaVenueDetail? detail,
    List<AreanaReview>? reviews,
    bool? hasMoreReviews,
  }) {
    return VenueDetailState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      detail: detail ?? this.detail,
      reviews: reviews ?? this.reviews,
      hasMoreReviews: hasMoreReviews ?? this.hasMoreReviews,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, detail, reviews];
}

class VenueDetailCubit extends Cubit<VenueDetailState> {
  VenueDetailCubit(this._repository, this.venueId)
      : super(const VenueDetailState()) {
    load();
  }

  final HomeRepository _repository;
  final String venueId;
  String? _reviewCursor;

  Future<void> load() async {
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.fetchVenueDetail(venueId);
    if (isClosed) return;
    await result.when(
      success: (detail) async {
        emit(state.copyWith(status: AppLoading.success, detail: detail));
        await _repository.postVenueEvent(venueId: venueId, type: 'view');
        await loadMoreReviews();
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

  Future<void> loadMoreReviews() async {
    final result = await _repository.fetchVenueReviews(
      venueId,
      cursor: _reviewCursor,
    );
    if (isClosed) return;
    result.when(
      success: (page) {
        _reviewCursor = page.nextCursor;
        emit(
          state.copyWith(
            reviews: [...state.reviews, ...page.items],
            hasMoreReviews: page.hasMore,
          ),
        );
      },
      failure: (_) {},
    );
  }
}

class CourtDetailState extends Equatable {
  const CourtDetailState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.detail,
    this.reviews = const [],
    this.hasMoreReviews = false,
  });

  final AppLoading status;
  final String errorMessage;
  final AreanaCourtDetail? detail;
  final List<AreanaReview> reviews;
  final bool hasMoreReviews;

  CourtDetailState copyWith({
    AppLoading? status,
    String? errorMessage,
    AreanaCourtDetail? detail,
    List<AreanaReview>? reviews,
    bool? hasMoreReviews,
  }) {
    return CourtDetailState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      detail: detail ?? this.detail,
      reviews: reviews ?? this.reviews,
      hasMoreReviews: hasMoreReviews ?? this.hasMoreReviews,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, detail, reviews];
}

class CourtDetailCubit extends Cubit<CourtDetailState> {
  CourtDetailCubit(this._repository, this.courtId)
      : super(const CourtDetailState()) {
    load();
  }

  final HomeRepository _repository;
  final String courtId;
  String? _reviewCursor;

  Future<void> load() async {
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.fetchCourtDetail(courtId);
    if (isClosed) return;
    await result.when(
      success: (detail) async {
        emit(state.copyWith(status: AppLoading.success, detail: detail));
        await _repository.postVenueEvent(
          venueId: detail.venueId,
          type: 'court_view',
          courtId: courtId,
        );
        await loadMoreReviews();
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

  Future<void> loadMoreReviews() async {
    final result = await _repository.fetchCourtReviews(
      courtId,
      cursor: _reviewCursor,
    );
    if (isClosed) return;
    result.when(
      success: (page) {
        _reviewCursor = page.nextCursor;
        emit(
          state.copyWith(
            reviews: [...state.reviews, ...page.items],
            hasMoreReviews: page.hasMore,
          ),
        );
      },
      failure: (_) {},
    );
  }
}
