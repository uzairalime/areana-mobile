import '../../features/notifications/model/app_notification.dart';

/// In-memory notifications while [AppConfig.useMockApi] is true.
class MockNotificationData {
  MockNotificationData._();

  static final List<AppNotification> _items = [
    const AppNotification(
      id: '1',
      type: .booking,
      group: 'Today',
      title: 'Booking confirmed',
      body:
          'Court 2 at Arena One Padel Club, today 7:00 to 8:00 PM. Pay Rs 4,500 at the ground.',
      timeLabel: '2 min ago',
      link: '/bookings',
    ),
    const AppNotification(
      id: '2',
      type: .reminder,
      group: 'Today',
      title: 'Your slot starts in 1 hour',
      body: 'Arena One Padel Club, Court 2. Please arrive 10 minutes early.',
      timeLabel: '1 h ago',
      link: '/messages/arena-one',
    ),
    const AppNotification(
      id: '3',
      type: .offer,
      group: 'Today',
      title: 'Off-peak slots open',
      body: 'Weekday slots before 5 PM are available at Goal Zone Turf.',
      timeLabel: '4 h ago',
      link: '/messages/goal-zone',
    ),
    const AppNotification(
      id: '4',
      type: .update,
      group: 'Earlier',
      title: 'Slot time changed',
      body: 'Strike Indoor Cricket Arena moved your booking to 9:00 PM.',
      timeLabel: 'Yesterday',
      isRead: true,
      link: '/messages/strike',
    ),
    const AppNotification(
      id: '5',
      type: .cancel,
      group: 'Earlier',
      title: 'Booking cancelled',
      body: 'Your booking at Goal Zone Turf on Mon 26 Oct was cancelled.',
      timeLabel: 'Mon',
      isRead: true,
      link: '/bookings',
    ),
    const AppNotification(
      id: '6',
      type: .offer,
      group: 'Earlier',
      title: 'New venue near you',
      body: 'A new padel venue just opened in DHA Phase 6.',
      timeLabel: 'Sun',
      isRead: true,
      link: '/home',
    ),
  ];

  static List<AppNotification> get items =>
      List<AppNotification>.unmodifiable(_items);

  static void markRead(String id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0 || _items[index].isRead) return;
    _items[index] = _items[index].copyWith(isRead: true);
  }

  static void markAllRead() {
    for (var i = 0; i < _items.length; i++) {
      if (!_items[i].isRead) {
        _items[i] = _items[i].copyWith(isRead: true);
      }
    }
  }
}
