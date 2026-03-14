class MonthData {
  final String month;
  final int priceIndex;    // 1=çok ucuz, 5=çok pahalı
  final int crowdIndex;    // 1=ıssız, 5=çok kalabalık
  final int weatherScore;  // 1=kötü, 5=mükemmel
  final String weatherDesc;

  const MonthData({
    required this.month,
    required this.priceIndex,
    required this.crowdIndex,
    required this.weatherScore,
    required this.weatherDesc,
  });
}

class TravelTiming {
  final String destinationName;
  final List<MonthData> months; // 12 ay
  final String bestMonthsSummary;
  final String avoidMonthsSummary;
  final String tip;

  const TravelTiming({
    required this.destinationName,
    required this.months,
    required this.bestMonthsSummary,
    required this.avoidMonthsSummary,
    required this.tip,
  });

  // En ucuz aylar (priceIndex <= 2)
  List<String> get cheapMonths => months
      .where((m) => m.priceIndex <= 2)
      .map((m) => m.month)
      .toList();

  // En pahalı aylar (priceIndex >= 4)
  List<String> get expensiveMonths => months
      .where((m) => m.priceIndex >= 4)
      .map((m) => m.month)
      .toList();

  // En iyi zaman (hava + fiyat dengesi)
  List<String> get sweetSpotMonths => months
      .where((m) => m.weatherScore >= 4 && m.priceIndex <= 3)
      .map((m) => m.month)
      .toList();

  // Gezginlerin en çok tercih ettiği (kalabalık >= 4)
  List<String> get popularMonths => months
      .where((m) => m.crowdIndex >= 4)
      .map((m) => m.month)
      .toList();
}