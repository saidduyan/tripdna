import 'package:flutter/material.dart';
import '../models/destination.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Destination destination;
  const DestinationDetailScreen({super.key, required this.destination});

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  int _imageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dest = widget.destination;

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('${dest.name}, ${dest.country}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
            background: dest.imageAssets.isEmpty
                ? Container(
                    color: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.travel_explore,
                        size: 80, color: theme.colorScheme.primary))
                : Stack(children: [
                    PageView.builder(
                      itemCount: dest.imageAssets.length,
                      onPageChanged: (i) => setState(() => _imageIndex = i),
                      itemBuilder: (_, i) => Image.asset(
                        dest.imageAssets[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: theme.colorScheme.primaryContainer,
                          child: Icon(Icons.travel_explore,
                              size: 80, color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                    if (dest.imageAssets.length > 1)
                      Positioned(
                        bottom: 48,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              dest.imageAssets.length,
                              (i) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    width: _imageIndex == i ? 16 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _imageIndex == i
                                          ? Colors.white
                                          : Colors.white54,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  )),
                        ),
                      ),
                  ]),
          ),
        ),
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Continent badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(dest.continent,
                  style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            Text(dest.subtitle,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.attach_money,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(['Budget', 'Mid-range', 'Premium'][dest.budgetLevel],
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              if (dest.shortTripFriendly) ...[
                Icon(Icons.flash_on,
                    size: 16, color: theme.colorScheme.secondary),
                const SizedBox(width: 4),
                Text('Short trip', style: theme.textTheme.bodySmall),
                const SizedBox(width: 12),
              ],
              if (dest.longStayFriendly) ...[
                Icon(Icons.calendar_month,
                    size: 16, color: theme.colorScheme.secondary),
                const SizedBox(width: 4),
                Text('Long stay', style: theme.textTheme.bodySmall),
              ],
            ]),
            const SizedBox(height: 24),

            // Amenities checklist
            Text('Traveller Checklist',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._amenityRows(dest, theme),

            const SizedBox(height: 24),
            // Top tags
            Text('Vibe Tags',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (dest.tagAffinities.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value)))
                  .take(8)
                  .map((e) => Chip(
                        label: Text(
                            '${e.key.replaceAll('_', ' ')} ·${e.value.toInt()}',
                            style: const TextStyle(fontSize: 12)),
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        side:
                            BorderSide(color: theme.colorScheme.outlineVariant),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),
            // Mini itinerary
            Text('Sample 3-Day Idea',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._itinerary(dest.name).asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle),
                          child: Center(
                              child: Text('${e.key + 1}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(e.value,
                                style: theme.textTheme.bodyMedium)),
                      ]),
                )),
            const SizedBox(height: 32),
          ]),
        )),
      ]),
    );
  }

  List<Widget> _amenityRows(Destination dest, ThemeData theme) {
    final labels = {
      'atm': 'ATM availability',
      'currencyExchange': 'Currency exchange office',
      'fiveStarHotels': '5-star hotels',
      'publicTransport': 'Public transport',
      'englishFriendly': 'English-friendly',
      'uberAvailable': 'Uber / ride-sharing',
    };
    return labels.entries.map((e) {
      final available = dest.amenities[e.key] ?? false;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Icon(available ? Icons.check_circle : Icons.cancel,
              color: available ? Colors.green : Colors.red, size: 22),
          const SizedBox(width: 12),
          Text(e.value, style: theme.textTheme.bodyMedium),
        ]),
      );
    }).toList();
  }

  List<String> _itinerary(String destName) {
    final defaults = [
      'Day 1 — Arrive, explore the neighbourhood & try local street food',
      'Day 2 — Visit top landmarks, museums or natural highlights',
      'Day 3 — Off-the-beaten-path exploration, markets & farewell dinner',
    ];
    final custom = <String, List<String>>{
      'Tokyo': [
        'Day 1 — Shibuya crossing, Harajuku & ramen dinner',
        'Day 2 — Senso-ji temple, TeamLab & sushi',
        'Day 3 — Shinjuku gardens, Akihabara & yakitori'
      ],
      'Bali': [
        'Day 1 — Arrive Ubud, rice terrace walk & sunset temple',
        'Day 2 — Sacred Monkey Forest, spa & traditional dance',
        'Day 3 — Tanah Lot & Seminyak beach'
      ],
      'Barcelona': [
        'Day 1 — La Sagrada Família, La Rambla & tapas bar hop',
        'Day 2 — Park Güell, Gothic Quarter & sunset at Barceloneta',
        'Day 3 — Montjuïc, El Born market & flamenco night'
      ],
    };
    return custom[destName] ?? defaults;
  }
}
