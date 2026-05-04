import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'photo_quiz_screen.dart';

class DemoStartScreen extends StatefulWidget {
  const DemoStartScreen({super.key});

  @override
  State<DemoStartScreen> createState() => _DemoStartScreenState();
}

class _DemoStartScreenState extends State<DemoStartScreen> {
  final _nameController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _startDemo() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final user = await AuthService().signInAnonymously(name);

    if (!mounted) return;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const PhotoQuizScreen(),
        ),
      );
    } else {
      setState(() {
        _loading = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FDF9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Başlık
                Text(
                  'TripDNA',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A6B5A),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Know where you belong before you book.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF555555),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 40),

                // Bilgi kutusu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF1A6B5A), width: 1),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.travel_explore,
                          size: 44, color: Color(0xFF1A6B5A)),
                      SizedBox(height: 12),
                      Text(
                        'Discover your Tourist DNA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A6B5A),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '12 photo choices  →  your travel personality  →  perfect destinations',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF444444)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // İsim alanı
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _startDemo(),
                  decoration: InputDecoration(
                    labelText: 'Your first name',
                    hintText: 'e.g. Elif',
                    prefixIcon: const Icon(Icons.person_outline,
                        color: Color(0xFF1A6B5A)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF1A6B5A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF1A6B5A), width: 2),
                    ),
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: 24),

                // Buton
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _loading ? null : _startDemo,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1A6B5A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Discover My DNA  →',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No account needed  •  Takes 2 minutes',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}