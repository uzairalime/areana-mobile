import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/cubit/splash_cubit.dart';
import '../../features/auth/screen/forgot_password_screen.dart';
import '../../features/auth/screen/login_screen.dart';
import '../../features/auth/screen/signup_screen.dart';
import '../../features/auth/screen/splash_screen.dart';
import '../../features/booking/cubit/booking_cubit.dart';
import '../../features/booking/screen/booking_confirmed_screen.dart';
import '../../features/booking/screen/checkout_screen.dart';
import '../../features/booking/screen/pick_slot_screen.dart';
import '../../features/bookings/cubit/bookings_cubit.dart';
import '../../features/bookings/screen/booking_detail_screen.dart';
import '../../features/bookings/screen/bookings_screen.dart';
import '../../features/dashboard/screen/dashboard_shell.dart';
import '../../features/home/cubit/home_cubit.dart';
import '../../features/home/screen/home_screen.dart';
import '../../features/home/screen/venue_detail_screen.dart';
import '../../features/explore/cubit/explore_cubit.dart';
import '../../features/explore/screen/explore_screen.dart';
import '../../features/messages/cubit/chat_cubit.dart';
import '../../features/messages/cubit/messages_cubit.dart';
import '../../features/messages/screen/chat_screen.dart';
import '../../features/messages/screen/messages_screen.dart';
import '../../features/notifications/cubit/notifications_cubit.dart';
import '../../features/notifications/screen/notifications_screen.dart';
import '../../features/profile/model/legal_doc.dart';
import '../../features/profile/screen/account_controls_screen.dart';
import '../../features/profile/screen/account_screen.dart';
import '../../features/profile/screen/change_password_screen.dart';
import '../../features/profile/screen/edit_profile_screen.dart';
import '../../features/profile/screen/help_support_screen.dart';
import '../../features/profile/screen/language_screen.dart';
import '../../features/profile/screen/legal_doc_screen.dart';
import '../../features/profile/screen/legal_screen.dart';
import '../../features/profile/screen/my_reviews_screen.dart';
import '../../features/profile/screen/notification_settings_screen.dart';
import '../../features/profile/screen/payment_preference_screen.dart';
import '../../features/profile/screen/saved_venues_screen.dart';
import '../../features/profile/widgets/profile_scope.dart';
import '../../features/search/cubit/search_cubit.dart';
import '../../features/search/screen/search_screen.dart';
import '../services/locator.dart';
import '../services/session_store.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const bookings = '/bookings';
  static const bookingDetail = '/bookings/detail';
  static const explore = '/explore';
  static const messages = '/messages';
  static const chat = '/chat';
  static const notifications = '/notifications';
  static const account = '/account';
  static const editProfile = '/account/edit';
  static const accountControls = '/account/controls';
  static const changePassword = '/account/change-password';
  static const notificationSettings = '/account/notifications';
  static const language = '/account/language';
  static const paymentPreference = '/account/payment';
  static const savedVenues = '/account/saved-venues';
  static const myReviews = '/account/reviews';
  static const helpSupport = '/account/help';
  static const legal = '/account/legal';
  static const legalDoc = '/account/legal-doc';
  static const search = '/search';
  static const venueDetail = '/venue';
  static const pickSlot = '/booking/slot';
  static const checkout = '/booking/checkout';
  static const bookingConfirmed = '/booking/confirmed';
}

GoRouter createAppRouter({GlobalKey<NavigatorState>? navigatorKey}) {
  final session = getIt<SessionStore>();
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: session.isAuthenticated
        ? AppRoutes.home
        : AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) {
          return _appPage(
            state,
            BlocProvider(
              create: (_) => getIt<SplashCubit>(),
              child: const SplashScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) {
          return _appPage(
            state,
            BlocProvider(
              create: (_) => getIt<AuthCubit>(),
              child: const LoginScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) {
          return _appPage(
            state,
            BlocProvider(
              create: (_) => getIt<AuthCubit>(),
              child: const SignupScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) {
          return _appPage(
            state,
            BlocProvider(
              create: (_) => getIt<AuthCubit>(),
              child: const ForgotPasswordScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (context, state) {
          return _appPage(
            state,
            BlocProvider(
              create: (_) => getIt<SearchCubit>(),
              child: const SearchScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (context, state) {
          return _appPage(
            state,
            BlocProvider(
              create: (_) => getIt<NotificationsCubit>(),
              child: const NotificationsScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (context, state) => _appPage(
          state,
          const ProfileScope(child: EditProfileScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.accountControls,
        pageBuilder: (context, state) => _appPage(
          state,
          const ProfileScope(child: AccountControlsScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        pageBuilder: (context, state) => _appPage(
          state,
          const ProfileScope(child: ChangePasswordScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        pageBuilder: (context, state) => _appPage(
          state,
          const ProfileScope(child: NotificationSettingsScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.language,
        pageBuilder: (context, state) => _appPage(
          state,
          const ProfileScope(child: LanguageScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.paymentPreference,
        pageBuilder: (context, state) => _appPage(
          state,
          const ProfileScope(child: PaymentPreferenceScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.savedVenues,
        pageBuilder: (context, state) => _appPage(
          state,
          const ProfileScope(child: SavedVenuesScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.myReviews,
        pageBuilder: (context, state) => _appPage(
          state,
          const ProfileScope(child: MyReviewsScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.helpSupport,
        pageBuilder: (context, state) => _appPage(
          state,
          const ProfileScope(child: HelpSupportScreen()),
        ),
      ),
      GoRoute(
        path: AppRoutes.legal,
        pageBuilder: (context, state) =>
            _appPage(state, const LegalScreen()),
      ),
      GoRoute(
        path: '${AppRoutes.legalDoc}/:doc',
        pageBuilder: (context, state) {
          final type = LegalDocTypeX.fromPath(state.pathParameters['doc']);
          if (type == null) {
            return _appPage(
              state,
              const Scaffold(body: Center(child: Text('Document not found'))),
            );
          }
          return _appPage(state, LegalDocScreen(type: type));
        },
      ),
      GoRoute(
        path: '${AppRoutes.chat}/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _appPage(
            state,
            BlocProvider(
              create: (_) => getIt<ChatCubit>(param1: id),
              child: ChatScreen(threadId: id),
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.bookingDetail}/:id',
        pageBuilder: (context, state) {
          final booking = BookingDetailScreen.resolve(state);
          if (booking == null) {
            return _appPage(
              state,
              const Scaffold(body: Center(child: Text('Booking not found'))),
            );
          }
          return _appPage(
            state,
            BlocProvider.value(
              value: getIt<BookingsCubit>(),
              child: BookingDetailScreen(booking: booking),
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.venueDetail}/:id',
        pageBuilder: (context, state) {
          final venue = VenueDetailScreen.resolve(state);
          if (venue == null) {
            return _appPage(
              state,
              const Scaffold(body: Center(child: Text('Venue not found'))),
            );
          }
          return _appPage(state, VenueDetailScreen(venue: venue));
        },
      ),
      GoRoute(
        path: AppRoutes.pickSlot,
        pageBuilder: (context, state) {
          return _appPage(
            state,
            BlocProvider.value(
              value: getIt<BookingCubit>(),
              child: const PickSlotScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (context, state) {
          return _appPage(
            state,
            BlocProvider.value(
              value: getIt<BookingCubit>(),
              child: const CheckoutScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookingConfirmed,
        pageBuilder: (context, state) {
          return _appPage(
            state,
            BlocProvider.value(
              value: getIt<BookingCubit>(),
              child: const BookingConfirmedScreen(),
            ),
            slide: false,
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) {
                  return NoTransitionPage(
                    child: BlocProvider(
                      create: (_) => getIt<HomeCubit>(),
                      child: const HomeScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bookings,
                pageBuilder: (context, state) {
                  return NoTransitionPage(
                    child: BlocProvider.value(
                      value: getIt<BookingsCubit>(),
                      child: const BookingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                pageBuilder: (context, state) {
                  return NoTransitionPage(
                    child: BlocProvider.value(
                      value: getIt<ExploreCubit>(),
                      child: const ExploreScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.messages,
                pageBuilder: (context, state) {
                  return NoTransitionPage(
                    child: BlocProvider(
                      create: (_) => getIt<MessagesCubit>(),
                      child: const MessagesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.account,
                pageBuilder: (context, state) {
                  return const NoTransitionPage(child: AccountScreen());
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

CustomTransitionPage<void> _appPage(
  GoRouterState state,
  Widget child, {
  bool slide = true,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final fade = FadeTransition(opacity: curved, child: child);
      if (!slide) {
        return fade;
      }
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0.02),
          end: Offset.zero,
        ).animate(curved),
        child: fade,
      );
    },
  );
}
