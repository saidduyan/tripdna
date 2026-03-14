import '../models/destination.dart';
import '../models/tourist_profile.dart';

class ScoredDestination {
  final Destination destination;
  final double score;
  final String whyMatch;
  const ScoredDestination({required this.destination, required this.score, required this.whyMatch});
}

TouristDNA computeDNA(Map<String, double> scores) {
  final urban = (scores['city'] ?? 0) + (scores['modern'] ?? 0) + (scores['nightlife'] ?? 0);
  final nature = (scores['mountain'] ?? 0) + (scores['beach'] ?? 0) + (scores['adventure'] ?? 0);
  final culture = (scores['culture'] ?? 0) + (scores['landmarks'] ?? 0) + (scores['hidden'] ?? 0);
  final luxScore = (scores['luxury'] ?? 0) + (scores['wellness'] ?? 0) + (scores['food_fine'] ?? 0);

  final vibeMap = {
    PrimaryVibe.urban: urban,
    PrimaryVibe.nature: nature,
    PrimaryVibe.culture: culture,
    PrimaryVibe.luxury: luxScore,
  };
  final sorted = vibeMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  final top = sorted.first;
  final second = sorted[1];
  final threshold = top.value * 0.15;
  final primaryVibe = (top.value - second.value) < threshold ? PrimaryVibe.balanced : top.key;

  final dynamicScore = (scores['city'] ?? 0) + (scores['adventure'] ?? 0) + (scores['nightlife'] ?? 0);
  final slowScore = (scores['relax'] ?? 0) + (scores['quiet'] ?? 0) + (scores['wellness'] ?? 0);
  final social = (scores['nightlife'] ?? 0) + (scores['city'] ?? 0);
  final lowCrowd = (scores['hidden'] ?? 0) + (scores['quiet'] ?? 0);
  final luxComfort = (scores['luxury'] ?? 0) + (scores['food_fine'] ?? 0);
  final simpleComfort = (scores['food_street'] ?? 0) + (scores['hidden'] ?? 0);

  return TouristDNA(
    primaryVibe: primaryVibe,
    pace: dynamicScore >= slowScore ? Pace.dynamic_ : Pace.slow,
    crowd: social >= lowCrowd ? CrowdPref.social : CrowdPref.lowCrowd,
    comfort: luxComfort >= simpleComfort ? ComfortPref.luxury : ComfortPref.simple,
  );
}

List<ScoredDestination> rankDestinations({
  required List<Destination> destinations,
  required Map<String, double> scores,
  required TouristDNA dna,
  required TouristProfile profile,
}) {
  final maxScore = scores.values.fold(0.0, (a, b) => a > b ? a : b);
  final norm = maxScore > 0 ? maxScore : 1.0;
  final s = scores.map((k, v) => MapEntry(k, v / norm));

  return destinations.map((dest) {
    double score = 0;
    List<String> reasons = [];

    // Base affinity dot-product
    dest.tagAffinities.forEach((tag, affinity) {
      final userScore = s[tag] ?? 0;
      score += userScore * affinity;
    });

    // DNA multiplier
    switch (dna.primaryVibe) {
      case PrimaryVibe.urban:
        final isUrban = (dest.tagAffinities['city'] ?? 0) > 3 || (dest.tagAffinities['modern'] ?? 0) > 3;
        if (isUrban) { score *= 1.5; reasons.add('urban DNA'); } else { score *= 0.75; }
        break;
      case PrimaryVibe.nature:
        final isNature = (dest.tagAffinities['mountain'] ?? 0) > 3 || (dest.tagAffinities['beach'] ?? 0) > 3 || (dest.tagAffinities['adventure'] ?? 0) > 3;
        if (isNature) { score *= 1.5; reasons.add('nature DNA'); } else { score *= 0.75; }
        break;
      case PrimaryVibe.culture:
        final isCulture = (dest.tagAffinities['culture'] ?? 0) > 3 || (dest.tagAffinities['landmarks'] ?? 0) > 3;
        if (isCulture) { score *= 1.5; reasons.add('culture DNA'); } else { score *= 0.75; }
        break;
      case PrimaryVibe.luxury:
        final isLux = (dest.tagAffinities['luxury'] ?? 0) > 3 || (dest.tagAffinities['wellness'] ?? 0) > 3;
        if (isLux) { score *= 1.5; reasons.add('luxury DNA'); } else { score *= 0.75; }
        break;
      case PrimaryVibe.balanced:
        break;
    }

    // Budget
    switch (profile.budgetFlex) {
      case BudgetFlex.tight:
        if (dest.budgetLevel == 2) { score *= 0.5; }
        if (dest.budgetLevel == 0) { score *= 1.3; reasons.add('budget friendly'); }
        break;
      case BudgetFlex.medium:
        if (dest.budgetLevel == 2) score *= 0.85;
        if (dest.budgetLevel == 0) score *= 1.1;
        break;
      case BudgetFlex.flexible:
        if (dest.budgetLevel == 2) { score *= 1.3; reasons.add('premium match'); }
        break;
    }

    // Stay
    switch (profile.stayChange) {
      case StayChange.longer:
        if (dest.longStayFriendly) score *= 1.2;
        if (dest.shortTripFriendly && !dest.longStayFriendly) score *= 0.9;
        break;
      case StayChange.shorter:
        if (dest.shortTripFriendly) score *= 1.2;
        if (dest.longStayFriendly && !dest.shortTripFriendly) score *= 0.9;
        break;
    }

    // Continent comfort
    if (dest.continent == profile.homeContinent) {
      score *= 1.1;
      reasons.add('close to home');
    }

    // Top tag reasons
    final sortedTags = dest.tagAffinities.entries.toList()
      ..sort((a, b) => ((s[b.key] ?? 0) * b.value).compareTo((s[a.key] ?? 0) * a.value));
    for (final t in sortedTags.take(2)) {
      final label = t.key.replaceAll('_', ' ');
      if (!reasons.contains(label)) reasons.add(label);
    }

    return ScoredDestination(
      destination: dest,
      score: double.parse(score.toStringAsFixed(2)),
      whyMatch: reasons.take(4).join(' + '),
    );
  }).toList()
    ..sort((a, b) => b.score.compareTo(a.score));
}