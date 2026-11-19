import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';

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
    final name = (json['name'] ?? json['label'] ?? '').toString().trim();
    final rawId = json['id']?.toString() ?? '';
    final preset = match(name) ?? match(rawId);
    final label = name.isNotEmpty ? (preset?.label ?? name) : (preset?.label ?? '');
    return SportGame(
      id: preset?.id ?? (name.isNotEmpty ? _slug(name) : rawId),
      label: label,
      icon: _iconFromKey(json['icon'] as String?) ?? preset?.icon ?? Icons.sports,
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

  static const football = SportGame(
    id: 'football',
    label: 'Football',
    icon: Icons.sports_soccer,
    background: AppColors.footballSoft,
    foreground: AppColors.football,
  );

  static const futsal = SportGame(
    id: 'futsal',
    label: 'Futsal',
    icon: Icons.sports_soccer,
    background: Color(0xFFE5F6EE),
    foreground: Color(0xFF0E7A4B),
  );

  static const cricket = SportGame(
    id: 'cricket',
    label: 'Cricket',
    icon: Icons.sports_cricket,
    background: AppColors.cricketSoft,
    foreground: AppColors.cricket,
  );

  static const padel = SportGame(
    id: 'padel',
    label: 'Padel',
    icon: Icons.sports_tennis,
    background: AppColors.padelSoft,
    foreground: AppColors.padel,
  );

  static const tennis = SportGame(
    id: 'tennis',
    label: 'Tennis',
    icon: Icons.sports_tennis,
    background: Color(0xFFE7F8D8),
    foreground: Color(0xFF3D7A12),
  );

  static const badminton = SportGame(
    id: 'badminton',
    label: 'Badminton',
    icon: Icons.sports_tennis,
    background: AppColors.courtsSoft,
    foreground: AppColors.courts,
  );

  static const basketball = SportGame(
    id: 'basketball',
    label: 'Basketball',
    icon: Icons.sports_basketball,
    background: Color(0xFFFBE8D8),
    foreground: Color(0xFFC2410C),
  );

  static const volleyball = SportGame(
    id: 'volleyball',
    label: 'Volleyball',
    icon: Icons.sports_volleyball,
    background: Color(0xFFFFF4D6),
    foreground: Color(0xFFA16207),
  );

  static const hockey = SportGame(
    id: 'hockey',
    label: 'Hockey',
    icon: Icons.sports_hockey,
    background: Color(0xFFE4F4F1),
    foreground: Color(0xFF0F766E),
  );

  static const squash = SportGame(
    id: 'squash',
    label: 'Squash',
    icon: Icons.sports_handball,
    background: Color(0xFFF3E8FF),
    foreground: Color(0xFF7E22CE),
  );

  static const List<SportGame> catalog = [
    all,
    football,
    futsal,
    cricket,
    padel,
    tennis,
    badminton,
    basketball,
    volleyball,
    hockey,
    squash,
  ];

  /// Fallback while the sports API is loading.
  static List<SportGame> get defaults => List<SportGame>.unmodifiable(catalog);

  static List<SportGame> get profileFavourites =>
      List<SportGame>.unmodifiable([padel, football, cricket, tennis]);

  static SportGame? byId(String? id) => match(id);

  static SportGame? match(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final key = _slug(raw).replaceAll('_', '');
    if (key == 'indoorcricket') return cricket;
    for (final sport in catalog) {
      if (_slug(sport.id).replaceAll('_', '') == key) return sport;
      if (_slug(sport.label).replaceAll('_', '') == key) return sport;
    }
    return null;
  }

  /// Display name the venues API expects (`Football`, not `football`).
  static String? apiName(String? id) {
    if (id == null || id.isEmpty || id == all.id) return null;
    return match(id)?.label ?? id;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'icon': _iconKey(icon),
    'background': _colorToHex(background),
    'foreground': _colorToHex(foreground),
  };

  static String _slug(String raw) => raw
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  static IconData? _iconFromKey(String? key) => switch (key) {
    'all' || 'apps' => Icons.apps_rounded,
    'football' || 'soccer' || 'futsal' => Icons.sports_soccer,
    'padel' || 'tennis' || 'badminton' => Icons.sports_tennis,
    'cricket' || 'indoor_cricket' => Icons.sports_cricket,
    'basketball' => Icons.sports_basketball,
    'volleyball' => Icons.sports_volleyball,
    'hockey' => Icons.sports_hockey,
    'squash' => Icons.sports_handball,
    _ => null,
  };

  static String _iconKey(IconData icon) {
    if (icon == Icons.apps_rounded) return 'all';
    if (icon == Icons.sports_soccer) return 'football';
    if (icon == Icons.sports_tennis) return 'padel';
    if (icon == Icons.sports_cricket) return 'cricket';
    if (icon == Icons.sports_basketball) return 'basketball';
    if (icon == Icons.sports_volleyball) return 'volleyball';
    if (icon == Icons.sports_hockey) return 'hockey';
    if (icon == Icons.sports_handball) return 'squash';
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
