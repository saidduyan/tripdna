class Destination {
  final String name;
  final String subtitle;
  final String continent;
  final bool isCity;
  final bool isBeach;
  final bool isNature;
  final bool isMountain;
  final bool isCulture;
  final bool isLandmarks;
  final bool isLuxury;
  final bool isWellness;
  final bool isNightlife;
  final bool isModern;
  final bool isFoodKnown;
  final bool longStayFriendly;
  final bool shortTripFriendly;
  // premium: 0=budget, 1=medium, 2=high
  final int premiumLevel;

  const Destination({
    required this.name,
    required this.subtitle,
    required this.continent,
    this.isCity = false,
    this.isBeach = false,
    this.isNature = false,
    this.isMountain = false,
    this.isCulture = false,
    this.isLandmarks = false,
    this.isLuxury = false,
    this.isWellness = false,
    this.isNightlife = false,
    this.isModern = false,
    this.isFoodKnown = false,
    this.longStayFriendly = false,
    this.shortTripFriendly = false,
    required this.premiumLevel,
  });
}