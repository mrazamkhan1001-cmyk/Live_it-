import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'audius_exceptions.dart';

/// Centralized HTTP client and Host Manager for Audius API
class AudiusClient {
  final http.Client _httpClient;
  final String appName;

  static const String discoveryRootUrl = 'https://api.audius.co';

  /// Pre-configured reliable fallback discovery nodes in case api.audius.co is slow or down
  static const List<String> defaultFallbackHosts = [
    'https://discoveryprovider.audius.co',
    'https://audius-discovery-1.cultur3stake.com',
    'https://discovery-us-01.audius.openplayer.org',
    'https://audius-discovery-2.cultur3stake.com',
    'https://audius-discovery-3.cultur3stake.com',
    'https://audius-dp.ams.creatorseed.com',
  ];

  List<String> _hosts = List.from(defaultFallbackHosts);
  String? _activeHost;
  DateTime? _lastHostDiscovery;

  AudiusClient({http.Client? httpClient, this.appName = 'LIVE_IT_AZAM'})
    : _httpClient = httpClient ?? http.Client();

  /// Currently active and healthy Audius host
  String get activeHost => _activeHost ?? _hosts.first;

  /// Get candidate hosts
  List<String> get candidateHosts => List.unmodifiable(_hosts);

  /// Discover available host nodes from Audius root endpoint
  Future<List<String>> discoverHosts({bool force = false}) async {
    final now = DateTime.now();
    if (!force &&
        _lastHostDiscovery != null &&
        now.difference(_lastHostDiscovery!) < const Duration(hours: 1)) {
      return _hosts;
    }

    try {
      final uri = Uri.parse(discoveryRootUrl);
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['data'] is List) {
          final discovered = (decoded['data'] as List)
              .map((h) => h.toString().replaceAll(RegExp(r'/+$'), ''))
              .where((h) => h.startsWith('http'))
              .toList();

          if (discovered.isNotEmpty) {
            // Keep unique hosts, with newly discovered hosts prioritized
            final combined = <String>{
              ...discovered,
              ...defaultFallbackHosts,
            }.toList();
            _hosts = combined;
            _lastHostDiscovery = now;
            if (_activeHost == null || !_hosts.contains(_activeHost)) {
              _activeHost = _hosts.first;
            }
            return _hosts;
          }
        }
      }
    } catch (_) {
      // Fallback silently to default hosts on discovery failure
    }

    _lastHostDiscovery = now;
    return _hosts;
  }

  /// Execute an API request with host fallback and retry logic
  Future<dynamic> request(
    String path, {
    Map<String, String>? queryParameters,
    Duration timeout = const Duration(seconds: 6),
    int maxHostRetries = 3,
  }) async {
    if (_hosts.isEmpty) {
      _hosts = List.from(defaultFallbackHosts);
    }

    // Ensure we have an active host
    if (_activeHost == null) {
      await discoverHosts();
    }

    final sanitizedPath = path.startsWith('/') ? path : '/$path';
    final params = <String, String>{
      'app_name': appName,
      if (queryParameters != null) ...queryParameters,
    };

    List<String> hostsToTry = [_activeHost ?? _hosts.first];
    for (final h in _hosts) {
      if (!hostsToTry.contains(h)) {
        hostsToTry.add(h);
      }
    }

    int attempts = 0;
    Object? lastError;

    for (final host in hostsToTry) {
      if (attempts >= maxHostRetries) break;
      attempts++;

      try {
        final uri = Uri.parse('$host$sanitizedPath')
            .replace(queryParameters: params);
        final response = await _httpClient
            .get(uri, headers: {'Accept': 'application/json'})
            .timeout(timeout);

        if (response.statusCode == 200 || response.statusCode == 201) {
          _activeHost = host;
          final decoded = jsonDecode(response.body);
          return decoded;
        } else if (response.statusCode == 404) {
          throw const NotFoundException();
        } else if (response.statusCode == 429) {
          throw const RateLimitException();
        } else if (response.statusCode >= 500) {
          // Server error on this node - try next host
          lastError = InvalidResponseException(
            'Host $host returned status ${response.statusCode}',
            response.statusCode,
          );
          continue;
        } else {
          throw InvalidResponseException(
            'Unexpected response status ${response.statusCode}',
            response.statusCode,
          );
        }
      } on SocketException catch (e) {
        lastError = NetworkException(
          'Cannot connect to Audius host $host: ${e.message}',
        );
        continue;
      } on async.TimeoutException {
        lastError = const TimeoutException('Audius host request timed out');
        continue;
      } on AudiusException {
        rethrow;
      } catch (e) {
        lastError = InvalidResponseException('Error contacting host $host: $e');
        continue;
      }
    }

    if (lastError is AudiusException) {
      throw lastError;
    }
    throw const HostUnavailableException();
  }

  /// Resolve a streamable URL for a track ID
  String getStreamUrl(String trackId) {
    final host = activeHost;
    return '$host/v1/tracks/$trackId/stream?app_name=$appName';
  }

  /// Set the active host manually (e.g. for testing)
  void setActiveHost(String host) {
    _activeHost = host;
  }

  /// Close client
  void close() {
    _httpClient.close();
  }
}
