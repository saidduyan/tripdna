import 'package:flutter/material.dart';
import '../models/tourist_profile.dart';
import '../data/destinations_data.dart';
import '../services/recommendation_engine.dart';
import 'results_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, double> quizScores;
  const ProfileScreen({super.key, required this.quizScores});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _continent;
  StayChange? _stay;
  BudgetFlex? _budget;

  final _continents = ['Europe','Asia','North America','South America','Africa','Oceania'];

  bool get _ready => _continent != null && _stay != null && _budget != null;

  void _proceed() {
    final dna = computeDNA(widget.quizScores);
    final profile = TouristProfile(homeContinent: _continent!, stayChange: _stay!, budgetFlex: _budget!);
    final ranked = rankDestinations(destinations: destinations, scores: widget.quizScores, dna: dna, profile: profile);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => ResultsScreen(dna: dna, rankedDestinations: ranked.take(4).toList(), quizScores: widget.quizScores, profile: profile),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [theme.colorScheme.primaryContainer, theme.colorScheme.surface],
        )),
        child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(child: Icon(Icons.person_search_outlined, size: 56, color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            Center(child: Text('Almost there!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))),
            Center(child: Text('Fine-tune your match', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline))),
            const SizedBox(height: 28),
            _Card(title: '1. Where are you based?', child: Wrap(spacing: 8, runSpacing: 8,
              children: _continents.map((c) => ChoiceChip(
                label: Text(c), selected: _continent == c,
                onSelected: (_) => setState(() => _continent = c),
              )).toList(),
            )),
            const SizedBox(height: 16),
            _Card(title: '2. Preferred trip length?', child: Column(children: [
              _Tile(label: '+ 1 week — longer stay', icon: Icons.calendar_month, selected: _stay == StayChange.longer, onTap: () => setState(() => _stay = StayChange.longer)),
              const SizedBox(height: 8),
              _Tile(label: '- 1 week — quick trip', icon: Icons.flash_on, selected: _stay == StayChange.shorter, onTap: () => setState(() => _stay = StayChange.shorter)),
            ])),
            const SizedBox(height: 16),
            _Card(title: '3. Budget flexibility?', child: Column(children: [
              _Tile(label: 'Tight — keeping it lean', icon: Icons.savings_outlined, selected: _budget == BudgetFlex.tight, onTap: () => setState(() => _budget = BudgetFlex.tight)),
              const SizedBox(height: 8),
              _Tile(label: 'Medium — comfort when needed', icon: Icons.account_balance_wallet_outlined, selected: _budget == BudgetFlex.medium, onTap: () => setState(() => _budget = BudgetFlex.medium)),
              const SizedBox(height: 8),
              _Tile(label: 'Flexible — experience first', icon: Icons.diamond_outlined, selected: _budget == BudgetFlex.flexible, onTap: () => setState(() => _budget = BudgetFlex.flexible)),
            ])),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: _ready ? _proceed : null,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Show My Destinations 🌍', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )),
            const SizedBox(height: 24),
          ],
        ))),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title; final Widget child;
  const _Card({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(elevation: 0, color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12), child,
      ])),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label; final IconData icon; final bool selected; final VoidCallback onTap;
  const _Tile({required this.label, required this.icon, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(onTap: onTap, child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: selected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceVariant,
        border: Border.all(color: selected ? theme.colorScheme.primary : Colors.transparent, width: 2),
      ),
      child: Row(children: [
        Icon(icon, color: selected ? theme.colorScheme.primary : theme.colorScheme.outline, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
        ))),
        if (selected) Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
      ]),
    ));
  }
}