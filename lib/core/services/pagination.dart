import 'package:equatable/equatable.dart';

/// Areana offset page: venues, courts, games, player bookings.
/// Query: `?page&limit`. Response: `{items, total, page, limit,
/// totalPages, hasMore}`. A wrapped small catalog (wrapList) carries
/// the same shape.
class OffsetPage<T> extends Equatable {
  const OffsetPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasMore,
  });

  factory OffsetPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) parseItem,
  ) {
    final rawItems = json['items'];
    return OffsetPage(
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => parseItem(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  /// A bare list (legacy / wrapList edge) treated as a single page.
  factory OffsetPage.fromList(
    List<dynamic> list,
    T Function(Map<String, dynamic> json) parseItem,
  ) {
    final items = list
        .whereType<Map>()
        .map((e) => parseItem(Map<String, dynamic>.from(e)))
        .toList();
    return OffsetPage(
      items: items,
      total: items.length,
      page: 1,
      limit: items.length,
      totalPages: 1,
      hasMore: false,
    );
  }

  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasMore;

  @override
  List<Object?> get props => [items, total, page, limit, totalPages, hasMore];
}

/// Areana cursor page: favorites, notifications, venue/court reviews.
/// Query: `?cursor&limit`. Response: `{items, nextCursor, total?}`.
/// A null `nextCursor` means the end of the list.
class CursorPage<T> extends Equatable {
  const CursorPage({required this.items, this.nextCursor, this.total});

  factory CursorPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) parseItem,
  ) {
    final rawItems = json['items'];
    return CursorPage(
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => parseItem(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      nextCursor: json['nextCursor'] as String?,
      total: (json['total'] as num?)?.toInt(),
    );
  }

  final List<T> items;
  final String? nextCursor;
  final int? total;

  bool get hasMore => nextCursor != null;

  @override
  List<Object?> get props => [items, nextCursor, total];
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

/// Accepts either an OffsetPage object or a bare list, as returned by
/// the small wrapList catalogs (`/sports`, `/venues/cities`, …).
OffsetPage<T> parseOffsetPage<T>(
  dynamic data,
  T Function(Map<String, dynamic> json) parseItem,
) {
  if (data is Map) return OffsetPage.fromJson(_map(data), parseItem);
  if (data is List) return OffsetPage.fromList(data, parseItem);
  return OffsetPage(
    items: const [],
    total: 0,
    page: 1,
    limit: 20,
    totalPages: 1,
    hasMore: false,
  );
}

/// Accepts either a CursorPage object or a bare list.
CursorPage<T> parseCursorPage<T>(
  dynamic data,
  T Function(Map<String, dynamic> json) parseItem,
) {
  if (data is Map) return CursorPage.fromJson(_map(data), parseItem);
  if (data is List) {
    final items = data
        .whereType<Map>()
        .map((e) => parseItem(Map<String, dynamic>.from(e)))
        .toList();
    return CursorPage(items: items);
  }
  return const CursorPage(items: []);
}
