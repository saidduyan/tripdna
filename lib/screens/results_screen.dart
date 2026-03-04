import 'package:flutter/material.dart';
import '../models/tourist_profile.dart';
import '../services/recommendation_engine.dart';
import 'start_screen.dart';

class ResultsScreen extends StatelessWidget {
  final TouristDNA dna;
  final List<ScoredDestination> rankedDestinations;

  const ResultsScreen({
    super.key,
    required this.dna,
    required this.rankedDestinations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.travel_explore,
                                color: Colors.white, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              'Your Results',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dna.summary,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DNA Card
                  _DNACard(dna: dna, theme: theme),
                  const SizedBox(height: 24),
                  Text(
                    '🏆 Your Top 4 Destinations',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...rankedDestinations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final sd = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _DestinationCard(
                        rank: index + 1,
                        scored: sd,
                        theme: theme,
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Start Over',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const StartScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DNACard extends StatelessWidget {
  final TouristDNA dna;
  final ThemeData theme;

  const _DNACard({required this.dna, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.biotech_outlined,
                    color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Your Tourist DNA',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DNARow(
              label: 'Primary Vibe',
              value: dna.primaryVibeLabel,
              icon: Icons.explore,
              theme: theme,
            ),
            _DNARow(
              label: 'Pace',
              value: dna.pace == Pace.dynamic_ ? 'Dynamic' : 'Slow & Mindful',
              icon: Icons.speed,
              theme: theme,
            ),
            _DNARow(
              label: 'Crowd',
              value: dna.crowd == CrowdPref.social ? 'Social Butterfly' : 'Off-the-beaten-path',
              icon: Icons.people_outline,
              theme: theme,
            ),
            _DNARow(
              label: 'Comfort',
              value: dna.comfort == ComfortPref.luxury ? 'Luxury Seeker' : 'Authentic & Simple',
              icon: Icons.hotel_outlined,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _DNARow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;

  const _DNARow({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.secondary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final int rank;
  final ScoredDestination scored;
  final ThemeData theme;

  const _DestinationCard({
    required this.rank,
    required this.scored,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final dest = scored.destination;
    final colors = [
      const Color(0xFFFFD700), // gold
      const Color(0xFFC0C0C0), // silver
      const Color(0xFFCD7F32), // bronze
      theme.colorScheme.primaryContainer,
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors[rank - 1],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dest.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dest.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                // Debug score
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${scored.score.toStringAsFixed(1)} pts',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 16,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      scored.whyMatch,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _TraitChips(dest: dest, theme: theme),
          ],
        ),
      ),
    );
  }
}

class _TraitChips extends StatelessWidget {
  final dynamic dest;
  final ThemeData theme;

  const _TraitChips({required this.dest, required this.theme});

  @override
  Widget build(BuildContext context) {
    final traits = <String>[];
    if (dest.isCity) traits.add('🏙 City');
    if (dest.isBeach) traits.add('🏖 Beach');
    if (dest.isNature) traits.add('🌿 Nature');
    if (dest.isMountain) traits.add('🏔 Mountain');
    if (dest.isCulture) traits.add('🎭 Culture');
    if (dest.isLandmarks) traits.add('🗿 Landmarks');
    if (dest.isLuxury) traits.add('💎 Luxury');
    if (dest.isWellness) traits.add('🧘 Wellness');
    if (dest.isNightlife) traits.add('🌙 Nightlife');
    if (dest.isModern) traits.add('⚡ Modern');
    if (dest.isFoodKnown) traits.add('🍽 Food');

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: traits
          .map((t) => Chip(
                label: Text(t, style: const TextStyle(fontSize: 11)),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ))
          .toList(),
    );
  }
}