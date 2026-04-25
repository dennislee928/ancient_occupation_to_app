import 'package:flutter/material.dart';

import '../api/app_api_client.dart';
import '../api/app_api_models.dart';
import '../theme/app_theme.dart';

class NomenclatorFeature extends StatefulWidget {
  const NomenclatorFeature({required this.apiClient, super.key});

  final AppApiClient apiClient;

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
      followUp:
          'She mentioned her daughter was applying to architecture programs.',
      contexts: const [
        _ContextCue(
          label: 'Benefit reception',
          goal: 'Show you remembered the mission, not just the name.',
          prompt: 'Open on the workshop impact and ask one sincere question.',
        ),
        _ContextCue(
          label: 'Exit lobby',
          goal: 'Land a considerate follow-up message.',
          prompt:
              'Wish her daughter luck and ask if an introduction would help.',
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
      opener:
          'Thank him for the wearable intros and ask about the studio move.',
      followUp: 'He moved his studio near Songshan Cultural Park.',
      contexts: const [
        _ContextCue(
          label: 'Green room',
          goal: 'Be useful and brief.',
          prompt:
              'Lead with gratitude for the intros, then one precise update.',
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

  final _nameController = TextEditingController();
  final _affiliationController = TextEditingController();
  final _notesController = TextEditingController();
  final _contextController = TextEditingController();
  final _companionController = TextEditingController();
  final _promptController = TextEditingController();

  int personIndex = 0;
  int contextIndex = 0;
  int promptIndex = 0;
  int backendSelectionIndex = 0;
  bool isLoadingBackend = false;
  bool isCreatingPerson = false;
  bool isCreatingSession = false;
  bool isSendingPrompt = false;
  String? backendError;
  String deliveryMode = 'quiet';
  List<NomenclatorPersonCard> backendPeople = const [];
  NomenclatorSession? activeSession;

  @override
  void initState() {
    super.initState();
    _loadBackendPeople();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _affiliationController.dispose();
    _notesController.dispose();
    _contextController.dispose();
    _companionController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _loadBackendPeople() async {
    if (!widget.apiClient.isConfigured) {
      return;
    }

    setState(() {
      isLoadingBackend = true;
      backendError = null;
    });

    try {
      final people = await widget.apiClient.listPeopleCards();
      if (!mounted) {
        return;
      }
      setState(() {
        backendPeople = people;
        if (backendSelectionIndex >= people.length) {
          backendSelectionIndex = people.isEmpty ? 0 : people.length - 1;
        }
      });
    } on AppApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => backendError = error.message);
    } finally {
      if (mounted) {
        setState(() => isLoadingBackend = false);
      }
    }
  }

  Future<void> _createPersonCard() async {
    if (isCreatingPerson) {
      return;
    }

    setState(() {
      isCreatingPerson = true;
      backendError = null;
    });

    try {
      final person = await widget.apiClient.createPersonCard(
        name: _nameController.text,
        affiliation: _affiliationController.text,
        notes: _notesController.text,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        backendPeople = [person, ...backendPeople];
        backendSelectionIndex = 0;
        _nameController.clear();
        _affiliationController.clear();
        _notesController.clear();
      });
    } on AppApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => backendError = error.message);
    } finally {
      if (mounted) {
        setState(() => isCreatingPerson = false);
      }
    }
  }

  Future<void> _createSession() async {
    if (isCreatingSession || backendPeople.isEmpty) {
      return;
    }

    final selected = backendPeople[backendSelectionIndex];

    setState(() {
      isCreatingSession = true;
      backendError = null;
    });

    try {
      final session = await widget.apiClient.createSession(
        personCardId: selected.id,
        contextLabel: _contextController.text,
        companionUserId: _companionController.text,
      );
      if (!mounted) {
        return;
      }
      setState(() => activeSession = session);
      await _refreshActiveSession();
    } on AppApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => backendError = error.message);
    } finally {
      if (mounted) {
        setState(() => isCreatingSession = false);
      }
    }
  }

  Future<void> _refreshActiveSession() async {
    final session = activeSession;
    if (session == null) {
      return;
    }

    try {
      final latest = await widget.apiClient.getSession(session.id);
      if (!mounted) {
        return;
      }
      setState(() => activeSession = latest);
    } on AppApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => backendError = error.message);
    }
  }

  Future<void> _sendPrompt() async {
    final session = activeSession;
    if (isSendingPrompt || session == null) {
      return;
    }

    setState(() {
      isSendingPrompt = true;
      backendError = null;
    });

    try {
      await widget.apiClient.createPrompt(
        sessionId: session.id,
        body: _promptController.text,
        deliveryMode: deliveryMode,
      );
      _promptController.clear();
      await _refreshActiveSession();
    } on AppApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => backendError = error.message);
    } finally {
      if (mounted) {
        setState(() => isSendingPrompt = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final person = people[personIndex];
    final contextCue = person.contexts[contextIndex];
    final prompt = person.feed[promptIndex];
    final selectedBackendPerson = backendPeople.isEmpty
        ? null
        : backendPeople[backendSelectionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _InfoPanel(
          title: 'Companion memory support',
          body:
              'Your backstage partner feeds discreet cues to a watch or AR layer so you can recover names, context, and safe openers in real time.',
        ),
        const SizedBox(height: 16),
        _BackendSyncPanel(
          apiClient: widget.apiClient,
          isLoadingBackend: isLoadingBackend,
          isCreatingPerson: isCreatingPerson,
          isCreatingSession: isCreatingSession,
          isSendingPrompt: isSendingPrompt,
          backendError: backendError,
          backendPeople: backendPeople,
          backendSelectionIndex: backendSelectionIndex,
          onSelectBackendPerson: (index) =>
              setState(() => backendSelectionIndex = index),
          activeSession: activeSession,
          selectedBackendPerson: selectedBackendPerson,
          nameController: _nameController,
          affiliationController: _affiliationController,
          notesController: _notesController,
          contextController: _contextController,
          companionController: _companionController,
          promptController: _promptController,
          deliveryMode: deliveryMode,
          onDeliveryModeChanged: (value) =>
              setState(() => deliveryMode = value),
          onReload: _loadBackendPeople,
          onCreatePerson: _createPersonCard,
          onCreateSession: _createSession,
          onSendPrompt: _sendPrompt,
          onRefreshSession: _refreshActiveSession,
        ),
        const SizedBox(height: 20),
        const Text(
          'Prototype cues',
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
                  color: personIndex == index
                      ? const Color(0xFFE2EEF7)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: personIndex == index
                        ? const Color(0xFF26638E)
                        : AppTheme.line,
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

class _BackendSyncPanel extends StatelessWidget {
  const _BackendSyncPanel({
    required this.apiClient,
    required this.isLoadingBackend,
    required this.isCreatingPerson,
    required this.isCreatingSession,
    required this.isSendingPrompt,
    required this.backendError,
    required this.backendPeople,
    required this.backendSelectionIndex,
    required this.onSelectBackendPerson,
    required this.activeSession,
    required this.selectedBackendPerson,
    required this.nameController,
    required this.affiliationController,
    required this.notesController,
    required this.contextController,
    required this.companionController,
    required this.promptController,
    required this.deliveryMode,
    required this.onDeliveryModeChanged,
    required this.onReload,
    required this.onCreatePerson,
    required this.onCreateSession,
    required this.onSendPrompt,
    required this.onRefreshSession,
  });

  final AppApiClient apiClient;
  final bool isLoadingBackend;
  final bool isCreatingPerson;
  final bool isCreatingSession;
  final bool isSendingPrompt;
  final String? backendError;
  final List<NomenclatorPersonCard> backendPeople;
  final int backendSelectionIndex;
  final ValueChanged<int> onSelectBackendPerson;
  final NomenclatorSession? activeSession;
  final NomenclatorPersonCard? selectedBackendPerson;
  final TextEditingController nameController;
  final TextEditingController affiliationController;
  final TextEditingController notesController;
  final TextEditingController contextController;
  final TextEditingController companionController;
  final TextEditingController promptController;
  final String deliveryMode;
  final ValueChanged<String> onDeliveryModeChanged;
  final Future<void> Function() onReload;
  final Future<void> Function() onCreatePerson;
  final Future<void> Function() onCreateSession;
  final Future<void> Function() onSendPrompt;
  final Future<void> Function() onRefreshSession;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2F7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFB7CCDB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Backend sync',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilledButton.tonal(
                onPressed: apiClient.isConfigured && !isLoadingBackend
                    ? onReload
                    : null,
                child: const Text('Reload'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            apiClient.isConfigured
                ? 'Live against ${apiClient.baseUrl} using ${apiClient.authMode.toLowerCase()}.'
                : 'Set API_BASE_URL plus API_DEBUG_USER_ID or API_BEARER_TOKEN to use the Go backend.',
          ),
          if (backendError != null) ...[
            const SizedBox(height: 10),
            Text(
              backendError!,
              style: const TextStyle(
                color: Color(0xFFA33E2C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (apiClient.isConfigured) ...[
            _SectionTitle(
              title: 'Cloud people cards',
              trailing: isLoadingBackend
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('${backendPeople.length} cards'),
            ),
            const SizedBox(height: 8),
            if (backendPeople.isEmpty)
              const _MutedBox(
                text: 'No cloud people cards yet. Create one below.',
              )
            else
              ...backendPeople.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final selected = index == backendSelectionIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => onSelectBackendPerson(index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFD9EAF6)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF26638E)
                              : AppTheme.line,
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
                          if ((item.affiliation ?? '').isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(item.affiliation!),
                          ],
                          if ((item.notes ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              item.notes!,
                              style: const TextStyle(color: AppTheme.muted),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 14),
            const Text(
              'Create a people card',
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            _LabeledField(controller: nameController, label: 'Name'),
            const SizedBox(height: 8),
            _LabeledField(
              controller: affiliationController,
              label: 'Affiliation',
            ),
            const SizedBox(height: 8),
            _LabeledField(
              controller: notesController,
              label: 'Notes',
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: isCreatingPerson ? null : onCreatePerson,
              child: Text(
                isCreatingPerson ? 'Creating...' : 'Create people card',
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Live session',
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedBackendPerson == null
                  ? 'Select a cloud people card first.'
                  : 'Selected person: ${selectedBackendPerson!.name}',
            ),
            const SizedBox(height: 8),
            _LabeledField(
              controller: contextController,
              label: 'Context label',
            ),
            const SizedBox(height: 8),
            _LabeledField(
              controller: companionController,
              label: 'Companion user id',
            ),
            const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: selectedBackendPerson == null || isCreatingSession
                  ? null
                  : onCreateSession,
              child: Text(isCreatingSession ? 'Starting...' : 'Start session'),
            ),
            if (activeSession != null) ...[
              const SizedBox(height: 16),
              _MutedBox(
                text:
                    'Session ${activeSession!.id}\nStatus: ${activeSession!.status}\nContext: ${activeSession!.contextLabel ?? 'none'}',
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['quiet', 'manual', 'urgent']
                    .map(
                      (mode) => ChoiceChip(
                        label: Text(mode),
                        selected: deliveryMode == mode,
                        onSelected: (_) => onDeliveryModeChanged(mode),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              _LabeledField(
                controller: promptController,
                label: 'Prompt body',
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilledButton(
                    onPressed: isSendingPrompt ? null : onSendPrompt,
                    child: Text(isSendingPrompt ? 'Sending...' : 'Send prompt'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.tonal(
                    onPressed: onRefreshSession,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (activeSession!.prompts.isEmpty)
                const _MutedBox(text: 'No prompt messages in this session yet.')
              else
                ...activeSession!.prompts.map(
                  (prompt) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prompt.body,
                            style: const TextStyle(
                              color: AppTheme.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${prompt.deliveryMode} • ${prompt.createdAt}',
                            style: const TextStyle(color: AppTheme.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        trailing,
      ],
    );
  }
}

class _MutedBox extends StatelessWidget {
  const _MutedBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
      ),
      child: Text(text),
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
