import 'package:flutter/material.dart';

import '../../features/home/model/sport_game.dart';
import '../../features/home/model/venue.dart';
import '../consts/app_colors.dart';

class MockHomeData {
  const MockHomeData._();

  static List<SportGame> get sports => SportGame.defaults;

  static final List<Venue> popularVenues = [
    ..._seed,
    ..._generatedExtras,
  ];

  static List<Venue> venuesForSport(String? sportId) {
    if (sportId == null ||
        sportId.isEmpty ||
        sportId == SportGame.all.id) {
      return popularVenues;
    }
    return popularVenues
        .where((venue) => SportGame.idForVenueSport(venue.sport) == sportId)
        .toList(growable: false);
  }

  static const List<Venue> _seed = [
    Venue(
      id: 'arena-one',
      name: 'Arena One Padel Club',
      sport: 'Padel',
      location: 'DHA Phase 6, Karachi',
      priceFrom: 3000,
      amenities: ['Glass courts', 'Floodlit', 'Parking'],
      nextSlot: 'Today, 7:00 PM',
      heroColor: AppColors.padel,
      description:
          'Premium indoor padel with glass courts, pro coaching, and easy parking. Ideal for doubles nights and weekend ladders.',
      rating: 4.8,
      reviewCount: 126,
      openHours: '6:00 AM – 12:00 AM',
      courtsLabel: '4 glass courts',
      latitude: 24.8142,
      longitude: 67.0741,
      imageUrls: [
        'https://images.unsplash.com/photo-1554068865-24cecd4e79c7?w=900&q=80',
        'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=900&q=80',
        'https://images.unsplash.com/photo-1517649763962-0c623066027b?w=900&q=80',
      ],
    ),
    Venue(
      id: 'goal-zone',
      name: 'Goal Zone Turf',
      sport: 'Football',
      location: 'Clifton, Karachi',
      priceFrom: 5000,
      amenities: ['5-a-side', 'Floodlit', 'Changing rooms'],
      nextSlot: 'Today, 9:00 PM',
      heroColor: AppColors.football,
      description:
          'Floodlit 5-a-side turf with clean changing rooms. Book by the hour and pay at the ground.',
      rating: 4.6,
      reviewCount: 89,
      openHours: '4:00 PM – 1:00 AM',
      courtsLabel: '2 turf pitches',
      latitude: 24.8138,
      longitude: 67.0297,
      imageUrls: [
        'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=900&q=80',
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=900&q=80',
      ],
    ),
    Venue(
      id: 'strike-indoor',
      name: 'Strike Indoor Cricket Arena',
      sport: 'Indoor Cricket',
      location: 'Gulshan-e-Iqbal, Karachi',
      priceFrom: 3500,
      amenities: ['Net lanes', 'Air conditioned', 'Cafe'],
      nextSlot: 'Today, 8:00 PM',
      heroColor: Color(0xFF1D2B3A),
      description:
          'Air-conditioned net lanes with cafe seating for teams waiting on deck. Perfect for practice and friendlies.',
      rating: 4.5,
      reviewCount: 64,
      openHours: '10:00 AM – 11:00 PM',
      courtsLabel: '6 net lanes',
      latitude: 24.9180,
      longitude: 67.0971,
      imageUrls: [
        'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=900&q=80',
      ],
    ),
    Venue(
      id: 'lahore-padel-hub',
      name: 'Lahore Padel Hub',
      sport: 'Padel',
      location: 'Gulberg III, Lahore',
      priceFrom: 2800,
      amenities: ['4 courts', 'Floodlit', 'Cafe'],
      nextSlot: 'Tomorrow, 6:00 PM',
      heroColor: AppColors.padel,
      description:
          'Central Gulberg padel hub with floodlights and a cafe overlooking the courts.',
      rating: 4.7,
      reviewCount: 102,
      openHours: '7:00 AM – 11:30 PM',
      courtsLabel: '4 outdoor courts',
      latitude: 31.5052,
      longitude: 74.3486,
      imageUrls: [
        'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=900&q=80',
        'https://images.unsplash.com/photo-1461896836934-ffe607ba6851?w=900&q=80',
        'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=900&q=80',
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=900&q=80',
      ],
    ),
    Venue(
      id: 'dha-turf-arena',
      name: 'DHA Turf Arena',
      sport: 'Football',
      location: 'DHA Phase 5, Lahore',
      priceFrom: 4500,
      amenities: ['7-a-side', 'Parking', 'Floodlit'],
      nextSlot: 'Today, 10:00 PM',
      heroColor: AppColors.football,
      description:
          '7-a-side floodlit turf with ample parking. Popular for late evening kickabouts.',
      rating: 4.4,
      reviewCount: 71,
      openHours: '5:00 PM – 1:00 AM',
      courtsLabel: '1 turf pitch',
      latitude: 31.4697,
      longitude: 74.4183,
      imageUrls: [
        'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=900&q=80',
        'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?w=900&q=80',
      ],
    ),
  ];

  /// Extra courts so Explore map exercises clustering (&gt;20 markers).
  static final List<Venue> _generatedExtras = _buildExtras();

  static List<Venue> _buildExtras() {
    const sports = [
      ('Football', AppColors.football),
      ('Padel', AppColors.padel),
      ('Indoor Cricket', Color(0xFF1D2B3A)),
    ];
    const hubs = <(String, double, double)>[
      ('North Nazimabad, Karachi', 24.9320, 67.0330),
      ('PECHS, Karachi', 24.8730, 67.0550),
      ('Bahria Town, Karachi', 25.0005, 67.3100),
      ('Johar Town, Lahore', 31.4692, 74.2728),
      ('Model Town, Lahore', 31.4830, 74.3230),
      ('Bahria Town, Lahore', 31.3700, 74.1850),
    ];

    final out = <Venue>[];
    var i = 0;
    for (final hub in hubs) {
      for (var n = 0; n < 4; n++) {
        final sport = sports[i % sports.length];
        final lat = hub.$2 + ((n % 2) * 0.018) - 0.008;
        final lng = hub.$3 + ((n ~/ 2) * 0.022) - 0.01;
        final id = 'court-extra-$i';
        out.add(
          Venue(
            id: id,
            name: '${sport.$1} Court ${i + 1}',
            sport: sport.$1,
            location: hub.$1,
            priceFrom: 2200 + (i % 7) * 350,
            amenities: const ['Floodlit', 'Parking'],
            nextSlot: 'Today, ${6 + (i % 5)}:00 PM',
            heroColor: sport.$2,
            description: 'Mock venue for map clustering and list stress tests.',
            rating: 4.0 + (i % 10) / 10,
            reviewCount: 20 + i * 3,
            openHours: '6:00 AM – 12:00 AM',
            courtsLabel: '${1 + (i % 4)} courts',
            latitude: lat,
            longitude: lng,
            imageUrls: const [
              'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=900&q=80',
            ],
          ),
        );
        i++;
      }
    }
    return out;
  }

  static Venue? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final venue in popularVenues) {
      if (venue.id == id) return venue;
    }
    return null;
  }
}
