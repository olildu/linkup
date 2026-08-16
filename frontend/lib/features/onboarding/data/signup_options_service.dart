import 'dart:developer';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linkup/features/onboarding/data/models/signup_options_model.dart';

class SignupOptionsService {
  static const String _logTag = 'SignupOptionsService';
  static const String _remoteUrl =
      'https://raw.githubusercontent.com/olildu/linkup-frontend/refs/heads/main/assets/json/signup_options.json';
  static const String _assetFallbackPath = 'assets/json/signup_options.json';
  static const String _cacheJsonKey = 'signup_options_cache_json';
  static const String _cacheEtagKey = 'signup_options_cache_etag';
  static const String _cacheFetchedAtKey = 'signup_options_cache_fetched_at';
  static const Duration _cacheTtl = Duration(hours: 12);

  final http.Client _client;

  SignupOptionsService({http.Client? client})
    : _client = client ?? http.Client();

  Future<SignupOptionsConfig> loadSignupOptions({
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_cacheJsonKey);
    final cachedEtag = prefs.getString(_cacheEtagKey);
    final cachedFetchedAt = prefs.getInt(_cacheFetchedAtKey);

    log(
      'loadSignupOptions(forceRefresh: $forceRefresh, hasCache: ${cachedJson != null}, cachedEtag: ${cachedEtag != null && cachedEtag.isNotEmpty})',
      name: _logTag,
    );

    final hasFreshCache =
        cachedJson != null &&
        cachedFetchedAt != null &&
        DateTime.now().difference(
              DateTime.fromMillisecondsSinceEpoch(cachedFetchedAt),
            ) <
            _cacheTtl;

    if (cachedJson != null && hasFreshCache && !forceRefresh) {
      log('Using fresh local cache. Skipping GitHub fetch.', name: _logTag);
      return SignupOptionsConfig.fromJson(
        jsonDecode(cachedJson) as Map<String, dynamic>,
      );
    }

    try {
      final headers = <String, String>{'Accept': 'application/json'};
      if (cachedEtag != null && cachedEtag.isNotEmpty) {
        headers['If-None-Match'] = cachedEtag;
        log('Sending ETag to GitHub: $cachedEtag', name: _logTag);
      }

      log('Fetching signup options from GitHub.', name: _logTag);

      final response = await _client.get(
        Uri.parse(_remoteUrl),
        headers: headers,
      );

      log('GitHub response status: ${response.statusCode}', name: _logTag);

      if (response.statusCode == 304 && cachedJson != null) {
        await prefs.setInt(
          _cacheFetchedAtKey,
          DateTime.now().millisecondsSinceEpoch,
        );
        log(
          'GitHub reported no content change (304). Reusing cached JSON.',
          name: _logTag,
        );
        return SignupOptionsConfig.fromJson(
          jsonDecode(cachedJson) as Map<String, dynamic>,
        );
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final options = SignupOptionsConfig.fromJson(decoded);
        final remoteVersion = options.version;
        final cachedVersion = cachedJson != null
            ? SignupOptionsConfig.fromJson(
                jsonDecode(cachedJson) as Map<String, dynamic>,
              ).version
            : null;

        if (cachedVersion == null) {
          log(
            'Fetched config version $remoteVersion from GitHub for the first time.',
            name: _logTag,
          );
        } else if (cachedVersion != remoteVersion) {
          log(
            'GitHub config version changed: $cachedVersion -> $remoteVersion.',
            name: _logTag,
          );
        } else {
          log(
            'GitHub config version unchanged at $remoteVersion.',
            name: _logTag,
          );
        }

        await prefs.setString(_cacheJsonKey, response.body);
        await prefs.setString(_cacheEtagKey, response.headers['etag'] ?? '');
        await prefs.setInt(
          _cacheFetchedAtKey,
          DateTime.now().millisecondsSinceEpoch,
        );

        log('Cached the latest GitHub config locally.', name: _logTag);

        return options;
      }

      log(
        'GitHub fetch returned ${response.statusCode}. Will fall back to local data if available.',
        name: _logTag,
      );
    } catch (_) {
      log(
        'GitHub fetch failed or no network available. Falling back to local data.',
        name: _logTag,
      );
    }

    if (cachedJson != null) {
      log(
        'Using cached local signup options after GitHub failure.',
        name: _logTag,
      );
      return SignupOptionsConfig.fromJson(
        jsonDecode(cachedJson) as Map<String, dynamic>,
      );
    }

    try {
      log(
        'No cache available. Loading bundled local signup options asset.',
        name: _logTag,
      );
      final assetJson = await rootBundle.loadString(_assetFallbackPath);
      log('Loaded bundled local signup options asset.', name: _logTag);
      return SignupOptionsConfig.fromJson(
        jsonDecode(assetJson) as Map<String, dynamic>,
      );
    } catch (_) {
      log(
        'Bundled asset unavailable. Defaulting to hardcoded local fallback config.',
        name: _logTag,
      );
      return SignupOptionsConfig.fallback();
    }
  }
}
