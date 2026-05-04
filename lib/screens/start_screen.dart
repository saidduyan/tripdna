import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'auth_gate.dart';
import 'photo_quiz_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  List<String> _beenHere = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadBeenHere();
  }

  Future<void> _loadProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final profile = await AuthService()
            .getUserProfile(uid)
            .timeout(const Duration(seconds: 5));
        if (mounted) {
          setState(() {
            _profile = profile;
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadBeenHere() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final list = await AuthService().getBeenHere(uid);
    if (mounted) setState(() => _beenHere = list);
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = _profile?['firstName'] ?? '';
    final lastName = _profile?['lastName'] ?? '';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary
            ],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Colors.white))
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.logout,
                              color: Colors.white70),
                          onPressed: _logout,
                          tooltip: 'Sign out',
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.travel_explore,
                        size: 88, color: Colors.white),
                    const SizedBox(height: 16),
                    Text('TripDNA',
                        style: theme.textTheme.displaySmall
                            ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                    const SizedBox(height: 10),
                    Text('Hi, $firstName $lastName 👋',
                        style: theme.textTheme.titleLarge?.copyWith(
                            color:
                                Colors.white.withValues(alpha: 0.9))),
                    const SizedBox(height: 12),
                    Text(
                      'Discover your travel DNA\nand find your perfect destination',
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color:
                              Colors.white.withValues(alpha: 0.75)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _InfoRow(
                        icon: Icons.photo_library_outlined,
                        text: '12 photo picks'),
                    const SizedBox(height: 10),
                    _InfoRow(
                        icon: Icons.person_outline,
                        text: 'Quick profile questions'),
                    const SizedBox(height: 10),
                    _InfoRow(
                        icon: Icons.place_outlined,
                        text: 'Top destinations from 40+'),

                    // Past Travels
                    if (_beenHere.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Row(children: [
                                Icon(Icons.luggage,
                                    color: Colors.white70,
                                    size: 18),
                                SizedBox(width: 8),
                                Text('Past Travels',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ]),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: _beenHere
                                    .map((dest) => Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 10,
                                              vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(
                                                    alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                            border: Border.all(
                                                color: Colors.white
                                                    .withValues(
                                                        alpha: 0.4)),
                                          ),
                                          child: Row(
                                              mainAxisSize:
                                                  MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                    Icons
                                                        .check_circle,
                                                    size: 12,
                                                    color: Colors
                                                        .white70),
                                                const SizedBox(
                                                    width: 4),
                                                Text(dest,
                                                    style: const TextStyle(
                                                        color: Colors
                                                            .white,
                                                        fontSize:
                                                            12)),
                                              ]),
                                        ))
                                    .toList(),
                              ),
                            ]),
                      ),
                    ],

                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                              vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16)),
                          textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const PhotoQuizScreen()),
                        ),
                        child: const Text('Start My Journey ✈️'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Text(text,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 15)),
        ],
      );
}