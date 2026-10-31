import 'package:equatable/equatable.dart';

enum LegalDocType { terms, privacy, refunds, about, licences }

extension LegalDocTypeX on LegalDocType {
  String get path => switch (this) {
    .terms => 'terms',
    .privacy => 'privacy',
    .refunds => 'refunds',
    .about => 'about',
    .licences => 'licences',
  };

  String get title => switch (this) {
    .terms => 'Terms of service',
    .privacy => 'Privacy policy',
    .refunds => 'Cancellation and refunds',
    .about => 'About us',
    .licences => 'Open source licences',
  };

  static LegalDocType? fromPath(String? raw) => switch (raw) {
    'terms' => .terms,
    'privacy' => .privacy,
    'refunds' => .refunds,
    'about' => .about,
    'licences' || 'licenses' => .licences,
    _ => null,
  };
}

class LegalSection extends Equatable {
  const LegalSection({required this.heading, required this.body});

  final String heading;
  final String body;

  @override
  List<Object?> get props => [heading, body];
}

class LegalDoc extends Equatable {
  const LegalDoc({
    required this.type,
    required this.title,
    required this.sections,
    this.updatedLabel = '',
  });

  /// Bundled copy — no network.
  factory LegalDoc.of(LegalDocType type) => switch (type) {
    .privacy => const LegalDoc(
      type: .privacy,
      title: 'Privacy policy',
      updatedLabel: 'Last updated Oct 2026',
      sections: [
        LegalSection(
          heading: '1. Information we collect',
          body:
              'Your name, phone number, email and booking history, plus basic device data needed to run the app.',
        ),
        LegalSection(
          heading: '2. How we use it',
          body:
              'To confirm bookings, send reminders, provide support and improve the app. We do not sell your personal data.',
        ),
        LegalSection(
          heading: '3. Sharing',
          body:
              'We share booking details with the venue you book. Service providers process data on our behalf under strict terms.',
        ),
        LegalSection(
          heading: '4. Your choices',
          body:
              'You can edit your profile, manage notifications or delete your account at any time from Profile.',
        ),
        LegalSection(
          heading: '5. Contact',
          body: 'Questions? Email support@pitchside.app.',
        ),
      ],
    ),
    .terms => const LegalDoc(
      type: .terms,
      title: 'Terms of service',
      updatedLabel: 'Last updated Oct 2026',
      sections: [
        LegalSection(
          heading: '1. Using Pitchside',
          body:
              'You must be 16 or older to book. Keep your login details safe and provide accurate information.',
        ),
        LegalSection(
          heading: '2. Bookings',
          body:
              'A booking is confirmed when you receive a booking code. Arrive on time and follow venue rules.',
        ),
        LegalSection(
          heading: '3. Payments',
          body:
              'Pay at the ground or online where offered. Prices are set by each venue and shown before you confirm.',
        ),
        LegalSection(
          heading: '4. Cancellation and refunds',
          body:
              'Free cancellation up to 2 hours before the slot. Later cancellations may incur a fee set by the venue.',
        ),
        LegalSection(
          heading: '5. Conduct',
          body:
              'Respect venue rules and staff. We may suspend accounts for misuse.',
        ),
      ],
    ),
    .refunds => const LegalDoc(
      type: .refunds,
      title: 'Cancellation and refunds',
      updatedLabel: 'Last updated Oct 2026',
      sections: [
        LegalSection(
          heading: 'Free window',
          body:
              'Cancel for free up to 2 hours before your slot starts, unless the venue shows a different policy.',
        ),
        LegalSection(
          heading: 'Late cancellations',
          body:
              'After the free window, venues may charge a fee. Online payments are refunded to the original method within 5–7 days.',
        ),
      ],
    ),
    .about => const LegalDoc(
      type: .about,
      title: 'About us',
      sections: [
        LegalSection(
          heading: 'Pitchside',
          body:
              'We make it simple to find a court, lock a slot and get on with the game.',
        ),
        LegalSection(
          heading: 'Get in touch',
          body:
              'support@pitchside.app\n+92 300 0000000\nwww.pitchside.app',
        ),
      ],
    ),
    .licences => const LegalDoc(
      type: .licences,
      title: 'Open source licences',
      sections: [
        LegalSection(
          heading: 'Flutter & packages',
          body:
              'This app uses Flutter and open-source packages under their respective licences. Full licence texts ship with the binary.',
        ),
      ],
    ),
  };

  final LegalDocType type;
  final String title;
  final String updatedLabel;
  final List<LegalSection> sections;

  @override
  List<Object?> get props => [type, title, updatedLabel, sections];
}
