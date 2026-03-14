class Destination {
  final String name;
  final String country;
  final String continent;
  final String subtitle;
  final List<String> imageAssets; // up to 5
  final Map<String, double> tagAffinities;
  final int budgetLevel; // 0=low, 1=mid, 2=high
  final bool longStayFriendly;
  final bool shortTripFriendly;
  final Map<String, bool> amenities;

  const Destination({
    required this.name,
    required this.country,
    required this.continent,
    required this.subtitle,
    required this.imageAssets,
    required this.tagAffinities,
    required this.budgetLevel,
    this.longStayFriendly = false,
    this.shortTripFriendly = false,
    required this.amenities,
  });

  double affinity(String tag) => tagAffinities[tag] ?? 0.0;
}