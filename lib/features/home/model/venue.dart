import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/utils/json_parsing.dart';

class Venue extends Equatable {
  const Venue({
    required this.id,
    required this.name,
    required this.sport,
    required this.location,
    required this.priceFrom,
    required this.amenities,
    required this.nextSlot,
    required this.heroColor,
    this.description = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.openHours = '',
    this.courtsLabel = '',
    this.latitude = 0,
    this.longitude = 0,
    this.imageUrls = const [],
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['image_urls'] ?? json['images'];
    return Venue(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      sport: json['sport'] as String? ?? '',
      location: json['location'] as String? ?? '',
      priceFrom: JsonParsing.intValue(json['price_from']),
      amenities: (json['amenities'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      nextSlot: json['next_slot'] as String? ?? '',
      heroColor:
          _colorFromHex(json['hero_color'] as String?) ?? AppColors.primary,
      description: json['description'] as String? ?? '',
      rating: JsonParsing.doubleValue(json['rating']),
      reviewCount: JsonParsing.intValue(json['review_count']),
      openHours: json['open_hours'] as String? ?? '',
      courtsLabel: json['courts_label'] as String? ?? '',
      latitude: JsonParsing.doubleValue(json['latitude']),
      longitude: JsonParsing.doubleValue(json['longitude']),
      imageUrls: _imageUrls(imagesRaw),
    );
  }

  final String id;
  final String name;
  final String sport;
  final String location;
  final int priceFrom;
  final List<String> amenities;
  final String nextSlot;
  final Color heroColor;
  final String description;
  final double rating;
  final int reviewCount;
  final String openHours;
  final String courtsLabel;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;

  bool get hasCoordinates => latitude != 0 && longitude != 0;

  String get coverUrl {
    for (final url in imageUrls) {
      final trimmed = url.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  bool get hasCover => coverUrl.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sport': sport,
    'location': location,
    'price_from': priceFrom,
    'amenities': amenities,
    'next_slot': nextSlot,
    'hero_color':
        '#${heroColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
    'description': description,
    'rating': rating,
    'review_count': reviewCount,
    'open_hours': openHours,
    'courts_label': courtsLabel,
    'latitude': latitude,
    'longitude': longitude,
    'image_urls': imageUrls,
  };

  static List<String> _imageUrls(dynamic value) {
    if (value is! List) return const [];
    final urls = <String>[];
    for (final item in value) {
      if (item is String) {
        final trimmed = item.trim();
        if (trimmed.isNotEmpty) urls.add(trimmed);
      } else if (item is Map) {
        final trimmed = (item['url'] ?? item['src'])?.toString().trim() ?? '';
        if (trimmed.isNotEmpty) urls.add(trimmed);
      }
    }
    return urls;
  }

  static Color? _colorFromHex(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    var hex = value.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) {
      return null;
    }
    return Color(parsed);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    sport,
    location,
    priceFrom,
    nextSlot,
    description,
    rating,
    reviewCount,
    latitude,
    longitude,
    imageUrls,
  ];
}
