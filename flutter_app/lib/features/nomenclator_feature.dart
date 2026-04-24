import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NomenclatorFeature extends StatefulWidget {
  const NomenclatorFeature({super.key});

  @override
  State<NomenclatorFeature> createState() => _NomenclatorFeatureState();
}

class _NomenclatorFeatureState extends State<NomenclatorFeature> {
  final people = [
    _Person(
      name: 'Victor Chen',
      role: 'Procurement lead at Helios Display',
      lastSeen: 'Seen 7 months ago at Taipei Smart Venue Expo',
      cue: 'Tall, rimless glasses, usually carries a navy tote.',
      opener: 'Ask whether the Taichung pilot stores kept queue times down.',
      followUp: 'Congratulate him on the golden retriever he adopted.',
      contexts: const [
        _ContextCue(
          label: 'Expo floor',
          goal: 'Reconnect fast and earn a follow-up meeting.',
          prompt: 'Lead with the Taichung pilot and one concrete result.',
        ),
        _ContextCue(
          label: 'Coffee line',
          goal: 'Sound personal without overloading him.',
          prompt: 'Mention the dog first, then pivot into rollout timing.',
        ),
      ],
      feed: const [
        'This is Victor from Helios. Last spoke about self-checkout pilots.',
        'Safe personal opener: ask about Bao the golden retriever.',
        'Avoid leading with discounts. Use uptime and support instead.',
      ],
    ),
    _Person(
      name: 'Amelia Wong',
      role: 'Nonprofit fundraiser and museum trustee',
      lastSeen: 'Seen 5 weeks ago at the heritage dinner',
      cue: 'Short silver earrings, velvet blazer, warm laugh.',
      opener: 'Ask whether the youth conservation workshop sold out again.',
      followUp: 'She mentioned her daughter was applying to architecture programs.',
      contexts: const [
        _ContextCue(
          label: 'Benefit reception',
          goal: 'Show you remembered the mission, not just the name.',
          prompt: 'Open on the workshop impact and ask one sincere question.',
        ),
        _ContextCue(
          label: 'Exit lobby',
          goal: 'Land a considerate follow-up message.',
          prompt: 'Wish her daughter luck and ask if an introduction would help.',
        ),
      ],
      feed: const [
        'You spoke about preserving old storefront signs and neighborhood memory.',
        'She lights up when discussing the youth conservation workshop.',
        'Family cue: daughter applying to architecture schools.',
      ],
    ),
    _Person(
      name: 'Daniel Kim',
      role: 'Product designer turned startup advisor',
      lastSeen: 'Seen 3 days ago on a founder breakfast panel',
      cue: 'Usually in monochrome layers, analog watch, gentle voice.',
      opener: 'Thank him for the wearable intros and ask about the studio move.',
      followUp: 'He moved his studio near Songshan Cultural Park.',
      contexts: const [
        _ContextCue(
          label: 'Green room',
          goal: 'Be useful and brief.',
          prompt: 'Lead with gratitude for the intros, then one precise update.',
        ),
        _ContextCue(
          label: 'Street walk',
          goal: 'Make the studio move the center of the exchange.',
          prompt: 'Ask about the move first and keep startup talk second.',
        ),
      ],
      feed: const [
        'Daniel respects concise thank-yous and specific asks.',
        'Ask for critique, not validation.',
        'Personal cue: recent studio move near Songshan Cultural Park.',
      ],
    ),
  ];

  int personIndex = 0;
  int contextIndex = 0;
  int promptIndex = 0;

  @override
  Widget build(BuildContext context) {
    final person = people[personIndex];
    final contextCue = person.contexts[contextIndex];
    final prompt = person.feed[promptIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _InfoPanel(
          title: 'Companion memory support',
          body:
              'Your backstage partner feeds discreet cues to a watch or AR layer so you can recover names, context, and safe openers in real time.',
        ),
        const SizedBox(height: 16),
        const Text(
          'People',
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ...people.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() {
                personIndex = index;
                contextIndex = 0;
                promptIndex = 0;
              }),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: personIndex == index ? const Color(0xFFE2EEF7) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: personIndex == index ? const Color(0xFF26638E) : AppTheme.line,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(item.role),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        _InfoPanel(
          title: person.name,
          body:
              '${person.lastSeen}\nRecognition cue: ${person.cue}\nSafe opener: ${person.opener}\nFollow-up: ${person.followUp}',
        ),
        const SizedBox(height: 16),
        const Text(
          'Encounter context',
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
          children: person.contexts.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return ChoiceChip(
              label: Text(item.label),
              selected: index == contextIndex,
              onSelected: (_) => setState(() => contextIndex = index),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _InfoPanel(
          title: contextCue.goal,
          body: 'Backstage prompt: ${contextCue.prompt}',
        ),
        const SizedBox(height: 16),
        const Text(
          'Companion feed',
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ...person.feed.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final selected = index == promptIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => promptIndex = index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFE2EEF7) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? const Color(0xFF26638E) : AppTheme.line,
                  ),
                ),
                child: Text(item),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF18384A),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Watch / AR prompt preview',
                style: TextStyle(
                  color: Color(0xFFA9D0EA),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                prompt,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Person {
  const _Person({
    required this.name,
    required this.role,
    required this.lastSeen,
    required this.cue,
    required this.opener,
    required this.followUp,
    required this.contexts,
    required this.feed,
  });

  final String name;
  final String role;
  final String lastSeen;
  final String cue;
  final String opener;
  final String followUp;
  final List<_ContextCue> contexts;
  final List<String> feed;
}

class _ContextCue {
  const _ContextCue({
    required this.label,
    required this.goal,
    required this.prompt,
  });

  final String label;
  final String goal;
  final String prompt;
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
