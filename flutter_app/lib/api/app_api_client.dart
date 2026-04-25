import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_api_models.dart';

class AppApiException implements Exception {
  const AppApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AppApiClient {
  AppApiClient({
    required this.baseUrl,
    required this.debugUserId,
    required this.bearerToken,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  factory AppApiClient.fromEnvironment() {
    return AppApiClient(
      baseUrl: const String.fromEnvironment('API_BASE_URL'),
      debugUserId: const String.fromEnvironment('API_DEBUG_USER_ID'),
      bearerToken: const String.fromEnvironment('API_BEARER_TOKEN'),
    );
  }

  final String baseUrl;
  final String debugUserId;
  final String bearerToken;
  final http.Client _httpClient;

  bool get hasBaseUrl => baseUrl.trim().isNotEmpty;
  bool get hasAuth =>
      debugUserId.trim().isNotEmpty || bearerToken.trim().isNotEmpty;
  bool get isConfigured => hasBaseUrl && hasAuth;

  String get authMode {
    if (bearerToken.trim().isNotEmpty) {
      return 'Bearer token';
    }
    if (debugUserId.trim().isNotEmpty) {
      return 'Debug user';
    }
    return 'Missing auth';
  }

  Future<AppProfile> getProfile() async {
    final response = await _send('GET', '/v1/me');
    return AppProfile.fromJson(_readObject(response, 'profile'));
  }

  Future<List<NomenclatorPersonCard>> listPeopleCards() async {
    final response = await _send('GET', '/v1/nomenclator/people');
    final people = _readList(response, 'people');
    return people
        .map(
          (item) =>
              NomenclatorPersonCard.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<NomenclatorPersonCard> createPersonCard({
    required String name,
    String? affiliation,
    String? notes,
  }) async {
    final response = await _send(
      'POST',
      '/v1/nomenclator/people',
      body: {
        'name': name,
        if (_present(affiliation)) 'affiliation': affiliation!.trim(),
        if (_present(notes)) 'notes': notes!.trim(),
      },
    );
    return NomenclatorPersonCard.fromJson(_readObject(response, 'person'));
  }

  Future<NomenclatorSession> createSession({
    required String personCardId,
    String? contextLabel,
    String? companionUserId,
  }) async {
    final response = await _send(
      'POST',
      '/v1/nomenclator/sessions',
      body: {
        'person_card_id': personCardId,
        if (_present(contextLabel)) 'context_label': contextLabel!.trim(),
        if (_present(companionUserId))
          'companion_user_id': companionUserId!.trim(),
      },
    );
    return NomenclatorSession.fromJson(_readObject(response, 'session'));
  }

  Future<NomenclatorSession> getSession(String sessionId) async {
    final response = await _send('GET', '/v1/nomenclator/sessions/$sessionId');
    return NomenclatorSession.fromJson(_readObject(response, 'session'));
  }

  Future<NomenclatorPromptMessage> createPrompt({
    required String sessionId,
    required String body,
    required String deliveryMode,
  }) async {
    final response = await _send(
      'POST',
      '/v1/nomenclator/sessions/$sessionId/prompts',
      body: {'body': body, 'delivery_mode': deliveryMode},
    );
    return NomenclatorPromptMessage.fromJson(_readObject(response, 'prompt'));
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    if (!hasBaseUrl) {
      throw const AppApiException('API_BASE_URL is not configured');
    }
    if (!hasAuth) {
      throw const AppApiException(
        'Set API_DEBUG_USER_ID or API_BEARER_TOKEN to call the backend.',
      );
    }

    final uri = Uri.parse('${baseUrl.trim()}$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (bearerToken.trim().isNotEmpty)
        'Authorization': 'Bearer ${bearerToken.trim()}',
      if (debugUserId.trim().isNotEmpty) 'X-Debug-User-ID': debugUserId.trim(),
    };

    late http.Response response;
    final payload = body == null ? null : jsonEncode(body);

    try {
      if (method == 'GET') {
        response = await _httpClient
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 10));
      } else if (method == 'POST') {
        response = await _httpClient
            .post(uri, headers: headers, body: payload)
            .timeout(const Duration(seconds: 10));
      } else if (method == 'PATCH') {
        response = await _httpClient
            .patch(uri, headers: headers, body: payload)
            .timeout(const Duration(seconds: 10));
      } else {
        throw AppApiException('Unsupported method $method');
      }
    } on TimeoutException {
      throw const AppApiException('API request timed out');
    } on http.ClientException catch (error) {
      throw AppApiException('Network error: ${error.message}');
    }

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      final error = decoded['error'];
      final message = error is Map<String, dynamic>
          ? (error['message'] as String? ?? 'API request failed')
          : 'API request failed';
      throw AppApiException(message, statusCode: response.statusCode);
    }

    return decoded;
  }

  Map<String, dynamic> _readObject(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw AppApiException('Response is missing "$key"');
  }

  List<dynamic> _readList(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is List<dynamic>) {
      return value;
    }
    throw AppApiException('Response is missing "$key"');
  }

  bool _present(String? value) => value != null && value.trim().isNotEmpty;
}
