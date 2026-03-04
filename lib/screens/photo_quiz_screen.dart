import 'package:flutter/material.dart';
import '../data/quiz_data.dart';
import '../widgets/photo_card.dart';
import '../widgets/progress_header.dart';
import 'profile_screen.dart';

class PhotoQuizScreen extends StatefulWidget {
  const PhotoQuizScreen({super.key});

  @override
  State<PhotoQuizScreen> createState() => _PhotoQuizScreenState();
}

class _PhotoQuizScreenState extends State<PhotoQuizScreen> {
  int _currentIndex = 0;
  int? _selectedOption; // 0 = top (A), 1 = bottom (B)
  final Map<String, double> _scores = {};

  void _select(int option) {
    if (_selectedOption != null) return; // prevent double-tap

    setState(() => _selectedOption = option);

    final question = quizQuestions[_currentIndex];
    final chosen = option == 0 ? question.optionA : question.optionB;

    chosen.tagWeights.forEach((tag, weight) {
      _scores[tag] = (_scores[tag] ?? 0) + weight;
    });

    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      if (_currentIndex < quizQuestions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedOption = null;
        });
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ProfileScreen(quizScores: Map.from(_scores)),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = quizQuestions[_currentIndex];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (_selectedOption != null) return;
            if (details.primaryVelocity == null) return;
            // Swipe up → select top (A), swipe down → select bottom (B)
            if (details.primaryVelocity! < -200) {
              _select(0);
            } else if (details.primaryVelocity! > 200) {
              _select(1);
            }
          },
          child: Column(
            children: [
              const SizedBox(height: 16),
              ProgressHeader(
                current: _currentIndex + 1,
                total: quizQuestions.length,
              ),
              const SizedBox(height: 12),
              Text(
                'Which vibe do you prefer?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap a card or swipe to choose',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: PhotoCard(
                          imageAsset: question.optionA.imageAsset,
                          label: question.optionA.label,
                          isSelected: _selectedOption == 0,
                          onTap: () => _select(0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: PhotoCard(
                          imageAsset: question.optionB.imageAsset,
                          label: question.optionB.label,
                          isSelected: _selectedOption == 1,
                          onTap: () => _select(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}