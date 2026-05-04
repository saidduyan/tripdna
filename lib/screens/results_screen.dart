import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tourist_profile.dart';
import '../services/recommendation_engine.dart';
import '../services/auth_service.dart';
import '../data/destinations_data.dart';
import '../screens/destination_detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/start_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultsScreen extends StatefulWidget {
  final TouristDNA dna;
  final List<ScoredDestination> rankedDestinations;
  final Map<String, double> quizScores;
  final TouristProfile profile;

  const ResultsScreen({
    super.key,
    required this.dna,
    required this.rankedDestinations,
    required this.quizScores,
    required this.profile,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late List<ScoredDestination> _allRanked;
  late List<ScoredDestination> _displayed;
  Set<String> _beenHere = {};
  int _showCount = 4;
  bool _loadingMore = false;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _allRanked = rankDestinations(
      destinations: destinations,
      scores: widget.quizScores,
      dna: widget.dna,
      profile: widget.profile,
    ).take(10).toList();

    _displayed = _allRanked.take(4).toList();
    _loadBeenHere();
    _saveResult();
  }

  Future<void> _loadBeenHere() async {
    if (_uid == null) return;
    final list = await AuthService().getBeenHere(_uid!);
    if (mounted) setState(() => _beenHere = list.toSet());
  }

  Future<void> _saveResult() async {
    if (_uid == null) return;
    await AuthService().saveResult(uid: _uid!, resultData: {
      'dna': widget.dna.toMap(),
      'profile': widget.profile.toMap(),
      'topDestination': _allRanked.first.destination.name,
      'scores': widget.quizScores,
    });
    await FirebaseFirestore.instance.collection('users').doc(_uid).update({
    'topDestination': _allRanked.first.destination.name,
    'dnaVibe': widget.dna.primaryVibeLabel,
    'continent': widget.profile.homeContinent,
  });
  }

  Future<void> _markBeenHere(ScoredDestination scored) async {
    final name = scored.destination.name;

    if (_uid != null) {
      await AuthService().addBeenHere(_uid!, name);
    }

    setState(() {
      _beenHere.add(name);
      _displayed.remove(scored);

      final shown = _displayed.map((s) => s.destination.name).toSet();
      shown.addAll(_beenHere);

      final next = _allRanked.firstWhere(
        (s) => !shown.contains(s.destination.name),
        orElse: () => scored,
      );

      if (next != scored) _displayed.add(next);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child:
                    Text('${scored.destination.name} added to Past Travels ✈️'),
              ),
              GestureDetector(
                onTap: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () => _undoBeenHere(name),
          ),
        ),
      );
    }
  }

  Future<void> _undoBeenHere(String name) async {
    if (_uid != null) {
      await AuthService().removeBeenHere(_uid!, name);
    }
    setState(() {
      _beenHere.remove(name);
      _rebuildDisplayed();
    });
  }

  void _rebuildDisplayed() {
    final filtered = _allRanked
        .where((s) => !_beenHere.contains(s.destination.name))
        .toList();
    _displayed = filtered.take(_showCount).toList();
  }

  void _showMore() {
    setState(() => _loadingMore = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _showCount = (_showCount + 2).clamp(0, 10);
        _rebuildDisplayed();
        _loadingMore = false;
      });
    });
  }

  bool get _canShowMore {
    final available =
        _allRanked.where((s) => !_beenHere.contains(s.destination.name)).length;
    return _showCount < available && _showCount < 10;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 170,
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
                      Row(children: [
                        const Icon(Icons.travel_explore,
                            color: Colors.white, size: 28),
                        const SizedBox(width: 8),
                        Text('Your TripDNA Results',
                            style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 8),
                      Text(widget.dna.summary,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9))),
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
                Card(
                  elevation: 0,
                  color: theme.colorScheme.secondaryContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.biotech_outlined,
                              color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('Tourist DNA',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 12),
                        _dnaRow(theme, Icons.explore, 'Primary Vibe',
                            widget.dna.primaryVibeLabel),
                        _dnaRow(
                            theme,
                            Icons.speed,
                            'Pace',
                            widget.dna.pace == Pace.dynamic_
                                ? 'Dynamic'
                                : 'Slow & Mindful'),
                        _dnaRow(
                            theme,
                            Icons.people_outline,
                            'Crowd',
                            widget.dna.crowd == CrowdPref.social
                                ? 'Social Butterfly'
                                : 'Off-beaten-path'),
                        _dnaRow(
                            theme,
                            Icons.hotel_outlined,
                            'Comfort',
                            widget.dna.comfort == ComfortPref.luxury
                                ? 'Luxury Seeker'
                                : 'Authentic & Simple'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🏆 Top ${_displayed.length} Destinations',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (_beenHere.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.luggage, size: 16),
                        label: Text('${_beenHere.length} visited'),
                        onPressed: () {},
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap "Been Here" to replace with a new suggestion',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 12),
                ..._displayed.asMap().entries.map((entry) {
                  final index = entry.key;
                  final sd = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _DestCard(
                      rank: index + 1,
                      scored: sd,
                      theme: theme,
                      beenHere: _beenHere.contains(sd.destination.name),
                      onBeenHere: () => _markBeenHere(sd),
                    ),
                  );
                }),
                if (_canShowMore) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: _loadingMore
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.expand_more),
                      label: Text(_loadingMore
                          ? 'Loading...'
                          : 'Show More Destinations'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _loadingMore ? null : _showMore,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.home_outlined),
                    label: const Text(
                      'Go to Home ✈️',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Start Over',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const StartScreen()),
                      (r) => false,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _dnaRow(ThemeData theme, IconData icon, String label, String value) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(icon, size: 18, color: theme.colorScheme.secondary),
          const SizedBox(width: 10),
          Text('$label: ',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer
                      .withValues(alpha: 0.7))),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ]),
      );
}

class _DestCard extends StatelessWidget {
  final int rank;
  final ScoredDestination scored;
  final ThemeData theme;
  final bool beenHere;
  final VoidCallback onBeenHere;

  const _DestCard({
    required this.rank,
    required this.scored,
    required this.theme,
    required this.beenHere,
    required this.onBeenHere,
  });

  @override
  Widget build(BuildContext context) {
    final dest = scored.destination;
    final rankColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
      theme.colorScheme.tertiaryContainer,
      theme.colorScheme.surfaceVariant,
      theme.colorScheme.surfaceVariant,
      theme.colorScheme.surfaceVariant,
      theme.colorScheme.surfaceVariant,
    ];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DestinationDetailScreen(destination: dest)),
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: rank <= rankColors.length
                        ? rankColors[rank - 1]
                        : theme.colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('#$rank',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${dest.name}, ${dest.country}',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(dest.subtitle,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.outline)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${scored.score} pts',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(scored.whyMatch,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ),
                    ]),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(
                      beenHere
                          ? Icons.check_circle
                          : Icons.flight_takeoff_outlined,
                      size: 16,
                      color:
                          beenHere ? Colors.green : theme.colorScheme.primary,
                    ),
                    label: Text(
                      beenHere ? 'Been Here ✓' : 'Been Here?',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            beenHere ? Colors.green : theme.colorScheme.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      side: BorderSide(
                        color:
                            beenHere ? Colors.green : theme.colorScheme.outline,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: beenHere ? null : onBeenHere,
                  ),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              DestinationDetailScreen(destination: dest)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Explore', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
