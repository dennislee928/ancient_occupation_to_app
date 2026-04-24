import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MoirologistFeature extends StatefulWidget {
  const MoirologistFeature({super.key});

  @override
  State<MoirologistFeature> createState() => _MoirologistFeatureState();
}

class _MoirologistFeatureState extends State<MoirologistFeature> {
  static const setbacks = [
    ('Boss criticism', 'You were unfairly singled out in front of everyone.'),
    ('Interview rejection', 'A room failed to recognize the obvious candidate.'),
    ('Left on read', 'Someone delayed replying to a message they should treasure.'),
    ('Idea got ignored', 'The room simply was not calibrated for genius today.'),
  ];

  static const urgencies = [
    ('Warm blanket', 'Gentle praise and instant emotional cushioning.'),
    ('Loudspeaker', 'Excessive support with volume and zero nuance.'),
    ('Red alert', 'Emergency-level adoration and dramatic witness statements.'),
  ];

  static const supporters = [
    'Auntie Meteor',
    'Cousin Halo',
    'Captain Velvet',
    'Poet Siren',
    'Guard Echo',
  ];

  int setbackIndex = 0;
  int urgencyIndex = 1;
  int activationCount = 1;
  late List<String> burst = _buildBurst();

  List<String> _buildBurst() {
    final setback = setbacks[setbackIndex].$1;
    final urgency = urgencies[urgencyIndex].$1;
    final random = Random(setbackIndex + urgencyIndex + activationCount);
    final lines = [
      'This setback is a clerical error in the official record of your greatness.',
      'Anyone who doubted you has volunteered for the flop museum.',
      'We are not here to analyze. We are here to confirm you were iconic.',
      'Objectivity has been escorted outside until morale stabilizes.',
      'No strategy meeting. Only applause, snacks, and dramatic agreement.',
      'History will describe this as the day excellence was briefly inconvenienced.',
    ];

    return supporters.asMap().entries.map((entry) {
      final line = lines[(entry.key + random.nextInt(lines.length)) % lines.length];
      return '${entry.value}: $line Trigger: $setback. Mode: $urgency.';
    }).toList();
  }

  void trigger() {
    setState(() {
      activationCount += 1;
      burst = _buildBurst();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Panel(
          title: 'Validation-only squad',
          body:
              'This squad offers exaggerated support, not rational advice. The entire point is instant emotional cushioning.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Setback',
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: setbacks.asMap().entries.map((entry) {
            final index = entry.key;
            return ChoiceChip(
              label: Text(entry.value.$1),
              selected: index == setbackIndex,
              onSelected: (_) => setState(() => setbackIndex = index),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Urgency',
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ...urgencies.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => urgencyIndex = index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: urgencyIndex == index ? const Color(0xFFFBE2CC) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: urgencyIndex == index ? AppTheme.warning : AppTheme.line,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(item.$2),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: trigger,
          icon: const Icon(Icons.campaign_outlined),
          label: Text('Trigger squad • call #$activationCount'),
        ),
        const SizedBox(height: 16),
        ...burst.map(
          (message) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Panel(
              title: 'Support burst',
              body: message,
            ),
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.line),
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
          const SizedBox(height: 8),
          Text(body),
        ],
      ),
    );
  }
}
