import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RoyalTasterFeature extends StatefulWidget {
  const RoyalTasterFeature({super.key});

  @override
  State<RoyalTasterFeature> createState() => _RoyalTasterFeatureState();
}

class _RoyalTasterFeatureState extends State<RoyalTasterFeature> {
  static const samples = {
    'Manager':
        'Why are you ignoring this? I need the revised deck, budget numbers, and client reply before 9 AM tomorrow. This delay makes us look incompetent, and if you miss it again I will escalate it to leadership immediately.',
    'Ex':
        'You still have my cat carrier and I need it back tonight. Stop being impossible. If you keep dodging me I will tell everyone how selfish you have been. Reply in the next hour and confirm where I can pick it up.',
    'Family':
        'Call me back right now. The clinic needs your insurance photo and confirmation for Friday\'s appointment. I am already stressed enough, so please do not make this harder than it has to be.',
  };

  final controller = TextEditingController(text: samples.values.first);
  String stage = 'intercepted';

  static const urgentPhrases = [
    'right now',
    'immediately',
    'tonight',
    'next hour',
    'before',
    '9 am',
  ];
  static const toxicPhrases = [
    'selfish',
    'impossible',
    'incompetent',
    'ignoring',
    'dodging',
  ];
  static const threatPhrases = [
    'i will escalate',
    'i will tell everyone',
    'if you miss it again',
    'if you keep',
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<String> _hits(List<String> phrases, String lower) {
    return phrases.where(lower.contains).toList();
  }

  List<String> _actions(String text) {
    final lower = text.toLowerCase();
    final items = <String>[];
    if (lower.contains('deck') || lower.contains('budget')) {
      items.add('Prepare the revised deck and budget numbers.');
    }
    if (lower.contains('client')) {
      items.add('Send or draft the client reply.');
    }
    if (lower.contains('cat carrier')) {
      items.add('Arrange the cat carrier handoff.');
    }
    if (lower.contains('insurance')) {
      items.add('Send the insurance photo.');
    }
    if (lower.contains('appointment') || lower.contains('friday')) {
      items.add('Confirm the appointment timing.');
    }
    if (lower.contains('call me back') || lower.contains('reply')) {
      items.add('Send a reply or return the call.');
    }
    if (items.isEmpty) {
      items.add('No concrete task found. Treat as emotional spillover.');
    }
    return items.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final text = controller.text.trim();
    final lower = text.toLowerCase();
    final urgentHits = _hits(urgentPhrases, lower);
    final toxicHits = _hits(toxicPhrases, lower);
    final threatHits = _hits(threatPhrases, lower);

    final urgency = (urgentHits.length * 18).clamp(6, 96);
    final emotionalHeat = (toxicHits.length * 26 + threatHits.length * 12)
        .clamp(8, 97);
    final manipulation = (threatHits.length * 34 + toxicHits.length * 12).clamp(
      6,
      94,
    );
    final score = (urgency + emotionalHeat + manipulation) ~/ 3;

    String label = 'Composed';
    if (score >= 70) {
      label = 'Corrosive';
    } else if (score >= 48) {
      label = 'High Pressure';
    } else if (score >= 28) {
      label = 'Guarded';
    }

    final safeBrief = text.isEmpty
        ? 'No message intercepted yet.'
        : 'The sender is asking for concrete follow-up while using emotional pressure. Deliver only the actionable task list and keep the threatening tone out of the recipient view.';

    final actions = _actions(text);
    final highlights = {...urgentHits, ...toxicHits, ...threatHits}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _InfoPanel(
          title: 'Digital emotional firewall',
          body:
              'A trusted taster screens the message first, strips away emotional poison, and forwards only the usable brief.',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: samples.entries.map((entry) {
            return ChoiceChip(
              label: Text(entry.key),
              selected: controller.text == entry.value,
              onSelected: (_) {
                setState(() {
                  controller.text = entry.value;
                  stage = 'intercepted';
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          minLines: 5,
          maxLines: 8,
          onChanged: (_) => setState(() => stage = 'intercepted'),
          decoration: const InputDecoration(
            labelText: 'Stressful message',
            hintText: 'Paste the raw message here...',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => setState(() => stage = 'reviewed'),
                child: const Text('Taster reviews'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: stage == 'reviewed'
                    ? () => setState(() => stage = 'delivered')
                    : null,
                child: const Text('Deliver safe brief'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StageChip(
                label: 'Intercepted',
                active: true,
                complete: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StageChip(
                label: 'Reviewed',
                active: stage != 'intercepted',
                complete: stage != 'intercepted',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StageChip(
                label: 'Delivered',
                active: stage == 'delivered',
                complete: stage == 'delivered',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(label: 'Heat', value: '$emotionalHeat'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(label: 'Urgency', value: '$urgency'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(label: 'Manipulation', value: '$manipulation'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoPanel(title: 'Pressure verdict: $label', body: safeBrief),
        const SizedBox(height: 16),
        if (highlights.isNotEmpty) ...[
          const Text(
            'Filtered trigger signals',
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
            children: highlights
                .map(
                  (item) => Chip(
                    label: Text(item),
                    backgroundColor: AppTheme.cardSoft,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
        const Text(
          'Action items',
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ...actions.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ListItem(text: item),
          ),
        ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
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

class _StageChip extends StatelessWidget {
  const _StageChip({
    required this.label,
    required this.active,
    required this.complete,
  });

  final String label;
  final bool active;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final bg = complete ? const Color(0xFFE6F4EF) : AppTheme.cardSoft;
    final fg = active || complete ? AppTheme.ink : AppTheme.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

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
              fontSize: 18,
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

class _ListItem extends StatelessWidget {
  const _ListItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
      ),
      child: Text(text),
    );
  }
}
