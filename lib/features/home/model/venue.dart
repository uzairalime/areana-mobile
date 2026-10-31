import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';

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
      priceFrom: (json['price_from'] as num?)?.toInt() ?? 0,
      amenities: (json['amenities'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      nextSlot: json['next_slot'] as String? ?? '',
      heroColor:
          _colorFromHex(json['hero_color'] as String?) ?? AppColors.primary,
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      openHours: json['open_hours'] as String? ?? '',
      courtsLabel: json['courts_label'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      imageUrls: imagesRaw is List
          ? imagesRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const [],
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
