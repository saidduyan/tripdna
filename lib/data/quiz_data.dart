import '../models/quiz_question.dart';

const List<QuizQuestion> quizQuestions = [
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q1a.png',
      label: 'Turquoise beach',
      tagWeights: {
        'beach': 5, 'relax': 4, 'wellness': 3, 'quiet': 3,
        'luxury': 2, 'adventure': 2, 'hidden': 2, 'boutique': 2,
        'mountain': 1, 'city': 1, 'culture': 1, 'nightlife': 1,
        'food_street': 1, 'food_fine': 1, 'landmarks': 1, 'modern': 1,
      },
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q1b.png',
      label: 'Snowy mountain',
      tagWeights: {
        'mountain': 5, 'adventure': 4, 'quiet': 4, 'relax': 3,
        'wellness': 3, 'hidden': 2, 'luxury': 2, 'boutique': 2,
        'beach': 1, 'city': 1, 'culture': 1, 'landmarks': 1,
        'food_street': 1, 'food_fine': 1, 'nightlife': 1, 'modern': 1,
      },
    ),
  ),
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q2a.png',
      label: 'Bustling city',
      tagWeights: {
        'city': 5, 'modern': 4, 'nightlife': 4, 'food_street': 3,
        'food_fine': 3, 'culture': 3, 'landmarks': 2, 'adventure': 2,
        'luxury': 2, 'beach': 1, 'mountain': 1, 'quiet': 1,
        'relax': 1, 'wellness': 1, 'hidden': 1, 'boutique': 1,
      },
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q2b.png',
      label: 'Hidden village',
      tagWeights: {
        'hidden': 5, 'quiet': 5, 'culture': 4, 'boutique': 4,
        'relax': 3, 'wellness': 2, 'food_street': 2, 'adventure': 2,
        'mountain': 2, 'landmarks': 2, 'city': 1, 'modern': 1,
        'nightlife': 1, 'luxury': 1, 'beach': 1, 'food_fine': 1,
      },
    ),
  ),
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q3a.png',
      label: 'Street food market',
      tagWeights: {
        'food_street': 5, 'culture': 4, 'city': 3, 'adventure': 3,
        'hidden': 2, 'nightlife': 2, 'boutique': 2, 'landmarks': 2,
        'relax': 1, 'quiet': 1, 'food_fine': 1, 'modern': 1,
        'luxury': 1, 'wellness': 1, 'beach': 1, 'mountain': 1,
      },
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q3b.png',
      label: 'Fine dining',
      tagWeights: {
        'food_fine': 5, 'luxury': 4, 'boutique': 4, 'modern': 3,
        'city': 3, 'relax': 2, 'wellness': 2, 'nightlife': 2,
        'culture': 2, 'food_street': 1, 'hidden': 1, 'landmarks': 1,
        'quiet': 1, 'beach': 1, 'mountain': 1, 'adventure': 1,
      },
    ),
  ),
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q4a.png',
      label: 'Ancient ruins',
      tagWeights: {
        'landmarks': 5, 'culture': 5, 'hidden': 3, 'adventure': 3,
        'quiet': 3, 'boutique': 2, 'mountain': 2, 'relax': 2,
        'food_street': 2, 'city': 1, 'modern': 1, 'nightlife': 1,
        'luxury': 1, 'wellness': 1, 'beach': 1, 'food_fine': 1,
      },
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q4b.png',
      label: 'Modern skyline',
      tagWeights: {
        'modern': 5, 'city': 5, 'nightlife': 4, 'luxury': 3,
        'food_fine': 3, 'adventure': 2, 'food_street': 2, 'culture': 2,
        'landmarks': 2, 'boutique': 1, 'wellness': 1, 'relax': 1,
        'quiet': 1, 'beach': 1, 'mountain': 1, 'hidden': 1,
      },
    ),
  ),
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q5a.png',
      label: 'Spa retreat',
      tagWeights: {
        'wellness': 5, 'relax': 5, 'luxury': 4, 'boutique': 3,
        'quiet': 3, 'food_fine': 2, 'hidden': 2, 'beach': 2,
        'mountain': 2, 'culture': 1, 'food_street': 1, 'city': 1,
        'modern': 1, 'adventure': 1, 'nightlife': 1, 'landmarks': 1,
      },
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q5b.png',
      label: 'Adventure trek',
      tagWeights: {
        'adventure': 5, 'mountain': 4, 'hidden': 4, 'quiet': 3,
        'relax': 2, 'culture': 2, 'landmarks': 2, 'wellness': 2,
        'food_street': 2, 'beach': 1, 'city': 1, 'modern': 1,
        'luxury': 1, 'boutique': 1, 'nightlife': 1, 'food_fine': 1,
      },
    ),
  ),
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q6a.png',
      label: 'Crowded festival',
      tagWeights: {
        'nightlife': 4, 'culture': 5, 'food_street': 4, 'city': 3,
        'adventure': 3, 'landmarks': 2, 'modern': 2, 'boutique': 2,
        'food_fine': 1, 'relax': 1, 'wellness': 1, 'quiet': 1,
        'luxury': 1, 'hidden': 1, 'beach': 1, 'mountain': 1,
      },
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q6b.png',
      label: 'Quiet sunrise',
      tagWeights: {
        'quiet': 5, 'relax': 5, 'wellness': 4, 'hidden': 3,
        'mountain': 3, 'beach': 3, 'boutique': 2, 'culture': 2,
        'adventure': 2, 'landmarks': 1, 'luxury': 1, 'food_fine': 1,
        'city': 1, 'modern': 1, 'nightlife': 1, 'food_street': 1,
      },
    ),
  ),
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q7a.png',
      label: 'Luxury resort',
      tagWeights: {
        'luxury': 5, 'wellness': 4, 'relax': 4, 'food_fine': 4,
        'boutique': 3, 'beach': 3, 'quiet': 2, 'modern': 2,
        'city': 2, 'culture': 1, 'nightlife': 2, 'landmarks': 1,
        'adventure': 1, 'hidden': 1, 'mountain': 1, 'food_street': 1,
      },
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q7b.png',
      label: 'Budget hostel',
      tagWeights: {
        'hidden': 4, 'food_street': 4, 'adventure': 4, 'culture': 3,
        'city': 3, 'nightlife': 3, 'boutique': 2, 'quiet': 2,
        'relax': 2, 'landmarks': 2, 'mountain': 1, 'beach': 1,
        'modern': 1, 'luxury': 1, 'wellness': 1, 'food_fine': 1,
      },
    ),
  ),
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q8a.png',
      label: 'Tropical jungle',
      tagWeights: {
        'adventure': 5, 'hidden': 4, 'wellness': 3, 'quiet': 3,
        'beach': 3, 'relax': 3, 'mountain': 2, 'culture': 2,
        'food_street': 2, 'boutique': 2, 'luxury': 1, 'landmarks': 1,
        'city': 1, 'modern': 1, 'nightlife': 1, 'food_fine': 1,
      },
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q8b.png',
      label: 'Desert dunes',
      tagWeights: {
        'hidden': 5, 'quiet': 4, 'adventure': 4, 'landmarks': 3,
        'culture': 3, 'relax': 2, 'boutique': 2, 'wellness': 2,
        'mountain': 2, 'food_street': 2, 'luxury': 1, 'beach': 1,
        'city': 1, 'modern': 1, 'nightlife': 1, 'food_fine': 1,
      },
    ),
  ),
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q9a.png',
      label: 'Night clubs',
      tagWeights: {
        'nightlife': 5, 'city': 4, 'modern': 3, 'adventure': 3,
        'food_street': 2, 'food_fine': 2, 'luxury': 2, 'culture': 2,
        'boutique': 1, 'landmarks': 1, 'relax': 1, 'wellness': 1,
        'quiet': 1, 'hidden': 1, 'beach': 1, 'mountain': 1,
      },
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q9b.png',
      label: 'Rooftop bar',
      tagWeights: {
        'city': 4, 'luxury': 4, 'nightlife': 3, 'modern': 4,
        'food_fine': 3, 'boutique': 3, 'relax': 2, 'culture': 2,
        'landmarks': 2, 'wellness': 1, 'adventure': 1, 'hidden': 1,
        'quiet': 1, 'beach': 1, 'mountain': 1, 'food_street': 1,
      },
    ),
  ),
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q10a.png',
      label: 'Local museum',
      tagWeights: {
        'culture': 5, 'landmarks': 5, 'quiet': 3, 'hidden': 3,
        'boutique': 2, 'relax': 2, 'city': 2, 'food_fine': 2,
        'wellness': 1, 'modern': 1, 'adventure': 1, 'food_street': 1,
        'nightlife': 1, 'luxury': 1, 'beach': 1, 'mountain': 1,
      },
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q10b.png',
      label: 'Street art district',
      tagWeights: {
        'city': 4, 'modern': 4, 'culture': 4, 'hidden': 3,
        'adventure': 3, 'food_street': 3, 'nightlife': 2, 'boutique': 2,
        'landmarks': 2, 'relax': 1, 'quiet': 1, 'luxury': 1,
        'wellness': 1, 'food_fine': 1, 'beach': 1, 'mountain': 1,
      },
    ),
  ),
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q11a.png',
      label: 'Island hopping',
      tagWeights: {
        'beach': 5, 'adventure': 4, 'hidden': 3, 'relax': 3,
        'wellness': 2, 'boutique': 2, 'food_street': 2, 'luxury': 2,
        'quiet': 2, 'culture': 2, 'mountain': 1, 'city': 1,
        'modern': 1, 'nightlife': 1, 'food_fine': 1, 'landmarks': 1,
      },
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q11b.png',
      label: 'Mountain cabin',
      tagWeights: {
        'mountain': 5, 'quiet': 5, 'relax': 4, 'wellness': 4,
        'hidden': 3, 'boutique': 3, 'adventure': 2, 'food_fine': 2,
        'culture': 1, 'landmarks': 1, 'luxury': 2, 'city': 1,
        'modern': 1, 'nightlife': 1, 'beach': 1, 'food_street': 1,
      },
    ),
  ),
  QuizQuestion(
    optionA: QuizOption(
      imageAsset: 'assets/images/q12a.png',
      label: 'Iconic landmark',
      tagWeights: {
        'landmarks': 5, 'culture': 4, 'city': 3, 'adventure': 2,
        'modern': 2, 'food_fine': 2, 'food_street': 2, 'luxury': 2,
        'boutique': 2, 'nightlife': 1, 'relax': 1, 'wellness': 1,
        'quiet': 1, 'hidden': 1, 'beach': 1, 'mountain': 1,
      },
    ),
    optionB: QuizOption(
      imageAsset: 'assets/images/q12b.png',
      label: 'Off-the-beaten path',
      tagWeights: {
        'hidden': 5, 'quiet': 4, 'adventure': 4, 'culture': 3,
        'boutique': 3, 'relax': 3, 'wellness': 2, 'mountain': 2,
        'food_street': 2, 'landmarks': 1, 'luxury': 1, 'beach': 1,
        'city': 1, 'modern': 1, 'nightlife': 1, 'food_fine': 1,
      },
    ),
  ),
];