import '../models/destination.dart';
import '../models/tourist_profile.dart';

class ScoredDestination {
  final Destination destination;
  final double score;
  final String whyMatch;

  const ScoredDestination({
    required this.destination,
    required this.score,
    required this.whyMatch,
  });
}

TouristDNA computeDNA(Map<String, double> scores) {
  // Primary vibe
  final urban = (scores['city'] ?? 0) + (scores['modern'] ?? 0) + (scores['nightlife'] ?? 0);
  final nature = (scores['mountain'] ?? 0) + (scores['beach'] ?? 0) + (scores['adventure'] ?? 0);
  final culture = (scores['culture'] ?? 0) + (scores['landmarks'] ?? 0) + (scores['hidden'] ?? 0);
  final luxuryScore = (scores['luxury'] ?? 0) + (scores['wellness'] ?? 0) + (scores['food_fine'] ?? 0);

  final maxVibe = [urban, nature, culture, luxuryScore].reduce((a, b) => a > b ? a : b);
  final diff = maxVibe - [urban, nature, culture, luxuryScore].where((v) => v != maxVibe).fold(0.0, (a, b) => a > b ? a : b);

  PrimaryVibe primaryVibe;
  if (diff < 2.0) {
    primaryVibe = PrimaryVibe.balanced;
  } else if (maxVibe == urban) {
    primaryVibe = PrimaryVibe.urban;
  } else if (maxVibe == nature) {
    primaryVibe = PrimaryVibe.nature;
  } else if (maxVibe == culture) {
    primaryVibe = PrimaryVibe.culture;
  } else {
    primaryVibe = PrimaryVibe.luxury;
  }

  // Pace
  final dynamic_ = (scores['city'] ?? 0) + (scores['adventure'] ?? 0) + (scores['nightlife'] ?? 0);
  final slow = (scores['relax'] ?? 0) + (scores['quiet'] ?? 0) + (scores['wellness'] ?? 0);
  final pace = dynamic_ >= slow ? Pace.dynamic_ : Pace.slow;

  // Crowd
  final social = (scores['nightlife'] ?? 0) + (scores['city'] ?? 0);
  final lowCrowd = (scores['hidden'] ?? 0) + (scores['quiet'] ?? 0);
  final crowd = social >= lowCrowd ? CrowdPref.social : CrowdPref.lowCrowd;

  // Comfort
  final luxComfort = (scores['luxury'] ?? 0) + (scores['food_fine'] ?? 0);
  final simpleComfort = (scores['food_street'] ?? 0) + (scores['hidden'] ?? 0);
  final comfort = luxComfort >= simpleComfort ? ComfortPref.luxury : ComfortPref.simple;

  return TouristDNA(
    primaryVibe: primaryVibe,
    pace: pace,
    crowd: crowd,
    comfort: comfort,
  );
}

List<ScoredDestination> rankDestinations({
  required List<Destination> destinations,
  required Map<String, double> scores,
  required TouristDNA dna,
  required TouristProfile profile,
}) {
  List<ScoredDestination> results = [];

  for (final dest in destinations) {
    double score = 0;
    List<String> reasons = [];

    // --- Base tag scoring ---
    if (dest.isCity) {
      final cityScore = (scores['city'] ?? 0) + (scores['modern'] ?? 0) + (scores['nightlife'] ?? 0) / 2;
      score += cityScore;
      if (cityScore > 2) reasons.add('city vibe');
    }
    if (dest.isBeach) {
      final beachScore = scores['beach'] ?? 0;
      score += beachScore;
      if (beachScore > 1.5) reasons.add('beach');
    }
    if (dest.isNature || dest.isMountain) {
      final natureScore = (scores['mountain'] ?? 0) + (scores['adventure'] ?? 0) / 2 + (scores['relax'] ?? 0) / 2;
      score += natureScore;
      if (natureScore > 2) reasons.add('nature/mountain');
    }
    if (dest.isCulture || dest.isLandmarks) {
      final cultScore = (scores['culture'] ?? 0) + (scores['landmarks'] ?? 0) + (scores['hidden'] ?? 0) / 2;
      score += cultScore;
      if (cultScore > 2) reasons.add('culture + landmarks');
    }
    if (dest.isLuxury || dest.isWellness) {
      final luxScore = (scores['luxury'] ?? 0) + (scores['wellness'] ?? 0) + (scores['relax'] ?? 0) / 2;
      score += luxScore;
      if (luxScore > 2) reasons.add('luxury/wellness');
    }
    // Food scoring
    final foodScore = (scores['food_street'] ?? 0) + (scores['food_fine'] ?? 0);
    if (foodScore > 1) {
      score += foodScore * (dest.isFoodKnown ? 1.3 : 0.6);
      if (dest.isFoodKnown && foodScore > 1.5) reasons.add('food scene');
    }

    // --- DNA influence ---
    switch (dna.primaryVibe) {
      case PrimaryVibe.urban:
        if (dest.isCity || dest.isModern) {
          score += 4;
          reasons.add('urban DNA match');
        }
        break;
      case PrimaryVibe.nature:
        if (dest.isNature || dest.isMountain || dest.isBeach) {
          score += 4;
          reasons.add('nature DNA match');
        }
        break;
      case PrimaryVibe.culture:
        if (dest.isCulture || dest.isLandmarks) {
          score += 4;
          reasons.add('culture DNA match');
        }
        break;
      case PrimaryVibe.luxury:
        if (dest.isLuxury || dest.isWellness) {
          score += 4;
          reasons.add('luxury DNA match');
        }
        break;
      case PrimaryVibe.balanced:
        score += 1;
        break;
    }

    // --- Profile influence ---
    // Budget
    switch (profile.budgetFlex) {
      case BudgetFlex.strict:
        if (dest.premiumLevel == 2) {
          score -= 4;
          reasons.removeWhere((r) => r == 'luxury DNA match');
        }
        if (dest.premiumLevel == 0) {
          score += 2;
          reasons.add('budget friendly');
        }
        break;
      case BudgetFlex.flexible:
        if (dest.premiumLevel == 2) score -= 1;
        if (dest.premiumLevel == 0) score += 1;
        break;
      case BudgetFlex.wide:
        if (dest.premiumLevel == 2) {
          score += 3;
          reasons.add('budget flexible');
        }
        break;
    }

    // Stay length
    switch (profile.stayChange) {
      case StayChange.longer:
        if (dest.longStayFriendly) score += 3;
        if (dest.shortTripFriendly && !dest.longStayFriendly) score += 1;
        break;
      case StayChange.shorter:
        if (dest.shortTripFriendly) score += 3;
        if (dest.longStayFriendly && !dest.shortTripFriendly) score += 1;
        break;
    }

    // Continent comfort
    if (dest.continent == profile.homeContinent) {
      score += 2;
      reasons.add('close to home');
    }

    // Nightlife bonus
    if (dest.isNightlife && (scores['nightlife'] ?? 0) > 2) {
      reasons.add('nightlife');
    }
    if (dest.isModern && (scores['modern'] ?? 0) > 1.5) {
      reasons.add('modern');
    }

    final whyMatch = reasons.isNotEmpty
        ? reasons.take(4).join(' + ')
        : 'well-rounded destination';

    results.add(ScoredDestination(
      destination: dest,
      score: score,
      whyMatch: whyMatch,
    ));
  }

  results.sort((a, b) => b.score.compareTo(a.score));
  return results.take(4).toList();
}