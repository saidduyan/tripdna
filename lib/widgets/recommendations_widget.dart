import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/profile_provider.dart';

class _Recommendation {
  final String flag;
  final String city;
  final String country;
  final String reason;
  final int matchPercent;

  const _Recommendation({
    required this.flag,
    required this.city,
    required this.country,
    required this.reason,
    required this.matchPercent,
  });
}

List<_Recommendation> _generateRecommendations(
    int visitedCount, List<String> tagLabels) {
  // İleride burası backend / AI API'ye bağlanacak
  if (visitedCount >= 5) {
    return const [
      _Recommendation(
        flag: '🇯🇵',
        city: 'Tokyo',
        country: 'Japonya',
        reason: 'Kültür + şehir profilinle eşleşiyor',
        matchPercent: 96,
      ),
      _Recommendation(
        flag: '🇵🇹',
        city: 'Porto',
        country: 'Portekiz',
        reason: 'Avrupa seyahatlerine yakın',
        matchPercent: 91,
      ),
      _Recommendation(
        flag: '🇬🇷',
        city: 'Atina',
        country: 'Yunanistan',
        reason: 'Tarih & sahil kombinasyonu',
        matchPercent: 88,
      ),
    ];
  }
  return const [
    _Recommendation(
      flag: '🇮🇹',
      city: 'Floransa',
      country: 'İtalya',
      reason: 'Kültür DNA\'nla mükemmel uyum',
      matchPercent: 94,
    ),
    _Recommendation(
      flag: '🇪🇸',
      city: 'Barselona',
      country: 'İspanya',
      reason: 'Şehir + sahil kombinasyonu',
      matchPercent: 89,
    ),
  ];
}

class RecommendationsWidget extends StatelessWidget {
  const RecommendationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final recs = _generateRecommendations(
          provider.visitedCount,
          provider.selectedTags.map((t) => t.label).toList(),
        );

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                children: [
                  const Text(
                    'Senin için öneri',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Öneri listesi
              ...recs.asMap().entries.map((entry) {
                final i = entry.key;
                final rec = entry.value;
                return Column(
                  children: [
                    _RecommendationRow(rec: rec),
                    if (i < recs.length - 1)
                      const Divider(
                        height: 1,
                        color: AppColors.border,
                        thickness: 0.5,
                      ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  final _Recommendation rec;

  const _RecommendationRow({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Bayrak
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                rec.flag,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Bilgi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${rec.city}, ${rec.country}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rec.reason,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Yüzde
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '%${rec.matchPercent}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
