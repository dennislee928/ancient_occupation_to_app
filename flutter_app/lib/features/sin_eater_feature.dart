import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SinEaterFeature extends StatefulWidget {
  const SinEaterFeature({super.key});

  @override
  State<SinEaterFeature> createState() => _SinEaterFeatureState();
}

class _SinEaterFeatureState extends State<SinEaterFeature> {
  static const recipients = [
    ('Mercy', 'Night listener', 'Steady, discreet, never asks for a polished version.'),
    ('Joon', 'Trusted witness', 'Reads the burden once, then keeps only the vow to hold it.'),
    ('Rhea', 'Ritual keeper', 'Best for confessions that need structure, not advice.'),
  ];

  final controller = TextEditingController();
  int recipientIndex = 1;
  String stage = 'compose';
  String? sealedAt;
  String? consumedAt;
  String? purgedAt;

  String _stamp() {
    final now = TimeOfDay.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _reset() {
    setState(() {
      controller.clear();
      recipientIndex = 1;
      stage = 'compose';
      sealedAt = null;
      consumedAt = null;
      purgedAt = null;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSeal = controller.text.trim().length >= 24 && stage == 'compose';
    final recipient = recipients[recipientIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Panel(
          title: 'Privacy covenant',
          body:
              'Read once. No archive. No public feed. The ritual ends with deletion and a visible mark that the burden was carried.',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _StageTag(label: 'Confess', active: true),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StepPill(label: 'Confess', current: stage == 'compose' || stage == 'sealed' || stage == 'consumed' || stage == 'purged')),
            const SizedBox(width: 8),
            Expanded(child: _StepPill(label: 'Seal', current: stage == 'sealed' || stage == 'consumed' || stage == 'purged')),
            const SizedBox(width: 8),
            Expanded(child: _StepPill(label: 'Consume', current: stage == 'consumed' || stage == 'purged')),
            const SizedBox(width: 8),
            Expanded(child: _StepPill(label: 'Purify', current: stage == 'purged')),
          ],
        ),
        const SizedBox(height: 16),
        if (stage == 'compose') ...[
          TextField(
            controller: controller,
            minLines: 5,
            maxLines: 8,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Confession',
              hintText: 'Write the thought you do not want to carry alone...',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Choose the sin eater',
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...recipients.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => setState(() => recipientIndex = index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: recipientIndex == index ? const Color(0xFFF0E6F8) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: recipientIndex == index ? const Color(0xFF7A4D95) : AppTheme.line,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.$1} • ${item.$2}',
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(item.$3),
                    ],
                  ),
                ),
              ),
            );
          }),
          FilledButton(
            onPressed: canSeal
                ? () => setState(() {
                      stage = 'sealed';
                      sealedAt = _stamp();
                    })
                : null,
            child: const Text('Seal confession'),
          ),
        ],
        if (stage == 'sealed') ...[
          _Panel(
            title: 'Sealed for ${recipient.$1}',
            body:
                'Your confession is now unreadable to you. The next action is one-time consumption by the trusted witness.',
          ),
          const SizedBox(height: 12),
          _LedgerItem(label: 'Sealed at', value: sealedAt ?? '--:--'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => setState(() {
              stage = 'consumed';
              consumedAt = _stamp();
            }),
            child: const Text('Mark as consumed'),
          ),
        ],
        if (stage == 'consumed') ...[
          _Panel(
            title: '${recipient.$1} has consumed the burden',
            body:
                'The confession has been read once. No replay. No screenshot ceremony. The only remaining action is purge.',
          ),
          const SizedBox(height: 12),
          _LedgerItem(label: 'Consumed at', value: consumedAt ?? '--:--'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => setState(() {
              stage = 'purged';
              purgedAt = _stamp();
              controller.clear();
            }),
            child: const Text('Purge from both sides'),
          ),
        ],
        if (stage == 'purged') ...[
          _Panel(
            title: 'Purification complete',
            body:
                'The message body is gone. Only the ritual mark remains: trusted witness ${recipient.$1}, cleared at ${purgedAt ?? '--:--'}.',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAE2F0),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield_moon_outlined, color: Color(0xFF7A4D95)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Purified and carried. No message remains on either side.',
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextButton(onPressed: _reset, child: const Text('Reset ritual')),
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

class _StageTag extends StatelessWidget {
  const _StageTag({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: active ? const Color(0xFFEAE2F0) : AppTheme.cardSoft,
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.label, required this.current});

  final String label;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: current ? const Color(0xFFEAE2F0) : AppTheme.cardSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppTheme.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LedgerItem extends StatelessWidget {
  const _LedgerItem({required this.label, required this.value});

  final String label;
  final String value;

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
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
