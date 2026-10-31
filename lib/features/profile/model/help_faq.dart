import 'package:equatable/equatable.dart';

class HelpFaq extends Equatable {
  const HelpFaq({required this.id, required this.question, required this.answer});

  factory HelpFaq.fromJson(Map<String, dynamic> json) {
    return HelpFaq(
      id: json['id']?.toString() ?? '',
      question: json['question'] as String? ?? json['q'] as String? ?? '',
      answer: json['answer'] as String? ?? json['a'] as String? ?? '',
    );
  }

  final String id;
  final String question;
  final String answer;

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
  };

  @override
  List<Object?> get props => [id, question, answer];
}
