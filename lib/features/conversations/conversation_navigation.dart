import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_router.dart';
import '../../core/services/locator.dart';
import 'cubit/conversations_repository.dart';

abstract final class ConversationNavigation {
  static Future<void> openArenaChat(
    BuildContext context, {
    required String venueId,
    String? bookingId,
  }) async {
    final result = await getIt<ConversationsRepository>().openThread(
      venueId: venueId,
      bookingId: bookingId,
    );
    if (!context.mounted) return;
    result.when(
      success: (thread) {
        context.push('${AppRoutes.chat}/${thread.id}', extra: thread);
      },
      failure: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message.isEmpty
                  ? 'Could not open chat'
                  : error.message,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}
