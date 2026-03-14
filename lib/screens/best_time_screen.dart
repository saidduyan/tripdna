import 'package:flutter/material.dart';
import '../models/travel_timing.dart';
import '../data/travel_timing_data.dart';

class BestTimeScreen extends StatefulWidget {
  final String? initialDestination;
  const BestTimeScreen({super.key, this.initialDestination});

  @override
  State<BestTimeScreen> createState() => _BestTimeScreenState();
}

class _BestTimeScreenState extends State<BestTimeScreen> {
  String? _selected;
  TravelTiming? _timing;

  @override
  void initState() {
    super.initState();
    if (widget.initialDestination != null) {
      _selected = widget.initialDestination;
      _timing = getTimingFor(widget.initialDestination!);
    }
  }

  void _onSelect(String name) {
    setState(() {
      _selected = name;
      _timing = getTimingFor(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Best Time to Visit',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(children: [
        Container(
          color: theme.colorScheme.surfaceVariant,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: DropdownButtonFormField<String>(
            value: _selected,
            decoration: InputDecoration(
              labelText: 'Select a destination',
              prefixIcon: const Icon(Icons.place_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            items: travelTimingData
                .map((t) => DropdownMenuItem(
                      value: t.destinationName,
                      child: Text(t.destinationName),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) _onSelect(v);
            },
          ),
        ),
        Expanded(
          child: _timing == null
              ? _buildPlaceholder(theme)
              : _buildContent(theme, _timing!),
        ),
      ]),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.calendar_month_outlined,
            size: 72, color: theme.colorScheme.outline),
        const SizedBox(height: 16),
        Text('Select a destination',
            style: theme.textTheme.titleLarge
                ?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 8),
        Text('We\'ll show you the best time to visit',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline)),
      ]),
    );
  }

  Widget _buildContent(ThemeData theme, TravelTiming t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Sweet spot banner
        if (t.sweetSpotMonths.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Ideal Period',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ]),
                  const SizedBox(height: 6),
                  Text(t.sweetSpotMonths.join(' · '),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Good weather + reasonable price balance',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13)),
                ]),
          ),

        const SizedBox(height: 20),

        // Monthly chart
        Text('Monthly Overview',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Price · Weather · Crowd',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 12),
        _MonthlyChart(months: t.months, theme: theme),

        const SizedBox(height: 24),

        // Summary cards
        Row(children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.savings_outlined,
              label: 'Cheapest',
              value: t.cheapMonths.isEmpty
                  ? 'No data'
                  : t.cheapMonths.join(', '),
              color: Colors.green,
              theme: theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              icon: Icons.attach_money,
              label: 'Most Expensive',
              value: t.expensiveMonths.isEmpty
                  ? 'No data'
                  : t.expensiveMonths.join(', '),
              color: Colors.red,
              theme: theme,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.people_outline,
              label: 'Most Crowded',
              value: t.popularMonths.isEmpty
                  ? 'No data'
                  : t.popularMonths.join(', '),
              color: Colors.orange,
              theme: theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              icon: Icons.star_outline,
              label: 'Sweet Spot',
              value: t.sweetSpotMonths.isEmpty
                  ? 'No data'
                  : t.sweetSpotMonths.join(', '),
              color: theme.colorScheme.primary,
              theme: theme,
            ),
          ),
        ]),

        const SizedBox(height: 20),

        // Tip card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.lightbulb_outline,
                color: theme.colorScheme.secondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Local Tip',
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondaryContainer)),
                    const SizedBox(height: 6),
                    Text(t.tip,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer)),
                  ]),
            ),
          ]),
        ),

        const SizedBox(height: 20),

        // Month detail list
        Text('Month by Month',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...t.months.map((m) => _MonthDetailRow(month: m, theme: theme)),

        const SizedBox(height: 32),
      ]),
    );
  }
}

// ── Monthly bar chart ──────────────────────────────────────────────────────

class _MonthlyChart extends StatefulWidget {
  final List<MonthData> months;
  final ThemeData theme;
  const _MonthlyChart({required this.months, required this.theme});

  @override
  State<_MonthlyChart> createState() => _MonthlyChartState();
}

class _MonthlyChartState extends State<_MonthlyChart> {
  int _mode = 0; // 0=price, 1=weather, 2=crowd

  Color _barColor(int index, int mode) {
    if (mode == 0) {
      return Color.lerp(Colors.green, Colors.red, (index - 1) / 4)!;
    } else if (mode == 1) {
      return Color.lerp(Colors.grey, Colors.blue, (index - 1) / 4)!;
    } else {
      return Color.lerp(Colors.green, Colors.orange, (index - 1) / 4)!;
    }
  }

  int _getValue(MonthData m, int mode) {
    if (mode == 0) return m.priceIndex;
    if (mode == 1) return m.weatherScore;
    return m.crowdIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SegmentedButton<int>(
        segments: const [
          ButtonSegment(
              value: 0,
              label: Text('Price'),
              icon: Icon(Icons.attach_money, size: 16)),
          ButtonSegment(
              value: 1,
              label: Text('Weather'),
              icon: Icon(Icons.wb_sunny, size: 16)),
          ButtonSegment(
              value: 2,
              label: Text('Crowd'),
              icon: Icon(Icons.people, size: 16)),
        ],
        selected: {_mode},
        onSelectionChanged: (s) => setState(() => _mode = s.first),
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: widget.months.map((m) {
            final val = _getValue(m, _mode);
            final barH = (val / 5) * 100;
            final color = _barColor(val, _mode);
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    height: barH,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(m.month,
                      style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (_mode == 0) ...[
          _LegendDot(color: Colors.green, label: 'Cheap'),
          const SizedBox(width: 16),
          _LegendDot(color: Colors.red, label: 'Expensive'),
        ] else if (_mode == 1) ...[
          _LegendDot(color: Colors.grey, label: 'Poor'),
          const SizedBox(width: 16),
          _LegendDot(color: Colors.blue, label: 'Great'),
        ] else ...[
          _LegendDot(color: Colors.green, label: 'Quiet'),
          const SizedBox(width: 16),
          _LegendDot(color: Colors.orange, label: 'Crowded'),
        ],
      ]),
    ]);
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ]);
}

// ── Summary card ───────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ]),
          const SizedBox(height: 6),
          Text(value,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ]),
      );
}

// ── Month detail row ───────────────────────────────────────────────────────

class _MonthDetailRow extends StatelessWidget {
  final MonthData month;
  final ThemeData theme;
  const _MonthDetailRow({required this.month, required this.theme});

  Widget _dots(int value, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
          (i) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < value
                  ? color
                  : color.withValues(alpha: 0.15),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          SizedBox(
              width: 32,
              child: Text(month.month,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13))),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(month.weatherDesc,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline)),
                  const SizedBox(height: 4),
                  Row(children: [
                    _dots(month.priceIndex, Colors.red),
                    const SizedBox(width: 8),
                    Text('\$',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.red.shade300)),
                    const SizedBox(width: 12),
                    _dots(month.weatherScore, Colors.blue),
                    const SizedBox(width: 8),
                    Icon(Icons.wb_sunny,
                        size: 10, color: Colors.blue.shade300),
                    const SizedBox(width: 12),
                    _dots(month.crowdIndex, Colors.orange),
                    const SizedBox(width: 8),
                    Icon(Icons.people,
                        size: 10, color: Colors.orange.shade300),
                  ]),
                ]),
          ),
        ]),
      );
}