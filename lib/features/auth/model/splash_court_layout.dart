/// Court-line overlay from the A0/A1 splash HTML (390×844 artboard).
class SplashCourtLayout {
  const SplashCourtLayout({
    required this.centerYFactor,
    required this.outerRadius,
    required this.innerRadius,
    required this.boxWidth,
    required this.topBoxHeight,
    required this.bottomBoxHeight,
    required this.lineOpacity,
    this.fillRadius,
  });

  static const launch = SplashCourtLayout(
    centerYFactor: 400 / 844,
    outerRadius: 190,
    innerRadius: 120,
    boxWidth: 220,
    topBoxHeight: 150,
    bottomBoxHeight: 200,
    lineOpacity: 0.14,
  );

  static const welcome = SplashCourtLayout(
    centerYFactor: 330 / 844,
    outerRadius: 150,
    innerRadius: 96,
    fillRadius: 46,
    boxWidth: 200,
    topBoxHeight: 130,
    bottomBoxHeight: 130,
    lineOpacity: 0.16,
  );

  final double centerYFactor;
  final double outerRadius;
  final double innerRadius;
  final double? fillRadius;
  final double boxWidth;
  final double topBoxHeight;
  final double bottomBoxHeight;
  final double lineOpacity;
}
