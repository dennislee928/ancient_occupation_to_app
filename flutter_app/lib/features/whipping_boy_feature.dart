import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class WhippingBoyFeature extends StatefulWidget {
  const WhippingBoyFeature({super.key});

  @override
  State<WhippingBoyFeature> createState() => _WhippingBoyFeatureState();
}

class _WhippingBoyFeatureState extends State<WhippingBoyFeature> {
  static const goals = [
    ('Morning walk', '5x this week', '20-minute photo check-in before 8:30'),
    ('Language drill', '30 minutes daily', 'Upload one lesson screenshot'),
    ('Hydration target', '2 liters today', 'Log all four water blocks'),
  ];

  static const partners = [
    ('Jo', 'Roommate', 7),
    ('Mei', 'Gym partner', 12),
    ('Ian', 'Sibling', 9),
  ];

  static const consequences = [
    ('Shared badge dims', 'Your partner carries a gray pact badge until tomorrow.', 1),
    ('Partner loses a skip', 'They burn one support token from the streak board.', 2),
    ('Extra follow-up duty', 'They log the miss and send one reminder.', 3),
  ];

  int goalIndex = 0;
  int partnerIndex = 1;
  int consequenceIndex = 1;
  bool consentEnabled = true;
  int streak = 6;
  int misses = 2;
  String lastEvent = 'miss';
  List<bool> history = const [true, true, false, true, true, true, false];

  int get pressureScore {
    final base = 18 +
        misses * 11 +
        consequences[consequenceIndex].$3 * 13 +
        partners[partnerIndex].$3 +
        (lastEvent == 'miss' ? 15 : -8) -
        streak * 3;
    return base.clamp(8, 100);
  }

  String get pressureLabel {
    if (pressureScore < 30) return 'Steady';
    if (pressureScore < 60) return 'Heavy';
    return 'Critical';
  }

  Color get pressureColor {
    if (pressureScore < 30) return AppTheme.success;
    if (pressureScore < 60) return AppTheme.warning;
    return AppTheme.danger;
  }

  int get completionRate =>
      ((history.where((entry) => entry).length / history.length) * 100).round();

  void pushHistory(bool value) {
    setState(() {
      history = [...history.skip(1), value];
    });
  }

  void logComplete() {
    if (!consentEnabled) return;
    setState(() {
      misses = misses > 0 ? misses - 1 : 0;
      streak += 1;
      lastEvent = 'complete';
    });
    pushHistory(true);
  }

  void logMiss() {
    if (!consentEnabled) return;
    setState(() {
      misses += 1;
      streak = 0;
      lastEvent = 'miss';
    });
    pushHistory(false);
  }

  void resetDemo() {
    setState(() {
      goalIndex = 0;
      partnerIndex = 1;
      consequenceIndex = 1;
      consentEnabled = true;
      streak = 6;
      misses = 2;
      lastEvent = 'miss';
      history = const [true, true, false, true, true, true, false];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Safety note',
                style: TextStyle(
                  color: AppTheme.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Only use mild, reversible, explicitly agreed consequences. This is a consent-based accountability pact, not coercion.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Consent lock',
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Switch(
                    value: consentEnabled,
                    onChanged: (value) => setState(() => consentEnabled = value),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionLabel('1. Pick the goal'),
        _OptionList(
          children: goals.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _SelectableTile(
              title: item.$1,
              subtitle: '${item.$2} • ${item.$3}',
              selected: index == goalIndex,
              onTap: () => setState(() => goalIndex = index),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _SectionLabel('2. Bind it to a person'),
        _OptionList(
          children: partners.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _SelectableTile(
              title: item.$1,
              subtitle: '${item.$2} • pressure bonus ${item.$3}',
              selected: index == partnerIndex,
              onTap: () => setState(() => partnerIndex = index),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _SectionLabel('3. Choose the consequence'),
        _OptionList(
          children: consequences.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _SelectableTile(
              title: item.$1,
              subtitle: item.$2,
              selected: index == consequenceIndex,
              onTap: () => setState(() => consequenceIndex = index),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(label: 'Streak', value: '$streak days'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(label: 'Misses', value: '$misses'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(label: 'Hit rate', value: '$completionRate%'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Social pressure: $pressureLabel',
                style: TextStyle(
                  color: pressureColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: pressureScore / 100,
                  minHeight: 10,
                  backgroundColor: AppTheme.cardSoft,
                  color: pressureColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pressureScore < 60
                    ? 'The pact still feels supportive, but a miss will visibly drag your partner into the consequence.'
                    : 'Pressure is high. Recover the pact before your partner pays for your lapse.',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: history
                    .map(
                      (day) => Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: day ? AppTheme.success : AppTheme.danger,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          day ? Icons.check_rounded : Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: logComplete,
                      child: const Text('I checked in'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: logMiss,
                      child: const Text('I missed it'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: resetDemo,
                child: const Text('Reset demo'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.ink,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.line),
      ),
      child: child,
    );
  }
}

class _OptionList extends StatelessWidget {
  const _OptionList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final child in children) ...[
          child,
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3E0D3) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.line,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
