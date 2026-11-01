import 'package:equatable/equatable.dart';

import '../../../core/consts/app_colors.dart';
import 'venue.dart';

/// Areana server models, mirroring user-web `lib/player-types.ts`
/// field-for-field. These are the data layer for discovery, booking
/// and detail; the existing UI models ([Venue] etc.) are filled from
/// them so current widgets keep working without invented fields.

List<String> _stringList(dynamic value) => value is List
    ? value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
    : const [];

double? _numOrNull(dynamic value) => value is num ? value.toDouble() : null;

int _int(dynamic value, [int fallback = 0]) =>
    value is num ? value.toInt() : fallback;

String _str(dynamic value) => value?.toString() ?? '';

class AreanaVenue extends Equatable {
  const AreanaVenue({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.phone,
    this.lat,
    this.lng,
    this.sports = const [],
    this.amenities = const [],
    this.images = const [],
    this.rating = 0,
    this.ratingCount = 0,
    this.fromPrice,
    this.distanceKm,
    this.autoAccept = false,
    this.courtCount = 0,
  });

  factory AreanaVenue.fromJson(Map<String, dynamic> json) {
    final count = json['_count'];
    return AreanaVenue(
      id: _str(json['id']),
      name: _str(json['name']),
      address: _str(json['address']),
      city: _str(json['city']),
      phone: json['phone'] as String?,
      lat: _numOrNull(json['lat']),
      lng: _numOrNull(json['lng']),
      sports: _stringList(json['sports']),
      amenities: _stringList(json['amenities']),
      images: _stringList(json['images']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: _int(json['ratingCount']),
      fromPrice: _numOrNull(json['fromPrice']),
      distanceKm: _numOrNull(json['distanceKm']),
      autoAccept: json['autoAccept'] as bool? ?? false,
      courtCount: count is Map ? _int(count['courts']) : 0,
    );
  }

  final String id;
  final String name;
  final String address;
  final String city;
  final String? phone;
  final double? lat;
  final double? lng;
  final List<String> sports;
  final List<String> amenities;
  final List<String> images;
  final double rating;
  final int ratingCount;
  final double? fromPrice;
  final double? distanceKm;
  final bool autoAccept;
  final int courtCount;

  String get location => city.isEmpty ? address : '$address, $city';

  /// Adapter for the existing venue UI (cards, map, detail header).
  /// Every field comes from the server row; nothing is invented.
  Venue toVenue() => Venue(
    id: id,
    name: name,
    sport: sports.isNotEmpty ? sports.first : '',
    location: location,
    priceFrom: fromPrice?.toInt() ?? 0,
    amenities: amenities,
    nextSlot: '',
    heroColor: AppColors.primary,
    rating: rating,
    reviewCount: ratingCount,
    courtsLabel: courtCount > 0 ? '$courtCount courts' : '',
    latitude: lat ?? 0,
    longitude: lng ?? 0,
    imageUrls: images,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'city': city,
    'phone': phone,
    'lat': lat,
    'lng': lng,
    'sports': sports,
    'amenities': amenities,
    'images': images,
    'rating': rating,
    'ratingCount': ratingCount,
    'fromPrice': fromPrice,
    'distanceKm': distanceKm,
    'autoAccept': autoAccept,
  };

  @override
  List<Object?> get props => [id, name, address, city, rating, fromPrice];
}

class AreanaCourt extends Equatable {
  const AreanaCourt({
    required this.id,
    required this.venueId,
    required this.name,
    required this.sport,
    this.size,
    this.surface,
    this.indoor = false,
    this.pricePerHour = 0,
    this.openMinutes = 0,
    this.closeMinutes = 0,
    this.slotMinutes = 60,
    this.images = const [],
  });

  factory AreanaCourt.fromJson(Map<String, dynamic> json) {
    return AreanaCourt(
      id: _str(json['id']),
      venueId: _str(json['venueId']),
      name: _str(json['name']),
      sport: _str(json['sport']),
      size: json['size'] as String?,
      surface: json['surface'] as String?,
      indoor: json['indoor'] as bool? ?? false,
      pricePerHour: _int(json['pricePerHour']),
      openMinutes: _int(json['openMinutes']),
      closeMinutes: _int(json['closeMinutes']),
      slotMinutes: _int(json['slotMinutes'], 60),
      images: _stringList(json['images']),
    );
  }

  final String id;
  final String venueId;
  final String name;
  final String sport;
  final String? size;
  final String? surface;
  final bool indoor;
  final int pricePerHour;
  final int openMinutes;
  final int closeMinutes;
  final int slotMinutes;
  final List<String> images;

  String get specLine {
    final parts = <String>[sport];
    if (size != null && size!.isNotEmpty) parts.add(size!);
    if (surface != null && surface!.isNotEmpty) parts.add(surface!);
    parts.add(indoor ? 'Indoor' : 'Outdoor');
    return parts.join(' · ');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'venueId': venueId,
    'name': name,
    'sport': sport,
    'size': size,
    'surface': surface,
    'indoor': indoor,
    'pricePerHour': pricePerHour,
    'openMinutes': openMinutes,
    'closeMinutes': closeMinutes,
    'slotMinutes': slotMinutes,
    'images': images,
  };

  @override
  List<Object?> get props => [id, venueId, name, sport, pricePerHour];
}

class AreanaCourtListItem extends Equatable {
  const AreanaCourtListItem({
    required this.court,
    required this.venueId,
    required this.venueName,
    required this.venueCity,
    required this.venueAddress,
    this.venueLat,
    this.venueLng,
    this.venueRating = 0,
    this.venueRatingCount = 0,
    this.venueImages = const [],
    this.distanceKm,
  });

  factory AreanaCourtListItem.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'];
    final venueMap = venue is Map ? Map<String, dynamic>.from(venue) : const {};
    return AreanaCourtListItem(
      court: AreanaCourt.fromJson(json),
      venueId: _str(venueMap['id']),
      venueName: _str(venueMap['name']),
      venueCity: _str(venueMap['city']),
      venueAddress: _str(venueMap['address']),
      venueLat: _numOrNull(venueMap['lat']),
      venueLng: _numOrNull(venueMap['lng']),
      venueRating: (venueMap['rating'] as num?)?.toDouble() ?? 0,
      venueRatingCount: _int(venueMap['ratingCount']),
      venueImages: _stringList(venueMap['images']),
      distanceKm: _numOrNull(json['distanceKm']),
    );
  }

  final AreanaCourt court;
  final String venueId;
  final String venueName;
  final String venueCity;
  final String venueAddress;
  final double? venueLat;
  final double? venueLng;
  final double venueRating;
  final int venueRatingCount;
  final List<String> venueImages;
  final double? distanceKm;

  /// Venue row for the existing booking flow, filled from the court
  /// list item's venue fields. The booking flow itself (section 2)
  /// preselects this court by id.
  Venue toVenue() => Venue(
    id: venueId,
    name: venueName,
    sport: court.sport,
    location: venueCity.isEmpty ? venueAddress : '$venueAddress, $venueCity',
    priceFrom: court.pricePerHour,
    amenities: const [],
    nextSlot: '',
    heroColor: AppColors.primary,
    rating: venueRating,
    reviewCount: venueRatingCount,
    latitude: venueLat ?? 0,
    longitude: venueLng ?? 0,
    imageUrls: venueImages,
  );

  @override
  List<Object?> get props => [court, venueId, venueName];
}

class AreanaVenueDetail extends Equatable {
  const AreanaVenueDetail({
    required this.venue,
    this.maxAdvanceDays,
    this.minAdvanceMinutes,
    this.courts = const [],
  });

  factory AreanaVenueDetail.fromJson(Map<String, dynamic> json) {
    return AreanaVenueDetail(
      venue: AreanaVenue.fromJson(json),
      maxAdvanceDays: _numOrNull(json['maxAdvanceDays'])?.toInt(),
      minAdvanceMinutes: _numOrNull(json['minAdvanceMinutes'])?.toInt(),
      courts: (json['courts'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => AreanaCourt.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  final AreanaVenue venue;
  final int? maxAdvanceDays;
  final int? minAdvanceMinutes;
  final List<AreanaCourt> courts;

  @override
  List<Object?> get props => [venue, courts];
}

class AreanaCourtDetail extends Equatable {
  const AreanaCourtDetail({
    required this.court,
    required this.venueId,
    required this.venueName,
    required this.venueCity,
    required this.venueAddress,
    this.venueLat,
    this.venueLng,
    this.venueRating = 0,
    this.venueRatingCount = 0,
    this.venueImages = const [],
    this.venueAmenities = const [],
    this.maxAdvanceDays = 0,
    this.minAdvanceMinutes = 0,
  });

  factory AreanaCourtDetail.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'];
    final venueMap = venue is Map ? Map<String, dynamic>.from(venue) : const {};
    return AreanaCourtDetail(
      court: AreanaCourt.fromJson(json),
      venueId: _str(venueMap['id']),
      venueName: _str(venueMap['name']),
      venueCity: _str(venueMap['city']),
      venueAddress: _str(venueMap['address']),
      venueLat: _numOrNull(venueMap['lat']),
      venueLng: _numOrNull(venueMap['lng']),
      venueRating: (venueMap['rating'] as num?)?.toDouble() ?? 0,
      venueRatingCount: _int(venueMap['ratingCount']),
      venueImages: _stringList(venueMap['images']),
      venueAmenities: _stringList(venueMap['amenities']),
      maxAdvanceDays: _int(venueMap['maxAdvanceDays']),
      minAdvanceMinutes: _int(venueMap['minAdvanceMinutes']),
    );
  }

  final AreanaCourt court;
  final String venueId;
  final String venueName;
  final String venueCity;
  final String venueAddress;
  final double? venueLat;
  final double? venueLng;
  final double venueRating;
  final int venueRatingCount;
  final List<String> venueImages;
  final List<String> venueAmenities;
  final int maxAdvanceDays;
  final int minAdvanceMinutes;

  @override
  List<Object?> get props => [court, venueId, venueName];
}

class AvailabilitySlot extends Equatable {
  const AvailabilitySlot({
    required this.startMinutes,
    required this.endMinutes,
    required this.available,
    required this.price,
    this.peak = false,
    this.deal = false,
    this.reason,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      startMinutes: _int(json['startMinutes']),
      endMinutes: _int(json['endMinutes']),
      available: json['available'] as bool? ?? false,
      price: _int(json['price']),
      peak: json['peak'] as bool? ?? false,
      deal: json['deal'] as bool? ?? false,
      reason: json['reason'] as String?,
    );
  }

  final int startMinutes;
  final int endMinutes;
  final bool available;
  final int price;
  final bool peak;
  final bool deal;

  /// Server reason only; never invented by the UI.
  final String? reason;

  String get label {
    String fmt(int m) {
      final h = m ~/ 60;
      final min = m % 60;
      return '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
    }

    return '${fmt(startMinutes)} – ${fmt(endMinutes)}';
  }

  String get unavailableLabel => switch (reason) {
    'booked' => 'Booked',
    'past' => 'Past',
    'too_late' => 'Too late to book',
    'not_open_yet' => 'Not open yet',
    'blocked' => 'Unavailable',
    _ => available ? 'Available' : 'Unavailable',
  };

  @override
  List<Object?> get props => [startMinutes, endMinutes, available, price];
}

class AvailabilityResponse extends Equatable {
  const AvailabilityResponse({
    required this.courtId,
    required this.venueId,
    required this.date,
    this.currency = 'PKR',
    this.slotMinutes = 60,
    this.slots = const [],
  });

  factory AvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return AvailabilityResponse(
      courtId: _str(json['courtId']),
      venueId: _str(json['venueId']),
      date: _str(json['date']),
      currency: _str(json['currency']).isEmpty ? 'PKR' : _str(json['currency']),
      slotMinutes: _int(json['slotMinutes'], 60),
      slots: (json['slots'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => AvailabilitySlot.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  final String courtId;
  final String venueId;
  final String date;
  final String currency;
  final int slotMinutes;
  final List<AvailabilitySlot> slots;

  @override
  List<Object?> get props => [courtId, date, slots];
}

class AreanaReview extends Equatable {
  const AreanaReview({
    required this.id,
    required this.rating,
    this.comment,
    this.ownerReply,
    required this.createdAt,
    required this.userName,
  });

  factory AreanaReview.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map ? Map<String, dynamic>.from(user) : const {};
    return AreanaReview(
      id: _str(json['id']),
      rating: _int(json['rating']),
      comment: json['comment'] as String?,
      ownerReply: json['ownerReply'] as String?,
      createdAt: _str(json['createdAt']),
      userName: _str(userMap['name']),
    );
  }

  final String id;
  final int rating;
  final String? comment;
  final String? ownerReply;
  final String createdAt;
  final String userName;

  @override
  List<Object?> get props => [id, rating, createdAt];
}

class AreanaBanner extends Equatable {
  const AreanaBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    this.city,
  });

  factory AreanaBanner.fromJson(Map<String, dynamic> json) {
    return AreanaBanner(
      id: _str(json['id']),
      title: _str(json['title']),
      imageUrl: _str(json['imageUrl']),
      linkUrl: json['linkUrl'] as String?,
      city: json['city'] as String?,
    );
  }

  final String id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String? city;

  @override
  List<Object?> get props => [id, title, imageUrl];
}

class SlotSearchCourt extends Equatable {
  const SlotSearchCourt({
    required this.court,
    this.availableSlots = const [],
  });

  factory SlotSearchCourt.fromJson(Map<String, dynamic> json) {
    return SlotSearchCourt(
      court: AreanaCourt.fromJson(json),
      availableSlots: (json['availableSlots'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => AvailabilitySlot.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  final AreanaCourt court;
  final List<AvailabilitySlot> availableSlots;

  @override
  List<Object?> get props => [court, availableSlots];
}

class SlotSearchResult extends Equatable {
  const SlotSearchResult({
    required this.venueId,
    required this.venueName,
    required this.venueAddress,
    required this.venueCity,
    required this.venueRating,
    required this.venueImages,
    this.courts = const [],
  });

  factory SlotSearchResult.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'];
    final venueMap = venue is Map ? Map<String, dynamic>.from(venue) : const {};
    return SlotSearchResult(
      venueId: _str(venueMap['id']),
      venueName: _str(venueMap['name']),
      venueAddress: _str(venueMap['address']),
      venueCity: _str(venueMap['city']),
      venueRating: (venueMap['rating'] as num?)?.toDouble() ?? 0,
      venueImages: _stringList(venueMap['images']),
      courts: (json['courts'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => SlotSearchCourt.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  final String venueId;
  final String venueName;
  final String venueAddress;
  final String venueCity;
  final double venueRating;
  final List<String> venueImages;
  final List<SlotSearchCourt> courts;

  @override
  List<Object?> get props => [venueId, venueName, courts];
}
