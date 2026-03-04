import '../models/quiz_question.dart';

const List<QuizQuestion> quizQuestions = [
  // Q1: Beach vs Mountain
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q01_a.png',
      label: 'Turquoise beach',
      tagWeights: {'beach': 2.0, 'relax': 1.0},
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q01_b.png',
      label: 'Snowy mountain',
      tagWeights: {'mountain': 2.0, 'adventure': 1.0},
    ),
  ),
  // Q2: Bustling city vs Hidden village
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q02_a.png',
      label: 'Bustling city',
      tagWeights: {'city': 2.0, 'nightlife': 1.0},
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q02_b.png',
      label: 'Hidden village',
      tagWeights: {'hidden': 2.0, 'quiet': 1.5},
    ),
  ),
  // Q3: Street food market vs Fine dining
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q03_a.png',
      label: 'Street food market',
      tagWeights: {'food_street': 2.5, 'culture': 1.0},
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q03_b.png',
      label: 'Fine dining',
      tagWeights: {'food_fine': 2.5, 'luxury': 1.0},
    ),
  ),
  // Q4: Ancient ruins vs Modern skyline
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q04_a.png',
      label: 'Ancient ruins',
      tagWeights: {'landmarks': 2.0, 'culture': 1.5},
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q04_b.png',
      label: 'Modern skyline',
      tagWeights: {'modern': 2.0, 'city': 1.0},
    ),
  ),
  // Q5: Spa retreat vs Adventure trek
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q05_a.png',
      label: 'Spa retreat',
      tagWeights: {'wellness': 2.5, 'relax': 1.5, 'luxury': 0.5},
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q05_b.png',
      label: 'Adventure trek',
      tagWeights: {'adventure': 2.5, 'mountain': 1.0},
    ),
  ),
  // Q6: Crowded festival vs Quiet sunrise
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q06_a.png',
      label: 'Crowded festival',
      tagWeights: {'nightlife': 1.5, 'culture': 1.5},
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q06_b.png',
      label: 'Quiet sunrise',
      tagWeights: {'quiet': 2.5, 'relax': 1.0},
    ),
  ),
  // Q7: Luxury resort vs Budget hostel
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q07_a.png',
      label: 'Luxury resort',
      tagWeights: {'luxury': 3.0, 'wellness': 0.5},
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q07_b.png',
      label: 'Budget hostel',
      tagWeights: {'hidden': 1.0, 'food_street': 1.0, 'quiet': 0.5},
    ),
  ),
  // Q8: Tropical jungle vs Desert dunes
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q08_a.png',
      label: 'Tropical jungle',
      tagWeights: {'adventure': 1.5, 'beach': 1.0, 'relax': 1.0},
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q08_b.png',
      label: 'Desert dunes',
      tagWeights: {'hidden': 1.5, 'landmarks': 1.0, 'quiet': 1.0},
    ),
  ),
  // Q9: Night clubs vs Rooftop bars
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q09_a.png',
      label: 'Night clubs',
      tagWeights: {'nightlife': 3.0},
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q09_b.png',
      label: 'Rooftop bar',
      tagWeights: {'city': 1.5, 'luxury': 1.0, 'nightlife': 0.5},
    ),
  ),
  // Q10: Local museum vs Street art
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q10_a.png',
      label: 'Local museum',
      tagWeights: {'culture': 2.5, 'landmarks': 1.0},
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q10_b.png',
      label: 'Street art district',
      tagWeights: {'city': 1.5, 'hidden': 1.0, 'modern': 0.5},
    ),
  ),
  // Q11: Island hopping vs Mountain cabin
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q11_a.png',
      label: 'Island hopping',
      tagWeights: {'beach': 2.0, 'adventure': 1.0},
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q11_b.png',
      label: 'Mountain cabin',
      tagWeights: {'mountain': 2.0, 'quiet': 1.5, 'relax': 1.0},
    ),
  ),
  // Q12: Famous landmark vs Off-the-beaten path
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q12_a.png',
      label: 'Iconic landmark',
      tagWeights: {'landmarks': 2.5, 'culture': 1.0},
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q12_b.png',
      label: 'Off-the-beaten path',
      tagWeights: {'hidden': 3.0, 'quiet': 1.0},
    ),
  ),
];