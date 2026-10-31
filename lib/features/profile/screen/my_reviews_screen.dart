import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/deep_link/deep_link_service.dart';
import '../../../core/deep_link/deep_link_uri.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/services/locator.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../model/user_review.dart';
import '../widgets/my_reviews_shimmer.dart';
import '../widgets/profile_subpage_scaffold.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadReviews();
  }

  Future<void> _openPastBookings() async {
    AppHaptics.selection();
    await getIt<DeepLinkService>().handleRaw(kBookingsPastDeepLink);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        return ProfileSubpageScaffold(
          title: 'My reviews',
          body: AppLoadingHandler(
            status: state.status,
            errorMessage: state.errorMessage,
            onRetry: cubit.loadReviews,
            loading: const MyReviewsShimmer(),
            child: state.reviews.isEmpty
                ? ListView(
                    padding: const .fromLTRB(20, 48, 20, 28),
                    children: [
                      const Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ).center(),
                      16.h,
                      Text(
                        'No reviews yet',
                        textAlign: .center,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontSize: 20,
                        ),
                      ),
                      8.h,
                      Text(
                        'After you play, rate the venue so other players know what to expect.',
                        textAlign: .center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const .fromLTRB(20, 8, 20, 28),
                    itemCount: state.reviews.length,
                    separatorBuilder: (_, _) => 12.h,
                    itemBuilder: (context, index) {
                      final review = state.reviews[index];
                      return review.pending
                          ? _PendingReviewCard(
                              review: review,
                              onWrite: _openPastBookings,
                            )
                          : _ReviewCard(review: review);
                    },
                  ),
          ),
        );
      },
    );
  }
}

class _PendingReviewCard extends StatelessWidget {
  const _PendingReviewCard({required this.review, required this.onWrite});

  final UserReview review;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Padding(
        padding: const .all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    review.promptTitle.isEmpty
                        ? 'How was ${review.venueName}?'
                        : review.promptTitle,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: .w800,
                      fontSize: 15,
                      height: 1.25,
                    ),
                  ),
                  6.h,
                  Text(
                    review.promptBody,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.82),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            10.w,
            FilledButton(
              onPressed: onWrite,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                minimumSize: const Size(0, 40),
                padding: const .symmetric(horizontal: 18),
                tapTargetSize: .shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Write',
                style: context.textTheme.labelLarge?.copyWith(
                  color: AppColors.onAccent,
                  fontWeight: .w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final UserReview review;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Padding(
        padding: const .fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              crossAxisAlignment: .start,
              children: [
                Text(
                  review.venueName,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: .w800,
                    fontSize: 15,
                    height: 1.25,
                  ),
                ).expand(),
                10.w,
                Text(
                  review.dateLabel,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: .w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            8.h,
            _StarRating(rating: review.displayRating),
            10.h,
            Text(
              review.body,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.text,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: [
        for (var i = 1; i <= 5; i++)
          Padding(
            padding: EdgeInsets.only(right: i < 5 ? 2 : 0),
            child: Icon(
              i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 18,
              color: i <= rating ? AppColors.rating : AppColors.border,
            ),
          ),
      ],
    );
  }
}
