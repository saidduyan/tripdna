import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/traveler.dart';
import '../services/match_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _service = MatchService();
  List<Traveler> _candidates = [];
  int _currentIndex = 0;
  bool _loading = true;
  bool _profileReady = false;
  Map<String, dynamic>? _myProfile;

  // Filter state
  String _preferredGender = 'Any';
  int _minAge = 18;
  int _maxAge = 60;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final profile = await _service.getUserProfile(uid);
    setState(() {
      _myProfile = profile;
      _profileReady = profile?['exploreEnabled'] == true;
      if (_profileReady) {
        _preferredGender = profile?['preferredGender'] ?? 'Any';
        _minAge = profile?['minAge'] ?? 18;
        _maxAge = profile?['maxAge'] ?? 60;
      }
    });
    if (_profileReady) _loadCandidates();
    else setState(() => _loading = false);
  }

  Future<void> _loadCandidates() async {
    setState(() => _loading = true);
    final candidates = await _service.fetchCandidates(
      preferredGender: _preferredGender,
      topDestination: _myProfile?['topDestination'] ?? '',
      minAge: _minAge,
      maxAge: _maxAge,
    );
    setState(() { _candidates = candidates; _currentIndex = 0; _loading = false; });
  }

  Future<void> _onLike() async {
    if (_currentIndex >= _candidates.length) return;
    final target = _candidates[_currentIndex];
    final isMatch = await _service.likeUser(target.uid);
    if (isMatch && mounted) {
      _showMatchDialog(target);
    }
    setState(() => _currentIndex++);
  }

  Future<void> _onPass() async {
    if (_currentIndex >= _candidates.length) return;
    await _service.passUser(_candidates[_currentIndex].uid);
    setState(() => _currentIndex++);
  }

  void _showMatchDialog(Traveler other) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 It\'s a Match!', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('You and ${other.firstName} both want to visit\n${other.topDestination}!',
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Start planning your trip together 🌍',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600)),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Exploring'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go to Matches'),
          ),
        ],
      ),
    );
  }

  void _showSetupSheet() {
    String gender = 'Male';
    String preferredGender = 'Any';
    DateTime travelDate = DateTime.now().add(const Duration(days: 30));
    int minAge = 18;
    int maxAge = 45;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24,
              MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Set Up Explore Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            const Text('I am', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: ['Male', 'Female', 'Other'].map((g) =>
              ChoiceChip(label: Text(g), selected: gender == g,
                  onSelected: (_) => setModalState(() => gender = g)),
            ).toList()),
            const SizedBox(height: 16),

            const Text('Looking for', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: ['Any', 'Male', 'Female', 'Other'].map((g) =>
              ChoiceChip(label: Text(g), selected: preferredGender == g,
                  onSelected: (_) => setModalState(() => preferredGender = g)),
            ).toList()),
            const SizedBox(height: 16),

            const Text('Age range', style: TextStyle(fontWeight: FontWeight.w600)),
            RangeSlider(
              values: RangeValues(minAge.toDouble(), maxAge.toDouble()),
              min: 18, max: 70, divisions: 52,
              labels: RangeLabels('$minAge', '$maxAge'),
              onChanged: (v) => setModalState(() {
                minAge = v.start.toInt();
                maxAge = v.end.toInt();
              }),
            ),
            Text('$minAge - $maxAge years',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),

            const Text('When do you want to travel?',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text('${travelDate.day}/${travelDate.month}/${travelDate.year}'),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: travelDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (picked != null) setModalState(() => travelDate = picked);
              },
            ),
            const SizedBox(height: 24),

            SizedBox(width: double.infinity, child: FilledButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                Navigator.pop(ctx);
                await _service.updateTravelProfile(
                  gender: gender,
                  preferredGender: preferredGender,
                  travelDate: travelDate,
                  minAge: minAge,
                  maxAge: maxAge,
                  topDestination: _myProfile?['topDestination'] ?? '',
                  dnaVibe: _myProfile?['dnaVibe'] ?? '',
                  continent: _myProfile?['continent'] ?? '',
                );
                await _loadProfile();
              },
              child: const Text('Start Exploring 🌍',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Travelers', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showSetupSheet,
            tooltip: 'Filters',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_profileReady
              ? _buildSetupPrompt(theme)
              : _currentIndex >= _candidates.length
                  ? _buildEmpty(theme)
                  : _buildSwipeCard(theme),
    );
  }

  Widget _buildSetupPrompt(ThemeData theme) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.explore_outlined, size: 80, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text('Find Your Travel Buddy', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Complete the quiz first, then set up your explore profile to find travelers heading to the same destination!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 32),
        FilledButton.icon(
          icon: const Icon(Icons.person_add),
          label: const Text('Set Up Profile'),
          style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: _showSetupSheet,
        ),
      ]),
    ));
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.sentiment_satisfied_alt, size: 80, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text('No more travelers!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Check back later for new travelers heading to ${_myProfile?['topDestination'] ?? 'your destination'}.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
          onPressed: _loadCandidates,
        ),
      ]),
    ));
  }

  Widget _buildSwipeCard(ThemeData theme) {
    final traveler = _candidates[_currentIndex];
    return Column(children: [
      // Progress
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${_candidates.length - _currentIndex} travelers nearby',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          Text('→ ${_myProfile?['topDestination'] ?? ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
        ]),
      ),
      // Card
      Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [theme.colorScheme.primaryContainer, theme.colorScheme.secondaryContainer],
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(fit: StackFit.expand, children: [
                // Background pattern
                Positioned.fill(child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.secondary.withOpacity(0.05)],
                    ),
                  ),
                )),
                // Content
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          traveler.firstName.isNotEmpty ? traveler.firstName[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('${traveler.firstName} ${traveler.lastName}',
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('@${traveler.username}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                      const SizedBox(height: 20),
                      // Info chips
                      Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                        _Chip(icon: Icons.cake_outlined, label: '${traveler.age} years old'),
                        _Chip(icon: Icons.flight_takeoff, label: traveler.topDestination),
                        _Chip(icon: Icons.psychology_outlined, label: traveler.dnaVibe),
                        if (traveler.travelDate != null)
                          _Chip(icon: Icons.calendar_today,
                              label: '${traveler.travelDate!.day}/${traveler.travelDate!.month}/${traveler.travelDate!.year}'),
                        _Chip(icon: Icons.public, label: traveler.continent),
                      ]),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      )),
      // Action buttons
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          // Pass
          GestureDetector(
            onTap: _onPass,
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                border: Border.all(color: Colors.red.shade200, width: 2),
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 32),
            ),
          ),
          // Like
          GestureDetector(
            onTap: _onLike,
            child: Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary,
                boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 36),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
      ]),
    );
  }
}