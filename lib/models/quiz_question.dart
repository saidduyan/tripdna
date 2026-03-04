class QuizOption {
  final String imageAsset;
  final String label;
  final Map<String, double> tagWeights;

  const QuizOption({
    required this.imageAsset,
    required this.label,
    required this.tagWeights,
  });
}

class QuizQuestion {
  final QuizOption optionA; // top
  final QuizOption optionB; // bottom

  const QuizQuestion({
    required this.optionA,
    required this.optionB,
  });
}