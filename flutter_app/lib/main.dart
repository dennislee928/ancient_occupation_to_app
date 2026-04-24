import 'package:flutter/material.dart';

import 'features/moirologist_feature.dart';
import 'features/nomenclator_feature.dart';
import 'features/royal_taster_feature.dart';
import 'features/sin_eater_feature.dart';
import 'features/whipping_boy_feature.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AncientOccupationFlutterApp());
}

class AncientOccupationFlutterApp extends StatelessWidget {
  const AncientOccupationFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '專業朋友殺手',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const AncientLabHome(),
    );
  }
}

class AncientLabHome extends StatefulWidget {
  const AncientLabHome({super.key});

  @override
  State<AncientLabHome> createState() => _AncientLabHomeState();
}

class _AncientLabHomeState extends State<AncientLabHome> {
  final features = const [
    _FeatureMeta(
      id: 'whipping-boy',
      shortLabel: 'Whipping Boy',
      kicker: 'Plan 1',
      title: 'Whipping Boy',
      tagline: 'Consensual accountability pacts with partner-bound consequences.',
      summary:
          'A mobile habit pact demo that turns social guilt into follow-through through reversible, agreed partner impact.',
      meta: ['Accountability', 'Precommitment', 'Peer pact'],
      accent: Color(0xFFB4572F),
      child: WhippingBoyFeature(),
    ),
    _FeatureMeta(
      id: 'royal-taster',
      shortLabel: 'Royal Taster',
      kicker: 'Plan 2',
      title: 'Royal Food Taster',
      tagline: 'Stressful messages are intercepted before emotional impact lands.',
      summary:
          'A trusted digital taster screens high-pressure messages, strips away emotional toxins, and forwards only the useful brief.',
      meta: ['Emotional firewall', 'Delegation', 'Safe brief'],
      accent: Color(0xFF2F6A61),
      child: RoyalTasterFeature(),
    ),
    _FeatureMeta(
      id: 'sin-eater',
      shortLabel: 'Sin Eater',
      kicker: 'Plan 3',
      title: 'Sin Eater',
      tagline: 'Read-once confession, ritual consumption, and purge.',
      summary:
          'A private catharsis flow where a trusted witness consumes the burden exactly once before it is irreversibly deleted.',
      meta: ['Catharsis', 'Ritual', 'Ephemeral trust'],
      accent: Color(0xFF7A4D95),
      child: SinEaterFeature(),
    ),
    _FeatureMeta(
      id: 'nomenclator',
      shortLabel: 'Nomenclator',
      kicker: 'Plan 4',
      title: 'Nomenclator',
      tagline: 'Backstage memory prompts for live social recall.',
      summary:
          'A companion-fed watch or AR prompt system for remembering names, context, and safe openers during real encounters.',
      meta: ['Memory support', 'Wearables', 'Companion mode'],
      accent: Color(0xFF26638E),
      child: NomenclatorFeature(),
    ),
    _FeatureMeta(
      id: 'moirologist',
      shortLabel: 'Moirologist',
      kicker: 'Plan 5',
      title: 'Moirologist',
      tagline: 'Instant irrational validation from a trusted squad.',
      summary:
          'A one-tap affirmation rescue where your chosen squad floods the moment with exaggerated support instead of advice.',
      meta: ['Widget logic', 'Affirmation', 'Support squad'],
      accent: Color(0xFFC06A3B),
      child: MoirologistFeature(),
    ),
  ];

  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final active = features[activeIndex];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppTheme.line),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ancient Occupation to App',
                            style: TextStyle(
                              color: AppTheme.accent,
                              fontSize: 12,
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Five speculative mobile products from five forgotten jobs.',
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 34,
                              height: 1.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 14),
                          Text(
                            'This Flutter client gives you a real iOS and Android project for device installs, internal beta distribution, and rapid iteration with friends.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: features.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final feature = features[index];
                          final isActive = index == activeIndex;
                          return ChoiceChip(
                            label: Text(feature.shortLabel),
                            selected: isActive,
                            selectedColor: feature.accent,
                            labelStyle: TextStyle(
                              color: isActive ? Colors.white : AppTheme.ink,
                              fontWeight: FontWeight.w700,
                            ),
                            onSelected: (_) => setState(() => activeIndex = index),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppTheme.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            active.kicker,
                            style: TextStyle(
                              color: active.accent,
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            active.title,
                            style: const TextStyle(
                              color: AppTheme.ink,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(active.tagline),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: active.meta
                                .map((item) => Chip(label: Text(item)))
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          Text(active.summary),
                          const SizedBox(height: 18),
                          active.child,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureMeta {
  const _FeatureMeta({
    required this.id,
    required this.shortLabel,
    required this.kicker,
    required this.title,
    required this.tagline,
    required this.summary,
    required this.meta,
    required this.accent,
    required this.child,
  });

  final String id;
  final String shortLabel;
  final String kicker;
  final String title;
  final String tagline;
  final String summary;
  final List<String> meta;
  final Color accent;
  final Widget child;
}
