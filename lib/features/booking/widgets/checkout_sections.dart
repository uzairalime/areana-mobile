import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/enums/app_loading.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../auth/model/user_model.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

/// Checkout sections, extracted so the checkout screen stays under
/// 500 lines. Pay-at-venue only (user-web launch flow); promo via
/// `GET /bookings/validate-promo`.
class CheckoutGuestCallout extends StatelessWidget {
  const CheckoutGuestCallout({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.person_outline, color: AppColors.primary),
            ),
          ),
          12.w,
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                'Booking as a guest',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w800,
                  fontSize: 15,
                ),
              ),
              4.h,
              Text(
                'You will log in or create an account when you confirm. Your court, date and time stay saved.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ).expand(),
        ],
      ).paddingAll(14),
    );
  }
}

class CheckoutAccountCard extends StatelessWidget {
  const CheckoutAccountCard({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final name = user.name.isEmpty ? 'Player' : user.name;
    final phone = user.phone.isNotEmpty ? user.phone : user.email;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          ProfileAvatar(username: name, url: user.avatarUrl, size: 44),
          12.w,
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                name,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w800,
                  fontSize: 15,
                ),
              ),
              2.h,
              Text(
                phone,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ).expand(),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.payBadgeText,
                ),
                4.w,
                Text(
                  'Logged in',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.payBadgeText,
                    fontWeight: .w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 10, vertical: 6),
          ),
        ],
      ).paddingAll(14),
    );
  }
}

class CheckoutPromoField extends StatelessWidget {
  const CheckoutPromoField({super.key, required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingCubit>();
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Promo code',
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: 17,
            fontWeight: .w800,
          ),
        ),
        12.h,
        Row(
          children: [
            AppTextField(
              label: 'Promo code',
              controller: cubit.promoController,
              icon: Icons.local_offer_outlined,
              hint: 'Enter promo code',
              onChanged: cubit.setPromoCode,
            ).expand(),
            8.w,
            AppButton(
              label: 'Apply',
              loading: state.promoStatus.isLoading,
              onPressed: state.promoCode.trim().isEmpty
                  ? null
                  : cubit.validatePromo,
            ),
          ],
        ),
        if (state.promo != null) ...[
          8.h,
          Text(
            'Promo ${state.promo!.code} applied — '
            '${MoneyFormat.pkr(state.promo!.discount)} off.',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: .w700,
            ),
          ),
        ],
        if (state.promoError.isNotEmpty) ...[
          8.h,
          Text(
            state.promoError,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class CheckoutPayGroundCard extends StatelessWidget {
  const CheckoutPayGroundCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront_outlined, color: AppColors.primary),
          12.w,
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                'Pay at ground',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w800,
                ),
              ),
              2.h,
              Text(
                'Pay by cash or card at the front desk when you arrive.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ).expand(),
          const Icon(Icons.check_circle, color: AppColors.primary),
        ],
      ).paddingAll(14),
    );
  }
}

class CheckoutPriceCard extends StatelessWidget {
  const CheckoutPriceCard({super.key, required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          _PriceRow(label: 'Court fee', value: MoneyFormat.pkr(state.grossTotal)),
          if (state.discount > 0) ...[
            8.h,
            _PriceRow(
              label: 'Promo discount',
              value: '- ${MoneyFormat.pkr(state.discount)}',
            ),
          ],
          8.h,
          const Divider(height: 1),
          8.h,
          _PriceRow(
            label: 'Due at ground',
            value: MoneyFormat.pkr(state.total),
            bold: true,
          ),
        ],
      ).paddingAll(14),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: context.textTheme.bodyMedium).expand(),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: bold ? .w800 : .w600,
          ),
        ),
      ],
    );
  }
}
