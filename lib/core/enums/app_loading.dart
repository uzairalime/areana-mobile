enum AppLoading { initial, loading, error, success }

extension AppLoadingX on AppLoading {
  bool get isInitial => this == AppLoading.initial;

  bool get isLoading => this == AppLoading.loading;

  bool get isError => this == AppLoading.error;

  bool get isSuccess => this == AppLoading.success;
}
