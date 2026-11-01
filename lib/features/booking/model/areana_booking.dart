import 'package:equatable/equatable.dart';

String _str(dynamic value) => value?.toString() ?? '';
int _int(dynamic value, [int fallback = 0]) =>
    value is num ? value.toInt() : fallback;

String _fmtMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

/// `POST /bookings` response, mirroring user-web CreateBookingResponse.
/// The confirmed screen's old field names are kept as getters so it
/// does not need a rewrite: `code` is the check-in code, `shareCode`
/// is the group share link code (`/join/<shareCode>` on web).
class BookingConfirmation extends Equatable {
  const BookingConfirmation({
    required this.id,
    required this.venueId,
    required this.courtId,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    required this.totalPrice,
    required this.discountAmount,
    required this.status,
    required this.shareCode,
    required this.checkInCode,
    this.recurrenceId,
    this.createdAt,
    this.expiresAt,
    this.venueName = '',
    this.sport = '',
    this.location = '',
    this.courtName = '',
    this.slotCount = 1,
  });

  factory BookingConfirmation.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'];
    final venueMap = venue is Map ? Map<String, dynamic>.from(venue) : const {};
    final court = json['court'];
    final courtMap = court is Map ? Map<String, dynamic>.from(court) : const {};
    final slotMinutes = _int(json['slotMinutes'], 60);
    final start = _int(json['startMinutes']);
    final end = _int(json['endMinutes']);
    final count = slotMinutes > 0 ? ((end - start) ~/ slotMinutes) : 1;
    return BookingConfirmation(
      id: _str(json['id']),
      venueId: _str(json['venueId']),
      courtId: _str(json['courtId']),
      date: _str(json['date']),
      startMinutes: start,
      endMinutes: end,
      totalPrice: _int(json['totalPrice']),
      discountAmount: _int(json['discountAmount']),
      status: _str(json['status']),
      shareCode: _str(json['shareCode']),
      checkInCode: _str(json['checkInCode']),
      recurrenceId: json['recurrenceId'] as String?,
      createdAt: json['createdAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      venueName: _str(venueMap['name']),
      location: _str(venueMap['address']),
      courtName: _str(courtMap['name']),
      sport: _str(courtMap['sport']),
      slotCount: count < 1 ? 1 : count,
    );
  }

  final String id;
  final String venueId;
  final String courtId;
  final String date;
  final int startMinutes;
  final int endMinutes;
  final int totalPrice;
  final int discountAmount;
  final String status;
  final String shareCode;
  final String checkInCode;
  final String? recurrenceId;
  final String? createdAt;
  final String? expiresAt;
  final String venueName;
  final String sport;
  final String location;
  final String courtName;
  final int slotCount;

  // Confirmed-screen compatibility (derived, never invented).
  String get code => checkInCode;
  String get dateLabel => date;
  String get timeLabel => '${_fmtMinutes(startMinutes)} – ${_fmtMinutes(endMinutes)}';
  String get courtLabel => courtName;
  String get durationLabel => '$slotCount slot${slotCount == 1 ? '' : 's'}';
  int get amountDue => totalPrice;
  bool get payAtGround => true;

  @override
  List<Object?> get props => [id, date, startMinutes, totalPrice, status];
}

class PromoPreview extends Equatable {
  const PromoPreview({
    required this.code,
    required this.kind,
    required this.value,
    this.maxDiscount,
    required this.discount,
  });

  factory PromoPreview.fromJson(Map<String, dynamic> json) {
    final promo = json['promo'];
    final promoMap = promo is Map ? Map<String, dynamic>.from(promo) : const {};
    return PromoPreview(
      code: _str(promoMap['code']),
      kind: _str(promoMap['kind']),
      value: _int(promoMap['value']),
      maxDiscount: promoMap['maxDiscount'] is num
          ? (promoMap['maxDiscount'] as num).toInt()
          : null,
      discount: _int(json['discount']),
    );
  }

  final String code;
  final String kind;
  final int value;
  final int? maxDiscount;
  final int discount;

  @override
  List<Object?> get props => [code, discount];
}

class ShareResult extends Equatable {
  const ShareResult({required this.shareCode, required this.joinUrl});

  factory ShareResult.fromJson(Map<String, dynamic> json) {
    return ShareResult(
      shareCode: _str(json['shareCode']),
      joinUrl: _str(json['joinUrl']),
    );
  }

  final String shareCode;
  final String joinUrl;

  @override
  List<Object?> get props => [shareCode, joinUrl];
}
