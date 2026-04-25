class AppProfile {
  const AppProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppProfile.fromJson(Map<String, dynamic> json) {
    return AppProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  final String id;
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final String createdAt;
  final String updatedAt;
}

class NomenclatorPersonCard {
  const NomenclatorPersonCard({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.affiliation,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NomenclatorPersonCard.fromJson(Map<String, dynamic> json) {
    return NomenclatorPersonCard(
      id: json['id'] as String,
      ownerUserId: json['owner_user_id'] as String,
      name: json['name'] as String,
      affiliation: json['affiliation'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  final String id;
  final String ownerUserId;
  final String name;
  final String? affiliation;
  final String? notes;
  final String createdAt;
  final String updatedAt;
}

class NomenclatorPromptMessage {
  const NomenclatorPromptMessage({
    required this.id,
    required this.sessionId,
    required this.senderUserId,
    required this.body,
    required this.deliveryMode,
    required this.createdAt,
  });

  factory NomenclatorPromptMessage.fromJson(Map<String, dynamic> json) {
    return NomenclatorPromptMessage(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      senderUserId: json['sender_user_id'] as String,
      body: json['body'] as String,
      deliveryMode: json['delivery_mode'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  final String id;
  final String sessionId;
  final String senderUserId;
  final String body;
  final String deliveryMode;
  final String createdAt;
}

class NomenclatorSession {
  const NomenclatorSession({
    required this.id,
    required this.ownerUserId,
    required this.companionUserId,
    required this.personCardId,
    required this.contextLabel,
    required this.status,
    required this.createdAt,
    required this.prompts,
  });

  factory NomenclatorSession.fromJson(Map<String, dynamic> json) {
    final prompts = (json['prompts'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              NomenclatorPromptMessage.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return NomenclatorSession(
      id: json['id'] as String,
      ownerUserId: json['owner_user_id'] as String,
      companionUserId: json['companion_user_id'] as String?,
      personCardId: json['person_card_id'] as String,
      contextLabel: json['context_label'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      prompts: prompts,
    );
  }

  final String id;
  final String ownerUserId;
  final String? companionUserId;
  final String personCardId;
  final String? contextLabel;
  final String status;
  final String createdAt;
  final List<NomenclatorPromptMessage> prompts;
}
