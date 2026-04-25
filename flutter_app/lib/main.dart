import 'package:flutter/material.dart';

import 'api/app_api_client.dart';
import 'api/app_api_models.dart';
import 'features/moirologist_feature.dart';
import 'features/nomenclator_feature.dart';
import 'features/royal_taster_feature.dart';
import 'features/sin_eater_feature.dart';
import 'features/whipping_boy_feature.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(AncientOccupationFlutterApp(apiClient: AppApiClient.fromEnvironment()));
}

class AncientOccupationFlutterApp extends StatelessWidget {
  const AncientOccupationFlutterApp({
    required this.apiClient,
    super.key,
  });

  final AppApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '專業朋友殺手',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: AncientLabHome(apiClient: apiClient),
    );
  }
}

class AncientLabHome extends StatefulWidget {
  const AncientLabHome({
    required this.apiClient,
    super.key,
  });

  final AppApiClient apiClient;

  @override
  State<AncientLabHome> createState() => _AncientLabHomeState();
}

class _AncientLabHomeState extends State<AncientLabHome> {
  int activeIndex = 0;
  late final Future<AppProfile> _profileFuture;

  List<_FeatureMeta> get features => [
        const _FeatureMeta(
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
        const _FeatureMeta(
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
        const _FeatureMeta(
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
          meta: const ['Memory support', 'Wearables', 'Companion mode'],
          accent: const Color(0xFF26638E),
          child: NomenclatorFeature(apiClient: widget.apiClient),
        ),
        const _FeatureMeta(
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

  @override
  void initState() {
    super.initState();
    _profileFuture = widget.apiClient.getProfile();
  }

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ancient Occupation to App',
                            style: TextStyle(
                              color: AppTheme.accent,
                              fontSize: 12,
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Five speculative mobile products from five forgotten jobs.',
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 34,
                              height: 1.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'This Flutter client gives you a real iOS and Android project for device installs, internal beta distribution, and rapid iteration with friends.',
                          ),
                          const SizedBox(height: 18),
                          _BackendStatusPanel(
                            apiClient: widget.apiClient,
                            profileFuture: _profileFuture,
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

class _BackendStatusPanel extends StatelessWidget {
  const _BackendStatusPanel({
    required this.apiClient,
    required this.profileFuture,
  });

  final AppApiClient apiClient;
  final Future<AppProfile> profileFuture;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Backend status',
            style: TextStyle(
              color: AppTheme.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            apiClient.hasBaseUrl
                ? 'API: ${apiClient.baseUrl} • auth: ${apiClient.authMode}'
                : 'API is not configured. Pass --dart-define=API_BASE_URL=... and either API_DEBUG_USER_ID or API_BEARER_TOKEN.',
          ),
          const SizedBox(height: 10),
          FutureBuilder<AppProfile>(
            future: profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading profile...');
              }
              if (snapshot.hasError) {
                return Text(
                  'Profile unavailable: ${snapshot.error}',
                  style: const TextStyle(color: AppTheme.muted),
                );
              }

              final profile = snapshot.data;
              if (profile == null) {
                return const Text('Profile unavailable.');
              }

              return Text(
                'Signed in as ${profile.displayName ?? profile.userId} • profile id ${profile.id}',
              );
            },
          ),
        ],
      ),
    );
  }
}
