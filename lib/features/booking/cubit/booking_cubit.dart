import 'dart:async' show unawaited;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../../../core/services/notification/notification_service.dart';
import '../../../core/utils/app_haptics.dart';
import '../../home/model/venue.dart';
import '../model/time_slot.dart';
import 'booking_repository.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this._repository, this._notifications)
    : super(const BookingState());

  final BookingRepository _repository;
  final NotificationService _notifications;

  Future<void> start(Venue venue) async {
    emit(
      BookingState(
        status: AppLoading.loading,
        venue: venue,
        payMethod: PayMethod.ground,
      ),
    );
    final result = await _repository.fetchAvailability(venue);
    if (isClosed) {
      return;
    }
    result.when(
      success: (availability) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            courts: availability.courts,
            dates: availability.dates,
            durations: availability.durations,
            slots: availability.slots,
            selectedCourtId: availability.courts.isEmpty
                ? null
                : availability.courts.first.id,
            selectedDateId: availability.dates.isEmpty
                ? null
                : availability.dates.first.id,
            selectedDuration: availability.durations.isEmpty
                ? null
                : availability.durations.first,
            errorMessage: '',
            clearSlot: true,
            clearConfirmation: true,
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

  void selectCourt(String id) {
    if (id == state.selectedCourtId) {
      return;
    }
    AppHaptics.selection();
    emit(state.copyWith(selectedCourtId: id));
  }

  void selectDate(String id) {
    if (id == state.selectedDateId) {
      return;
    }
    AppHaptics.selection();
    emit(state.copyWith(selectedDateId: id, clearSlot: true));
  }

  void selectDuration(String value) {
    if (value == state.selectedDuration) {
      return;
    }
    AppHaptics.selection();
    emit(state.copyWith(selectedDuration: value, clearSlot: true));
  }

  void selectSlot(String id) {
    TimeSlot? slot;
    for (final item in state.slots) {
      if (item.id == id) {
        slot = item;
        break;
      }
    }
    if (slot == null || slot.isBooked) {
      return;
    }
    AppHaptics.selection();
    emit(state.copyWith(selectedSlotId: id));
  }

  void selectPayMethod(PayMethod method) {
    if (method == state.payMethod) {
      return;
    }
    AppHaptics.selection();
    emit(state.copyWith(payMethod: method));
  }

  Future<bool> confirmBooking() async {
    final venue = state.venue;
    final court = state.selectedCourt;
    final date = state.selectedDate;
    final slot = state.selectedSlot;
    final duration = state.selectedDuration;
    if (venue == null ||
        court == null ||
        date == null ||
        slot == null ||
        duration == null) {
      return false;
    }
    AppHaptics.medium();
    emit(state.copyWith(confirmStatus: AppLoading.loading, errorMessage: ''));
    final result = await _repository.confirmBooking(
      venue: venue,
      court: court,
      date: date,
      slot: slot,
      duration: duration,
      payAtGround: state.payMethod == PayMethod.ground,
    );
    if (isClosed) {
      return false;
    }
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
                '${confirmation.courtLabel} at ${confirmation.venueName}, '
                '${confirmation.dateLabel} ${confirmation.timeLabel}.',
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

  void clearConfirmError() {
    if (state.errorMessage.isEmpty && !state.confirmStatus.isError) {
      return;
    }
    emit(
      state.copyWith(confirmStatus: AppLoading.initial, errorMessage: ''),
    );
  }
}
