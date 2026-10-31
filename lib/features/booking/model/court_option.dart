import 'package:equatable/equatable.dart';

class CourtOption extends Equatable {
  const CourtOption({
    required this.id,
    required this.name,
    required this.note,
  });

  factory CourtOption.fromJson(Map<String, dynamic> json) {
    return CourtOption(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      note: json['note'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String note;

  @override
  List<Object?> get props => [id, name, note];
}
