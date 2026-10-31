import 'package:flutter/material.dart';

import '../../features/booking/model/booking_confirmation.dart';
import '../../features/booking/model/booking_date.dart';
import '../../features/booking/model/court_option.dart';
import '../../features/booking/model/time_slot.dart';
import '../../features/booking/model/venue_availability.dart';
import '../../features/bookings/model/user_booking.dart';
import '../../features/home/model/venue.dart';
import '../consts/app_colors.dart';

class MockBookingData {
  const MockBookingData._();

  static VenueAvailability availabilityFor(Venue venue) {
    final base = venue.priceFrom <= 0 ? 3000 : venue.priceFrom;
    final peak = (base * 1.15).round();
    final off = (base * 0.9).round();
    final now = DateTime.now();

    return VenueAvailability(
      courts: [
        CourtOption(
          id: '${venue.id}-c1',
          name: 'Court 1',
          note: venue.sport == 'Padel' ? 'Glass' : 'Indoor',
        ),
        CourtOption(
          id: '${venue.id}-c2',
          name: 'Court 2',
          note: venue.sport == 'Football' ? 'Turf' : 'Outdoor',
        ),
        CourtOption(
          id: '${venue.id}-c3',
          name: 'Court 3',
          note: 'Floodlit',
        ),
      ],
      dates: [
        for (var i = 0; i < 7; i++) _dateFrom(now.add(Duration(days: i))),
      ],
      durations: const ['60 min', '90 min', '120 min'],
      slots: [
        TimeSlot(id: '${venue.id}-s1', label: '5:00 PM', price: off),
        TimeSlot(id: '${venue.id}-s2', label: '6:00 PM', price: base),
        TimeSlot(id: '${venue.id}-s3', label: '7:00 PM', price: peak),
        TimeSlot(id: '${venue.id}-s4', label: '8:00 PM', price: peak),
        TimeSlot(
          id: '${venue.id}-s5',
          label: '9:00 PM',
          price: peak,
          status: SlotStatus.booked,
        ),
        TimeSlot(id: '${venue.id}-s6', label: '10:00 PM', price: base),
        TimeSlot(id: '${venue.id}-s7', label: '11:00 PM', price: off),
      ],
    );
  }

  /// My Bookings list — upcoming + past mock rows.
  static final List<UserBooking> myBookings = [
    UserBooking(
      id: 'bk-1',
      code: 'PS-48213',
      venueId: 'arena-one',
      venueName: 'Arena One Padel Club',
      sport: 'Padel',
      location: 'DHA Phase 6, Karachi',
      dateLabel: _futureDateLabel(1),
      timeLabel: '7:00 PM to 8:00 PM',
      courtLabel: 'Court 2, Glass',
      durationLabel: '60 min',
      amountDue: 3000,
      payAtGround: true,
      status: .confirmed,
      heroColor: AppColors.padel,
      occurredAt: _futureAt(1),
      imageUrl:
          'https://images.unsplash.com/photo-1554068865-24cecd4e79c7?w=600&q=80',
    ),
    UserBooking(
      id: 'bk-7',
      code: 'PS-48301',
      venueId: 'strike-indoor',
      venueName: 'Strike Indoor Cricket Arena',
      sport: 'Indoor Cricket',
      location: 'Gulshan-e-Iqbal, Karachi',
      dateLabel: _futureDateLabel(2),
      timeLabel: '8:00 PM to 9:00 PM',
      courtLabel: 'Lane 2',
      durationLabel: '60 min',
      amountDue: 3500,
      payAtGround: true,
      status: .pending,
      heroColor: const Color(0xFF1D2B3A),
      occurredAt: _futureAt(2),
      imageUrl:
          'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=600&q=80',
    ),
    UserBooking(
      id: 'bk-2',
      code: 'PS-48244',
      venueId: 'goal-zone',
      venueName: 'Goal Zone Turf',
      sport: 'Football',
      location: 'Clifton, Karachi',
      dateLabel: _futureDateLabel(3),
      timeLabel: '9:00 PM to 10:00 PM',
      courtLabel: 'Pitch 1, Turf',
      durationLabel: '60 min',
      amountDue: 5000,
      payAtGround: true,
      status: .pending,
      heroColor: AppColors.football,
      occurredAt: _futureAt(3),
      imageUrl:
          'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=600&q=80',
    ),
    UserBooking(
      id: 'bk-3',
      code: 'PS-48102',
      venueId: 'lahore-padel-hub',
      venueName: 'Lahore Padel Hub',
      sport: 'Padel',
      location: 'Gulberg III, Lahore',
      dateLabel: _futureDateLabel(5),
      timeLabel: '6:00 PM to 7:30 PM',
      courtLabel: 'Court 1, Outdoor',
      durationLabel: '90 min',
      amountDue: 4200,
      payAtGround: false,
      status: .confirmed,
      heroColor: AppColors.padel,
      occurredAt: _futureAt(5),
      imageUrl:
          'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=600&q=80',
    ),
    UserBooking(
      id: 'bk-4',
      code: 'PS-47011',
      venueId: 'strike-indoor',
      venueName: 'Strike Indoor Cricket Arena',
      sport: 'Indoor Cricket',
      location: 'Gulshan-e-Iqbal, Karachi',
      dateLabel: _pastDateLabel(4),
      timeLabel: '8:00 PM to 9:00 PM',
      courtLabel: 'Lane 3',
      durationLabel: '60 min',
      amountDue: 3500,
      payAtGround: true,
      status: .completed,
      reviewStatus: .recommended,
      heroColor: const Color(0xFF1D2B3A),
      occurredAt: _pastAt(4),
      imageUrl:
          'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=600&q=80',
    ),
    UserBooking(
      id: 'bk-5',
      code: 'PS-46988',
      venueId: 'dha-turf-arena',
      venueName: 'DHA Turf Arena',
      sport: 'Football',
      location: 'DHA Phase 5, Lahore',
      dateLabel: _pastDateLabel(9),
      timeLabel: '10:00 PM to 11:00 PM',
      courtLabel: 'Pitch 1',
      durationLabel: '60 min',
      amountDue: 4500,
      payAtGround: true,
      status: .completed,
      heroColor: AppColors.football,
      occurredAt: _pastAt(9),
      imageUrl:
          'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=600&q=80',
    ),
    UserBooking(
      id: 'bk-6',
      code: 'PS-46820',
      venueId: 'arena-one',
      venueName: 'Arena One Padel Club',
      sport: 'Padel',
      location: 'DHA Phase 6, Karachi',
      dateLabel: _pastDateLabel(14),
      timeLabel: '7:00 PM to 8:00 PM',
      courtLabel: 'Court 1, Glass',
      durationLabel: '60 min',
      amountDue: 3000,
      payAtGround: true,
      status: .cancelled,
      heroColor: AppColors.padel,
      occurredAt: _pastAt(14),
      imageUrl:
          'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=600&q=80',
    ),
  ];

  static void submitReview({
    required String bookingId,
    required bool recommended,
  }) {
    final index = myBookings.indexWhere((e) => e.id == bookingId);
    if (index < 0) return;
    final booking = myBookings[index];
    if (booking.status != .completed) return;
    myBookings[index] = booking.copyWith(
      reviewStatus: recommended ? .recommended : .notRecommended,
    );
  }

  static UserBooking? cancel(String bookingId) {
    final index = myBookings.indexWhere((e) => e.id == bookingId);
    if (index < 0) return null;
    final booking = myBookings[index];
    if (!booking.canModify) return null;
    final updated = booking.copyWith(
      status: .cancelled,
      occurredAt: DateTime.now(),
    );
    myBookings[index] = updated;
    return updated;
  }

  static UserBooking? bookingById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final booking in myBookings) {
      if (booking.id == id) return booking;
    }
    return null;
  }

  static BookingConfirmation confirm({
    required Venue venue,
    required CourtOption court,
    required BookingDate date,
    required TimeSlot slot,
    required String duration,
    required bool payAtGround,
  }) {
    final endHour = _endLabel(slot.label, duration);
    return BookingConfirmation(
      code: 'PS-${48000 + (venue.id.hashCode.abs() % 9000)}',
      venueName: venue.name,
      sport: venue.sport,
      location: venue.location,
      dateLabel: '${date.fullLabel} ${DateTime.now().year}',
      timeLabel: '${slot.label} to $endHour',
      courtLabel: '${court.name}, ${court.note}',
      durationLabel: duration,
      amountDue: slot.price,
      payAtGround: payAtGround,
    );
  }

  static BookingDate _dateFrom(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return BookingDate(
      id: 'd-${date.year}-${date.month}-${date.day}',
      weekday: weekday,
      day: '${date.day}',
      month: month,
      fullLabel: '$weekday ${date.day} $month',
    );
  }

  static DateTime _futureAt(int daysAhead) =>
      DateTime.now().add(Duration(days: daysAhead));

  static DateTime _pastAt(int daysAgo) =>
      DateTime.now().subtract(Duration(days: daysAgo));

  static String _futureDateLabel(int daysAhead) {
    final at = _futureAt(daysAhead);
    final d = _dateFrom(at);
    return '${d.fullLabel} ${at.year}';
  }

  static String _pastDateLabel(int daysAgo) {
    final at = _pastAt(daysAgo);
    final d = _dateFrom(at);
    return '${d.fullLabel} ${at.year}';
  }

  static String _endLabel(String start, String duration) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$').firstMatch(start);
    if (match == null) {
      return start;
    }
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!;
    if (period == 'PM' && hour != 12) {
      hour += 12;
    }
    if (period == 'AM' && hour == 12) {
      hour = 0;
    }
    final minutes = int.tryParse(duration.split(' ').first) ?? 60;
    final total = hour * 60 + minute + minutes;
    final endHour24 = (total ~/ 60) % 24;
    final endMinute = total % 60;
    final endPeriod = endHour24 >= 12 ? 'PM' : 'AM';
    final displayHour = endHour24 % 12 == 0 ? 12 : endHour24 % 12;
    return '$displayHour:${endMinute.toString().padLeft(2, '0')} $endPeriod';
  }
}
