import 'package:flutter/material.dart';
import 'package:trip_tuner/services/auth_service.dart';
import 'photo_quiz_screen.dart';

// Firebase user name fetch
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  Future<Map<String, dynamic>?> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!doc.exists) return {
      'firstName': null,
      'lastName': null,
      'email': user.email,
    };

    final data = doc.data()!;
    data['email'] ??= user.email;
    return data;
  }

  String _displayName(Map<String, dynamic>? data) {
    if (data == null) return '';
    final first = (data['firstName'] ?? '').toString().trim();
    final last = (data['lastName'] ?? '').toString().trim();
    if (first.isNotEmpty || last.isNotEmpty) {
      return [first, last].where((x) => x.isNotEmpty).join(' ');
    }
    final email = (data['email'] ?? '').toString().trim();
    if (email.isNotEmpty) return email;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await AuthService.signOut();
            },
            icon: const Icon(Icons.logout, color: Colors.white70, size: 18),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: _loadUserProfile(),
                builder: (context, snapshot) {
                  final name = _displayName(snapshot.data);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.travel_explore,
                        size: 88,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 18),

                      // Greeting (new)
                      if (snapshot.connectionState == ConnectionState.waiting)
                        Text(
                          'Loading your profile...',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.80),
                          ),
                          textAlign: TextAlign.center,
                        )
                      else if (name.isNotEmpty)
                        Text(
                          'Hi, $name 👋',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white.withOpacity(0.92),
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        )
                      else
                        Text(
                          'Hi there 👋',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white.withOpacity(0.92),
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: 10),

                      Text(
                        'TripTuner',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Discover your travel DNA\nand find your perfect destination',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      const _InfoRow(icon: Icons.photo_library_outlined, text: '12 photo picks'),
                      const SizedBox(height: 12),
                      const _InfoRow(icon: Icons.person_outline, text: 'Quick profile questions'),
                      const SizedBox(height: 12),
                      const _InfoRow(icon: Icons.place_outlined, text: 'Top 4 tailored destinations'),
                      const SizedBox(height: 56),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const PhotoQuizScreen(),
                              ),
                            );
                          },
                          child: const Text('Start My Journey ✈️'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
      ],
    );
  }
}