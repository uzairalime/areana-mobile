import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/cubit/auth_client.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/cubit/auth_repository.dart';
import '../../features/auth/cubit/splash_cubit.dart';
import '../../features/booking/cubit/booking_client.dart';
import '../../features/booking/cubit/booking_cubit.dart';
import '../../features/booking/cubit/booking_repository.dart';
import '../../features/bookings/cubit/bookings_client.dart';
import '../../features/bookings/cubit/bookings_cubit.dart';
import '../../features/bookings/cubit/bookings_repository.dart';
import '../../features/explore/cubit/explore_cubit.dart';
import '../../features/home/cubit/home_client.dart';
import '../../features/home/cubit/home_cubit.dart';
import '../../features/home/cubit/home_repository.dart';
import '../../features/messages/cubit/chat_cubit.dart';
import '../../features/messages/cubit/messages_client.dart';
import '../../features/messages/cubit/messages_cubit.dart';
import '../../features/messages/cubit/messages_repository.dart';
import '../../features/notifications/cubit/notifications_client.dart';
import '../../features/notifications/cubit/notifications_cubit.dart';
import '../../features/notifications/cubit/notifications_repository.dart';
import '../../features/profile/cubit/profile_client.dart';
import '../../features/profile/cubit/profile_cubit.dart';
import '../../features/profile/cubit/profile_repository.dart';
import '../../features/search/cubit/search_client.dart';
import '../../features/search/cubit/search_cubit.dart';
import '../../features/search/cubit/search_repository.dart';
import '../deep_link/deep_link_service.dart';
import 'dio_service.dart';
import 'in_app_review_service.dart';
import 'location/location_cubit.dart';
import 'location/location_service.dart';
import 'notification/notification_service.dart';
import 'notification/remote_notification_bridge.dart';
import 'explore_session_store.dart';
import 'recent_search_store.dart';
import 'session_cubit.dart';
import 'session_store.dart';
import 'social_auth_service.dart';
import 'token_store.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt
    ..registerLazySingleton<SessionStore>(SessionStore.new)
    ..registerLazySingleton<SessionCubit>(
      () => SessionCubit(getIt<SessionStore>()),
    )
    ..registerLazySingleton<DeepLinkService>(
      () => DeepLinkService(getIt<SessionStore>()),
    )
    ..registerLazySingleton<NotificationService>(NotificationService.new)
    ..registerLazySingleton<RemoteNotificationBridge>(
      () => RemoteNotificationBridge(getIt<NotificationService>()),
    )
    ..registerLazySingleton<LocationService>(LocationService.new)
    ..registerLazySingleton<LocationCubit>(
      () => LocationCubit(getIt<LocationService>()),
    )
    ..registerLazySingleton<InAppReviewService>(InAppReviewService.new)
    ..registerLazySingleton<TokenStore>(() => TokenStore(getIt<SessionStore>()))
    ..registerLazySingleton<SocialAuthService>(createSocialAuthService)
    ..registerLazySingleton<Dio>(DioService.create)
    ..registerLazySingleton<AuthClient>(() => AuthClient(getIt<Dio>()))
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        getIt<AuthClient>(),
        getIt<SessionCubit>(),
        getIt<SocialAuthService>(),
      ),
    )
    ..registerLazySingleton<HomeClient>(() => HomeClient(getIt<Dio>()))
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepository(getIt<HomeClient>()),
    )
    ..registerLazySingleton<RecentSearchStore>(RecentSearchStore.new)
    ..registerLazySingleton<SearchClient>(() => SearchClient(getIt<Dio>()))
    ..registerLazySingleton<SearchRepository>(
      () => SearchRepository(
        getIt<SearchClient>(),
        getIt<RecentSearchStore>(),
      ),
    )
    ..registerLazySingleton<BookingClient>(() => BookingClient(getIt<Dio>()))
    ..registerLazySingleton<BookingRepository>(
      () => BookingRepository(getIt<BookingClient>()),
    )
    ..registerLazySingleton<BookingCubit>(
      () => BookingCubit(
        getIt<BookingRepository>(),
        getIt<NotificationService>(),
      ),
    )
    ..registerLazySingleton<BookingsClient>(() => BookingsClient(getIt<Dio>()))
    ..registerLazySingleton<BookingsRepository>(
      () => BookingsRepository(getIt<BookingsClient>()),
    )
    ..registerLazySingleton<BookingsCubit>(
      () => BookingsCubit(getIt<BookingsRepository>()),
    )
    ..registerLazySingleton<NotificationsClient>(
      () => NotificationsClient(getIt<Dio>()),
    )
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepository(getIt<NotificationsClient>()),
    )
    ..registerFactory<NotificationsCubit>(
      () => NotificationsCubit(getIt<NotificationsRepository>()),
    )
    ..registerLazySingleton<MessagesClient>(() => MessagesClient(getIt<Dio>()))
    ..registerLazySingleton<MessagesRepository>(
      () => MessagesRepository(getIt<MessagesClient>()),
    )
    ..registerFactory<MessagesCubit>(
      () => MessagesCubit(getIt<MessagesRepository>()),
    )
    ..registerFactoryParam<ChatCubit, String, void>(
      (threadId, _) =>
          ChatCubit(getIt<MessagesRepository>(), threadId: threadId),
    )
    ..registerLazySingleton<ProfileClient>(() => ProfileClient(getIt<Dio>()))
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepository(
        getIt<ProfileClient>(),
        getIt<SessionStore>(),
        getIt<SessionCubit>(),
      ),
    )
    ..registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()))
    ..registerFactory<SplashCubit>(() => SplashCubit(getIt<SessionCubit>()))
    ..registerFactory<HomeCubit>(() => HomeCubit(getIt<HomeRepository>()))
    ..registerLazySingleton<ExploreSessionStore>(ExploreSessionStore.new)
    ..registerLazySingleton<ExploreCubit>(
      () => ExploreCubit(
        getIt<HomeRepository>(),
        getIt<ExploreSessionStore>(),
      ),
    )
    ..registerFactory<SearchCubit>(
      () => SearchCubit(getIt<SearchRepository>()),
    )
    ..registerLazySingleton<ProfileCubit>(
      () => ProfileCubit(getIt<ProfileRepository>(), getIt<SessionCubit>()),
    );
}
