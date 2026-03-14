import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tourist_profile.dart';
import '../services/recommendation_engine.dart';
import '../services/auth_service.dart';
import 'destination_detail_screen.dart';
import 'start_screen.dart';

class ResultsScreen extends StatefulWidget {
  final TouristDNA dna;
  final List<ScoredDestination> rankedDestinations;
  final Map<String, double> quizScores;
  final TouristProfile profile;

  const ResultsScreen({super.key, required this.dna, required this.rankedDestinations, required this.quizScores, required this.profile});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await AuthService().saveResult(uid: uid, resultData: {
      'dna': widget.dna.toMap(),
      'profile': widget.profile.toMap(),
      'topDestination': widget.rankedDestinations.first.destination.name,
      'scores': widget.quizScores,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 170, pinned: true, automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
              )),
              child: SafeArea(child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [
                    const Icon(Icons.travel_explore, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text('Your TripDNA Results', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 8),
                  Text(widget.dna.summary, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9))),
                ]),
              )),
            ),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // DNA card
            Card(elevation: 0, color: theme.colorScheme.secondaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.biotech_outlined, color: theme.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text('Tourist DNA', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 12),
                _dnaRow(theme, Icons.explore, 'Primary Vibe', widget.dna.primaryVibeLabel),
                _dnaRow(theme, Icons.speed, 'Pace', widget.dna.pace == Pace.dynamic_ ? 'Dynamic' : 'Slow & Mindful'),
                _dnaRow(theme, Icons.people_outline, 'Crowd', widget.dna.crowd == CrowdPref.social ? 'Social Butterfly' : 'Off-beaten-path'),
                _dnaRow(theme, Icons.hotel_outlined, 'Comfort', widget.dna.comfort == ComfortPref.luxury ? 'Luxury Seeker' : 'Authentic & Simple'),
              ])),
            ),
            const SizedBox(height: 24),
            Text('🏆 Your Top ${widget.rankedDestinations.length} Destinations',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...widget.rankedDestinations.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _DestCard(rank: e.key + 1, scored: e.value, theme: theme),
            )),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Start Over', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const StartScreen()), (r) => false),
            )),
            const SizedBox(height: 32),
          ]),
        )),
      ]),
    );
  }

  Widget _dnaRow(ThemeData theme, IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Icon(icon, size: 18, color: theme.colorScheme.secondary),
      const SizedBox(width: 10),
      Text('$label: ', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7))),
      Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
    ]),
  );
}

class _DestCard extends StatelessWidget {
  final int rank; final ScoredDestination scored; final ThemeData theme;
  const _DestCard({required this.rank, required this.scored, required this.theme});

  @override
  Widget build(BuildContext context) {
    final dest = scored.destination;
    final rankColors = [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32), theme.colorScheme.primaryContainer];
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: dest))),
      child: Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: rankColors[rank - 1], shape: BoxShape.circle),
              child: Center(child: Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${dest.name}, ${dest.country}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(dest.subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
              child: Text('${scored.score} pts', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(10)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.lightbulb_outline, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(scored.whyMatch, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
            ]),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.arrow_forward_ios, size: 14, color: theme.colorScheme.outline),
            const SizedBox(width: 4),
            Text('Tap to explore', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          ]),
        ]),
      )),
    );
  }
}