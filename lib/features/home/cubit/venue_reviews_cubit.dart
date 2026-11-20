import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../model/areana_models.dart';
import 'home_repository.dart';

class VenueReviewsState extends Equatable {
  const VenueReviewsState({
    this.status = AppLoading.initial,
    this.paging = false,
    this.errorMessage = '',
    this.reviews = const [],
    this.hasMore = false,
  });

  final AppLoading status;
  final bool paging;
  final String errorMessage;
  final List<AreanaReview> reviews;
  final bool hasMore;

  VenueReviewsState copyWith({
    AppLoading? status,
    bool? paging,
    String? errorMessage,
    List<AreanaReview>? reviews,
    bool? hasMore,
  }) {
    return VenueReviewsState(
      status: status ?? this.status,
      paging: paging ?? this.paging,
      errorMessage: errorMessage ?? this.errorMessage,
      reviews: reviews ?? this.reviews,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [status, paging, errorMessage, reviews, hasMore];
}

class VenueReviewsCubit extends Cubit<VenueReviewsState> {
  VenueReviewsCubit(this._repository, this.venueId)
    : super(const VenueReviewsState()) {
    load();
  }

  final HomeRepository _repository;
  final String venueId;
  String? _cursor;
  var _requestId = 0;

  Future<void> load() async {
    final requestId = ++_requestId;
    _cursor = null;
    emit(const VenueReviewsState(status: AppLoading.loading, errorMessage: ''));
    await _fetchPage(requestId, append: false);
  }

  Future<void> loadMore() async {
    if (state.status.isLoading ||
        state.paging ||
        !state.hasMore ||
        state.reviews.isEmpty) {
      return;
    }
    final requestId = ++_requestId;
    emit(state.copyWith(paging: true, errorMessage: ''));
    await _fetchPage(requestId, append: true);
  }

  Future<void> _fetchPage(int requestId, {required bool append}) async {
    final result = await _repository.fetchVenueReviews(
      venueId,
      cursor: append ? _cursor : null,
    );
    if (isClosed || requestId != _requestId) return;
    result.when(
      success: (page) {
        _cursor = page.nextCursor;
        emit(
          VenueReviewsState(
            status: AppLoading.success,
            reviews: append ? [...state.reviews, ...page.items] : page.items,
            hasMore: page.hasMore,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: append ? state.status : AppLoading.error,
            paging: false,
            errorMessage: error.message,
          ),
        );
      },
    );
  }
}
