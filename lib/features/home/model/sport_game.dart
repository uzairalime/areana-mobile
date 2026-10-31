import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';

class SportGame extends Equatable {
  const SportGame({
    required this.id,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  factory SportGame.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final preset = byId(id);
    return SportGame(
      id: id,
      label: json['label'] as String? ??
          json['name'] as String? ??
          preset?.label ??
          '',
      icon: _iconFromKey(json['icon'] as String?) ??
          preset?.icon ??
          Icons.sports,
      background:
          _colorFromHex(json['background'] as String?) ??
          preset?.background ??
          AppColors.primarySoft,
      foreground:
          _colorFromHex(json['foreground'] as String?) ??
          preset?.foreground ??
          AppColors.primary,
    );
  }

  final String id;
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  bool get isAll => id == all.id;

  /// Default selected chip — shows every venue.
  static const all = SportGame(
    id: 'all',
    label: 'All',
    icon: Icons.apps_rounded,
    background: AppColors.primarySoft,
    foreground: AppColors.primary,
  );

  static const List<SportGame> catalog = [
    all,
    SportGame(
      id: 'football',
      label: 'Football',
      icon: Icons.sports_soccer,
      background: AppColors.footballSoft,
      foreground: AppColors.football,
    ),
    SportGame(
      id: 'padel',
      label: 'Padel',
      icon: Icons.sports_tennis,
      background: AppColors.padelSoft,
      foreground: AppColors.padel,
    ),
    SportGame(
      id: 'indoor_cricket',
      label: 'Indoor Cricket',
      icon: Icons.sports_cricket,
      background: AppColors.cricketSoft,
      foreground: AppColors.cricket,
    ),
    SportGame(
      id: 'courts',
      label: 'Courts',
      icon: Icons.grid_view_rounded,
      background: AppColors.courtsSoft,
      foreground: AppColors.courts,
    ),
  ];

  /// Fallback while API loads / mock.
  static List<SportGame> get defaults => List<SportGame>.unmodifiable(catalog);

  /// Profile favourite chips (matches product edit-profile set).
  static const cricket = SportGame(
    id: 'cricket',
    label: 'Cricket',
    icon: Icons.sports_cricket,
    background: AppColors.cricketSoft,
    foreground: AppColors.cricket,
  );

  static const tennis = SportGame(
    id: 'tennis',
    label: 'Tennis',
    icon: Icons.sports_tennis,
    background: AppColors.courtsSoft,
    foreground: AppColors.courts,
  );

  static List<SportGame> get profileFavourites => List.unmodifiable([
    catalog.firstWhere((s) => s.id == 'padel'),
    catalog.firstWhere((s) => s.id == 'football'),
    cricket,
    tennis,
  ]);

  static SportGame? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final sport in catalog) {
      if (sport.id == id) return sport;
    }
    if (id == cricket.id) return cricket;
    if (id == tennis.id) return tennis;
    return null;
  }

  /// Maps venue.sport display names to catalog ids for local filter.
  static String? idForVenueSport(String sport) {
    final key = sport.trim().toLowerCase();
    return switch (key) {
      'football' || 'soccer' => 'football',
      'padel' => 'padel',
      'indoor cricket' || 'cricket' => 'indoor_cricket',
      'courts' || 'tennis' || 'badminton' => 'courts',
      _ => null,
    };
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'icon': _iconKey(icon),
    'background': _colorToHex(background),
    'foreground': _colorToHex(foreground),
  };

  static IconData? _iconFromKey(String? key) => switch (key) {
    'all' || 'apps' => Icons.apps_rounded,
    'football' || 'soccer' => Icons.sports_soccer,
    'padel' || 'tennis' => Icons.sports_tennis,
    'cricket' || 'indoor_cricket' => Icons.sports_cricket,
    'courts' || 'grid' => Icons.grid_view_rounded,
    _ => null,
  };

  static String _iconKey(IconData icon) {
    if (icon == Icons.apps_rounded) return 'all';
    if (icon == Icons.sports_soccer) return 'football';
    if (icon == Icons.sports_tennis) return 'padel';
    if (icon == Icons.sports_cricket) return 'indoor_cricket';
    if (icon == Icons.grid_view_rounded) return 'courts';
    return 'sports';
  }

  static Color? _colorFromHex(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final hex = raw.replaceFirst('#', '');
    if (hex.length != 6 && hex.length != 8) return null;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(hex.length == 6 ? 0xFF000000 | value : value);
  }

  static String _colorToHex(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2)}';
  }

  @override
  List<Object?> get props => [id, label];
}
