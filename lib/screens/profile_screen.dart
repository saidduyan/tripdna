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
  String? _homeContinent;
  StayChange? _stayChange;
  BudgetFlex? _budgetFlex;

  final _continents = [
    'Europe', 'Asia', 'North America', 'South America', 'Africa', 'Oceania'
  ];

  bool get _canProceed =>
      _homeContinent != null && _stayChange != null && _budgetFlex != null;

  void _proceed() {
    final dna = computeDNA(widget.quizScores);
    final profile = TouristProfile(
      homeContinent: _homeContinent!,
      stayChange: _stayChange!,
      budgetFlex: _budgetFlex!,
    );
    final ranked = rankDestinations(
      destinations: destinations,
      scores: widget.quizScores,
      dna: dna,
      profile: profile,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          dna: dna,
          rankedDestinations: ranked,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Icon(
                    Icons.person_search_outlined,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Almost there!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'A few questions to fine-tune your match',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Q1: Home continent
                _SectionCard(
                  title: '1. Where are you based?',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _continents.map((c) {
                      final selected = _homeContinent == c;
                      return ChoiceChip(
                        label: Text(c),
                        selected: selected,
                        onSelected: (_) => setState(() => _homeContinent = c),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Q2: Stay change
                _SectionCard(
                  title: '2. Preferred trip length?',
                  child: Column(
                    children: [
                      _OptionTile(
                        label: '+ 1 week (longer stay)',
                        icon: Icons.calendar_month,
                        selected: _stayChange == StayChange.longer,
                        onTap: () => setState(() => _stayChange = StayChange.longer),
                      ),
                      const SizedBox(height: 8),
                      _OptionTile(
                        label: '- 1 week (quick trip)',
                        icon: Icons.flash_on,
                        selected: _stayChange == StayChange.shorter,
                        onTap: () => setState(() => _stayChange = StayChange.shorter),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Q3: Budget
                _SectionCard(
                  title: '3. Budget flexibility?',
                  child: Column(
                    children: [
                      _OptionTile(
                        label: 'Strict — keeping it lean',
                        icon: Icons.savings_outlined,
                        selected: _budgetFlex == BudgetFlex.strict,
                        onTap: () => setState(() => _budgetFlex = BudgetFlex.strict),
                      ),
                      const SizedBox(height: 8),
                      _OptionTile(
                        label: 'Flexible — comfort when needed',
                        icon: Icons.account_balance_wallet_outlined,
                        selected: _budgetFlex == BudgetFlex.flexible,
                        onTap: () => setState(() => _budgetFlex = BudgetFlex.flexible),
                      ),
                      const SizedBox(height: 8),
                      _OptionTile(
                        label: 'Wide — experience matters more',
                        icon: Icons.diamond_outlined,
                        selected: _budgetFlex == BudgetFlex.wide,
                        onTap: () => setState(() => _budgetFlex = BudgetFlex.wide),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor:
                          theme.colorScheme.surfaceVariant,
                    ),
                    onPressed: _canProceed ? _proceed : null,
                    child: const Text(
                      'Show My Destinations 🌍',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceVariant,
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle,
                  color: theme.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}