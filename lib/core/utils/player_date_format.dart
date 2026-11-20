/// Player-facing calendar labels. API dates stay ISO; cards show these.
abstract final class PlayerDateFormat {
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
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

  static String card(DateTime at, {DateTime? now}) {
    final clock = now ?? DateTime.now();
    final day = DateTime(at.year, at.month, at.day);
    final today = DateTime(clock.year, clock.month, clock.day);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    final weekday = _weekdays[at.weekday - 1];
    final month = _months[at.month - 1];
    if (at.year == clock.year) return '$weekday, ${at.day} $month';
    return '$weekday, ${at.day} $month ${at.year}';
  }
}
