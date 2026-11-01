import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../../home/model/areana_models.dart';
import '../../home/model/venue.dart';
import '../model/areana_booking.dart';

/// Launch payment is pay-at-venue only (user-web). The enum is kept
/// for the checkout UI's single ground option.
enum PayMethod { ground, online }

String _fmtMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

String formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class BookingState extends Equatable {
  const BookingState({
    this.status = AppLoading.initial,
    this.confirmStatus = AppLoading.initial,
    this.errorMessage = '',
    this.venue,
    this.courts = const [],
    this.selectedCourtId,
    this.selectedDate,
    this.slots = const [],
    this.selectedStartMinutes,
    this.slotCount = 1,
    this.payMethod = PayMethod.ground,
    this.promoCode = '',
    this.promo,
    this.promoError = '',
    this.promoStatus = AppLoading.initial,
    this.confirmation,
    this.share,
  });

  final AppLoading status;
  final AppLoading confirmStatus;
  final String errorMessage;
  final Venue? venue;
  final List<AreanaCourt> courts;
  final String? selectedCourtId;

  /// `YYYY-MM-DD`, server format for availability + booking create.
  final String? selectedDate;
  final List<AvailabilitySlot> slots;
  final int? selectedStartMinutes;
  final int slotCount;
  final PayMethod payMethod;
  final String promoCode;
  final PromoPreview? promo;
  final String promoError;
  final AppLoading promoStatus;
  final BookingConfirmation? confirmation;
  final ShareResult? share;

  AreanaCourt? get selectedCourt {
    for (final court in courts) {
      if (court.id == selectedCourtId) return court;
    }
    return null;
  }

  AvailabilitySlot? get selectedSlot {
    for (final slot in slots) {
      if (slot.startMinutes == selectedStartMinutes) return slot;
    }
    return null;
  }

  /// Consecutive slots from the selection, for the total. If any of
  /// them is unavailable the selection is not bookable (the server
  /// is the final guard and will 409 on a clash).
  List<AvailabilitySlot> get selectedSlots {
    final start = selectedStartMinutes;
    if (start == null) return const [];
    final result = <AvailabilitySlot>[];
    for (var i = 0; i < slotCount; i++) {
      AvailabilitySlot? found;
      for (final slot in slots) {
        if (slot.startMinutes == start + i * (selectedCourt?.slotMinutes ?? 60)) {
          found = slot;
          break;
        }
      }
      if (found == null) return const [];
      result.add(found);
    }
    return result;
  }

  bool get selectedSlotsAvailable =>
      selectedSlots.length == slotCount &&
      selectedSlots.every((s) => s.available);

  bool get canContinue =>
      selectedCourt != null &&
      selectedDate != null &&
      selectedStartMinutes != null &&
      selectedSlotsAvailable;

  int get grossTotal =>
      selectedSlots.fold(0, (sum, slot) => sum + slot.price);

  int get discount => promo?.discount ?? 0;

  int get total => grossTotal - discount < 0 ? 0 : grossTotal - discount;

  String get summaryLine {
    final date = selectedDate ?? '';
    final slot = selectedSlot;
    if (date.isEmpty || slot == null) return '';
    return '$date · ${slot.label}';
  }

  String get timeRange {
    final slot = selectedSlot;
    if (slot == null) return '—';
    final end = slot.startMinutes +
        slotCount * (selectedCourt?.slotMinutes ?? 60);
    return '${_fmtMinutes(slot.startMinutes)} – ${_fmtMinutes(end)}';
  }

  BookingState copyWith({
    AppLoading? status,
    AppLoading? confirmStatus,
    String? errorMessage,
    Venue? venue,
    List<AreanaCourt>? courts,
    String? selectedCourtId,
    String? selectedDate,
    List<AvailabilitySlot>? slots,
    int? selectedStartMinutes,
    int? slotCount,
    PayMethod? payMethod,
    String? promoCode,
    PromoPreview? promo,
    String? promoError,
    AppLoading? promoStatus,
    BookingConfirmation? confirmation,
    ShareResult? share,
    bool clearSlot = false,
    bool clearPromo = false,
    bool clearConfirmation = false,
  }) {
    return BookingState(
      status: status ?? this.status,
      confirmStatus: confirmStatus ?? this.confirmStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      venue: venue ?? this.venue,
      courts: courts ?? this.courts,
      selectedCourtId: selectedCourtId ?? this.selectedCourtId,
      selectedDate: selectedDate ?? this.selectedDate,
      slots: slots ?? this.slots,
      selectedStartMinutes:
          clearSlot ? null : selectedStartMinutes ?? this.selectedStartMinutes,
      slotCount: slotCount ?? this.slotCount,
      payMethod: payMethod ?? this.payMethod,
      promoCode: promoCode ?? this.promoCode,
      promo: clearPromo ? null : promo ?? this.promo,
      promoError: promoError ?? this.promoError,
      promoStatus: promoStatus ?? this.promoStatus,
      confirmation:
          clearConfirmation ? null : confirmation ?? this.confirmation,
      share: share ?? this.share,
    );
  }

  @override
  List<Object?> get props => [
    status,
    confirmStatus,
    errorMessage,
    venue,
    courts,
    selectedCourtId,
    selectedDate,
    slots,
    selectedStartMinutes,
    slotCount,
    payMethod,
    promoCode,
    promo,
    promoError,
    promoStatus,
    confirmation,
    share,
  ];
}
