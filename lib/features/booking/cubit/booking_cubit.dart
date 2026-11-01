import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../../../core/services/notification/notification_service.dart';
import '../../../core/utils/app_haptics.dart';
import '../../home/model/venue.dart';
import 'booking_repository.dart';
import 'booking_state.dart';

/// Court-first booking, like user-web: pick a court, a date, a slot
/// (plus consecutive slots via slotCount), an optional promo, then
/// confirm pay-at-venue. The server is the final guard: a clash or a
/// changed price surfaces as its 400/409 message, never a local guess.
class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this._repository, this._notifications)
      : super(const BookingState());

  final BookingRepository _repository;
  final NotificationService _notifications;
  final promoController = TextEditingController();

  Future<void> start(Venue venue, {String? preselectedCourtId}) async {
    emit(
      BookingState(
        status: AppLoading.loading,
        venue: venue,
        payMethod: PayMethod.ground,
        selectedDate: formatDate(DateTime.now()),
      ),
    );
    final result = await _repository.fetchVenueCourts(venue.id);
    if (isClosed) return;
    await result.when(
      success: (courts) async {
        final selectedId = preselectedCourtId != null &&
                courts.any((c) => c.id == preselectedCourtId)
            ? preselectedCourtId
            : (courts.isEmpty ? null : courts.first.id);
        emit(
          state.copyWith(
            status: AppLoading.success,
            courts: courts,
            selectedCourtId: selectedId,
            errorMessage: '',
            clearSlot: true,
            clearConfirmation: true,
          ),
        );
        if (selectedId != null) await _loadAvailability();
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

  Future<void> _loadAvailability() async {
    final courtId = state.selectedCourtId;
    final date = state.selectedDate;
    if (courtId == null || date == null) return;
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.fetchAvailability(
      courtId: courtId,
      date: date,
    );
    if (isClosed) return;
    result.when(
      success: (availability) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            slots: availability.slots,
            errorMessage: '',
            clearSlot: true,
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

  Future<void> selectCourt(String id) async {
    if (id == state.selectedCourtId) return;
    AppHaptics.selection();
    emit(state.copyWith(selectedCourtId: id, clearSlot: true));
    await _loadAvailability();
  }

  Future<void> selectDate(DateTime date) async {
    final value = formatDate(date);
    if (value == state.selectedDate) return;
    AppHaptics.selection();
    emit(state.copyWith(selectedDate: value, clearSlot: true));
    await _loadAvailability();
  }

  void selectSlot(int startMinutes) {
    final slot = state.slots.where((s) => s.startMinutes == startMinutes);
    if (slot.isEmpty || !slot.first.available) return;
    AppHaptics.selection();
    emit(state.copyWith(selectedStartMinutes: startMinutes));
  }

  void selectSlotCount(int count) {
    if (count < 1 || count == state.slotCount) return;
    AppHaptics.selection();
    emit(state.copyWith(slotCount: count, clearPromo: true, promoError: ''));
  }

  void selectPayMethod(PayMethod method) {
    if (method == state.payMethod) return;
    AppHaptics.selection();
    emit(state.copyWith(payMethod: method));
  }

  void setPromoCode(String code) {
    emit(state.copyWith(promoCode: code, clearPromo: true, promoError: ''));
  }

  Future<void> validatePromo() async {
    final code = state.promoCode.trim();
    final courtId = state.selectedCourtId;
    if (code.isEmpty || courtId == null) return;
    emit(state.copyWith(promoStatus: AppLoading.loading, promoError: ''));
    final result = await _repository.validatePromo(
      code: code,
      courtId: courtId,
      slotCount: state.slotCount,
      date: state.selectedDate,
      startMinutes: state.selectedStartMinutes,
    );
    if (isClosed) return;
    result.when(
      success: (promo) {
        emit(
          state.copyWith(promoStatus: AppLoading.success, promo: promo),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            promoStatus: AppLoading.error,
            promoError: error.message,
            clearPromo: true,
          ),
        );
      },
    );
  }

  Future<bool> confirmBooking() async {
    final courtId = state.selectedCourtId;
    final date = state.selectedDate;
    final start = state.selectedStartMinutes;
    if (courtId == null || date == null || start == null || !state.canContinue) {
      return false;
    }
    AppHaptics.medium();
    emit(state.copyWith(confirmStatus: AppLoading.loading, errorMessage: ''));
    final result = await _repository.confirmBooking(
      courtId: courtId,
      date: date,
      startMinutes: start,
      slotCount: state.slotCount,
      promoCode: state.promoCode.trim().isEmpty ? null : state.promoCode.trim(),
      // User-web price guard: the server 400s with the new total if
      // the price moved since the player saw it, instead of booking
      // silently at a new price.
      expectedTotal: state.total,
    );
    if (isClosed) return false;
    return result.when(
      success: (confirmation) {
        AppHaptics.success();
        emit(
          state.copyWith(
            confirmStatus: AppLoading.success,
            confirmation: confirmation,
            errorMessage: '',
          ),
        );
        unawaited(
          _notifications.show(
            type: .booking,
            title: 'Booking confirmed',
            body:
                '${confirmation.courtName} at ${confirmation.venueName}, '
                '${confirmation.date} ${confirmation.timeLabel}.',
            link: '/bookings',
            id: confirmation.code,
          ),
        );
        return true;
      },
      failure: (error) {
        emit(
          state.copyWith(
            confirmStatus: AppLoading.error,
            errorMessage: error.message,
          ),
        );
        return false;
      },
    );
  }

  Future<void> loadShare() async {
    final confirmation = state.confirmation;
    if (confirmation == null) return;
    final result = await _repository.shareBooking(confirmation.id);
    if (isClosed) return;
    result.when(
      success: (share) => emit(state.copyWith(share: share)),
      failure: (_) {},
    );
  }

  void clearConfirmError() {
    if (state.errorMessage.isEmpty && !state.confirmStatus.isError) return;
    emit(
      state.copyWith(confirmStatus: AppLoading.initial, errorMessage: ''),
    );
  }

  @override
  Future<void> close() {
    promoController.dispose();
    return super.close();
  }
}
