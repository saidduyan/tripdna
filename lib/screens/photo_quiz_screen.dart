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
  int? _selectedOption;
  final Map<String, double> _scores = {};
  // History for undo: list of tag-weight maps that were applied
  final List<Map<String, double>> _history = [];

  void _select(int option) {
    if (_selectedOption != null) return;
    setState(() => _selectedOption = option);

    final question = quizQuestions[_currentIndex];
    final chosen = option == 0 ? question.optionA : question.optionB;

    // Apply weights
    chosen.tagWeights.forEach((tag, weight) {
      _scores[tag] = (_scores[tag] ?? 0) + weight;
    });
    // Save to history for undo
    _history.add(Map<String, double>.from(chosen.tagWeights));

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      if (_currentIndex < quizQuestions.length - 1) {
        setState(() { _currentIndex++; _selectedOption = null; });
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProfileScreen(quizScores: Map.from(_scores))),
        );
      }
    });
  }

  void _undo() {
    if (_currentIndex == 0 && _history.isEmpty) {
      _confirmExit();
      return;
    }
    if (_history.isEmpty) return;
    final last = _history.removeLast();
    last.forEach((tag, weight) {
      _scores[tag] = (_scores[tag] ?? 0) - weight;
      if ((_scores[tag] ?? 0) <= 0) _scores.remove(tag);
    });
    setState(() { _currentIndex--; _selectedOption = null; });
  }

  Future<void> _confirmExit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Exit')),
        ],
      ),
    );
    if (confirmed == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = quizQuestions[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (_currentIndex > 0) { _undo(); } else { _confirmExit(); }
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (_selectedOption != null) return;
              if ((details.primaryVelocity ?? 0) < -200) _select(0);
              else if ((details.primaryVelocity ?? 0) > 200) _select(1);
            },
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: _currentIndex > 0 ? _undo : _confirmExit,
                        tooltip: _currentIndex > 0 ? 'Undo' : 'Exit',
                      ),
                      Expanded(child: ProgressHeader(current: _currentIndex + 1, total: quizQuestions.length)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('Which vibe do you prefer?',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Tap or swipe to choose',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Expanded(child: PhotoCard(
                          imageAsset: question.optionA.imageAsset,
                          label: question.optionA.label,
                          isSelected: _selectedOption == 0,
                          onTap: () => _select(0),
                        )),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('OR', style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold, fontSize: 12,
                          )),
                        ),
                        const SizedBox(height: 8),
                        Expanded(child: PhotoCard(
                          imageAsset: question.optionB.imageAsset,
                          label: question.optionB.label,
                          isSelected: _selectedOption == 1,
                          onTap: () => _select(1),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}