enum BudgetFlex { strict, flexible, wide }
enum StayChange { longer, shorter }
enum PrimaryVibe { urban, nature, culture, luxury, balanced }
enum Pace { dynamic_, slow }
enum CrowdPref { social, lowCrowd }
enum ComfortPref { luxury, simple }

class TouristDNA {
  final PrimaryVibe primaryVibe;
  final Pace pace;
  final CrowdPref crowd;
  final ComfortPref comfort;

  const TouristDNA({
    required this.primaryVibe,
    required this.pace,
    required this.crowd,
    required this.comfort,
  });

  String get primaryVibeLabel {
    switch (primaryVibe) {
      case PrimaryVibe.urban: return 'Urban Explorer';
      case PrimaryVibe.nature: return 'Nature Seeker';
      case PrimaryVibe.culture: return 'Culture Enthusiast';
      case PrimaryVibe.luxury: return 'Luxury Traveler';
      case PrimaryVibe.balanced: return 'Balanced Wanderer';
    }
  }

  String get summary =>
      '$primaryVibeLabel · ${pace == Pace.dynamic_ ? 'Dynamic pace' : 'Slow pace'} · '
      '${crowd == CrowdPref.social ? 'Social' : 'Low-crowd'} · '
      '${comfort == ComfortPref.luxury ? 'Luxury comfort' : 'Simple comfort'}';
}

class TouristProfile {
  final String homeContinent;
  final StayChange stayChange;
  final BudgetFlex budgetFlex;

  const TouristProfile({
    required this.homeContinent,
    required this.stayChange,
    required this.budgetFlex,
  });
}