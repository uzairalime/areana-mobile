import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../../home/model/venue.dart';
import '../model/booking_confirmation.dart';
import '../model/booking_date.dart';
import '../model/court_option.dart';
import '../model/time_slot.dart';

enum PayMethod { ground, online }

class BookingState extends Equatable {
  const BookingState({
    this.status = AppLoading.initial,
    this.confirmStatus = AppLoading.initial,
    this.errorMessage = '',
    this.venue,
    this.courts = const [],
    this.dates = const [],
    this.durations = const [],
    this.slots = const [],
    this.selectedCourtId,
    this.selectedDateId,
    this.selectedDuration,
    this.selectedSlotId,
    this.payMethod = PayMethod.ground,
    this.confirmation,
  });

  final AppLoading status;
  final AppLoading confirmStatus;
  final String errorMessage;
  final Venue? venue;
  final List<CourtOption> courts;
  final List<BookingDate> dates;
  final List<String> durations;
  final List<TimeSlot> slots;
  final String? selectedCourtId;
  final String? selectedDateId;
  final String? selectedDuration;
  final String? selectedSlotId;
  final PayMethod payMethod;
  final BookingConfirmation? confirmation;

  CourtOption? get selectedCourt {
    for (final court in courts) {
      if (court.id == selectedCourtId) {
        return court;
      }
    }
    return null;
  }

  BookingDate? get selectedDate {
    for (final date in dates) {
      if (date.id == selectedDateId) {
        return date;
      }
    }
    return null;
  }

  TimeSlot? get selectedSlot {
    for (final slot in slots) {
      if (slot.id == selectedSlotId) {
        return slot;
      }
    }
    return null;
  }

  bool get canContinue =>
      selectedCourt != null && selectedDate != null && selectedSlot != null;

  int get total => selectedSlot?.price ?? 0;

  String get summaryLine {
    final date = selectedDate?.fullLabel ?? '';
    final slot = selectedSlot?.label ?? '';
    if (date.isEmpty || slot.isEmpty) {
      return '';
    }
    return '$date · $slot';
  }

  BookingState copyWith({
    AppLoading? status,
    AppLoading? confirmStatus,
    String? errorMessage,
    Venue? venue,
    List<CourtOption>? courts,
    List<BookingDate>? dates,
    List<String>? durations,
    List<TimeSlot>? slots,
    String? selectedCourtId,
    String? selectedDateId,
    String? selectedDuration,
    String? selectedSlotId,
    PayMethod? payMethod,
    BookingConfirmation? confirmation,
    bool clearSlot = false,
    bool clearConfirmation = false,
  }) {
    return BookingState(
      status: status ?? this.status,
      confirmStatus: confirmStatus ?? this.confirmStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      venue: venue ?? this.venue,
      courts: courts ?? this.courts,
      dates: dates ?? this.dates,
      durations: durations ?? this.durations,
      slots: slots ?? this.slots,
      selectedCourtId: selectedCourtId ?? this.selectedCourtId,
      selectedDateId: selectedDateId ?? this.selectedDateId,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      selectedSlotId: clearSlot
          ? null
          : selectedSlotId ?? this.selectedSlotId,
      payMethod: payMethod ?? this.payMethod,
      confirmation: clearConfirmation
          ? null
          : confirmation ?? this.confirmation,
    );
  }

  @override
  List<Object?> get props => [
    status,
    confirmStatus,
    errorMessage,
    venue,
    courts,
    dates,
    durations,
    slots,
    selectedCourtId,
    selectedDateId,
    selectedDuration,
    selectedSlotId,
    payMethod,
    confirmation,
  ];
}
