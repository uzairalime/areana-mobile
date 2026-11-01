import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../../bookings/cubit/bookings_client.dart';
import '../../bookings/model/user_booking.dart';
import '../model/game_post.dart';
import 'games_client.dart';

class GamesRepository {
  const GamesRepository(this._client, this._bookingsClient);

  final GamesClient _client;
  final BookingsClient _bookingsClient;

  Future<ApiResult<OffsetPage<GamePost>>> fetchGames({
    String? sport,
    String? city,
    String? date,
    String status = 'open',
    int page = 1,
    int limit = 20,
  }) => _client.fetchGames(
    sport: sport,
    city: city,
    date: date,
    status: status,
    page: page,
    limit: limit,
  );

  Future<ApiResult<GamePostDetail>> fetchGame(String id) =>
      _client.fetchGame(id);

  Future<ApiResult<GamePost>> createGame({
    required String bookingId,
    required int playersNeeded,
    int? squadSize,
    String? level,
    String? note,
  }) => _client.createGame(
    bookingId: bookingId,
    playersNeeded: playersNeeded,
    squadSize: squadSize,
    level: level,
    note: note,
  );

  /// Postable bookings, mirroring user-web: confirmed, no game post
  /// yet, and not yet started.
  Future<ApiResult<List<UserBooking>>> fetchPostableBookings() async {
    final result = await _bookingsClient.fetchBookings(filter: 'upcoming');
    return result.map((page) {
      final now = DateTime.now();
      return page.items.where((booking) {
        if (booking.status != UserBookingStatus.confirmed) return false;
        if (booking.gamePostId != null) return false;
        return booking.occurredAt.isAfter(now);
      }).toList();
    });
  }

  Future<ApiResult<void>> joinGame(String id) => _client.joinGame(id);

  Future<ApiResult<void>> leaveGame(String id) => _client.leaveGame(id);

  Future<ApiResult<void>> deleteGame(String id) => _client.deleteGame(id);

  Future<ApiResult<void>> acceptRequest({
    required String postId,
    required String participantId,
  }) => _client.acceptRequest(postId: postId, participantId: participantId);

  Future<ApiResult<void>> rejectRequest({
    required String postId,
    required String participantId,
  }) => _client.rejectRequest(postId: postId, participantId: participantId);
}
