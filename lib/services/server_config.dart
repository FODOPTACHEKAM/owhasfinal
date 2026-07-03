import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Server detection result from background isolate.
class _ServerDetectionResult {
  final String? url;
  final bool isOnline;
  final bool isHybrid;   // local server + internet both reachable

  _ServerDetectionResult({required this.url, required this.isOnline, this.isHybrid = false});
}

/// Top-level function for background server detection (runs in Isolate via compute).
/// This prevents UI jank by executing on a separate thread.
///
/// Detection order (optimised for the common online/cloud use-case):
///   1. https://owhas.org  — fast first check (most sessions go through the cloud)
///   2. Local LAN scan     — fixed gateways + subnet, parallel, 800 ms
///   3. Hybrid resolution  — both local + cloud reachable simultaneously
///   4. Slow-4G cloud retry
///   5. http://owhas.org:5501 — direct HTTP fallback (no reverse proxy)
///   6. https://owhas.org  — final last-resort retry before giving up
Future<_ServerDetectionResult> _detectServerInBackground(void _) async {
  final cloudUrl     = ServerConfig().onlineUrl;      // https://owhas.org
  final httpFallback = ServerConfig().onlineUrlHttp;  // http://owhas.org:5501
  final emulatorUrl  = ServerConfig().emulatorUrl;

  // ── 0. Local servers first — always prefer local over cloud ──────────────────
  //    Check all known local hotspot / VLAN IPs before hitting owhas.org.
  //    This prevents the app showing "Cloud Server" when the lecturer's PC
  //    is sharing its hotspot (which also provides internet to the phone).
  const localPriorityUrls = <String>[
    'http://10.13.14.164:5501',   // Workers Wi-Fi — direct IP
    'http://atd.ictu.loc',        // Workers/ICTU VLAN DNS (Nginx on port 80)
    'http://192.168.137.1:5501',  // Windows Mobile Hotspot (most common for PC)
    'http://192.168.43.1:5501',   // Android hotspot
    'http://172.20.10.1:5501',    // iOS hotspot
    'http://10.0.0.1:5501',
    'http://192.168.50.1:5501',
  ];
  for (final url in localPriorityUrls) {
    if (await _pingWithStrictTimeout(url, const Duration(milliseconds: 800))) {
      debugPrint('[ServerConfig] Local server detected (priority): $url');
      return _ServerDetectionResult(url: url, isOnline: false);
    }
  }

  // ── 1. Cloud — only reached if no local server responded ─────────────────────
  if (await _pingWithStrictTimeout(cloudUrl, const Duration(seconds: 2))) {
    debugPrint('[ServerConfig] Cloud detected (priority check): $cloudUrl');
    return _ServerDetectionResult(url: cloudUrl, isOnline: true);
  }

  // ── 2. Local scan: fixed gateways + full subnet (all parallel, 800 ms) ──────
  // Cloud probe runs concurrently so hybrid detection is still accurate.
  const Duration localTimeout         = Duration(milliseconds: 800);
  const Duration cloudParallelTimeout = Duration(seconds: 3);

  final cloudFuture = _pingWithStrictTimeout(cloudUrl, cloudParallelTimeout);

  final fixedCandidates = <String>[
    'http://192.168.137.1:5501',  // Windows Mobile Hotspot (fallback scan)
    'http://192.168.43.1:5501',   // Android hotspot (fallback scan)
    'http://172.20.10.1:5501',    // iOS hotspot (fallback scan)
    'http://10.0.0.1:5501',
    'http://192.168.50.1:5501',
  ];
  final subnetCandidates = <String>[
    for (int i = 1; i <= 254; i++) 'http://192.168.0.$i:5501',
    for (int i = 1; i <= 254; i++) 'http://192.168.1.$i:5501',
    for (int i = 1; i <= 254; i++) 'http://10.0.0.$i:5501',
  ];

  String? localUrl;
  try {
    final allLocal = [...fixedCandidates, ...subnetCandidates];
    final results  = await Future.wait(
      allLocal.map((url) => _pingWithStrictTimeout(url, localTimeout)),
      eagerError: false,
    );
    for (int i = 0; i < results.length; i++) {
      if (results[i]) { localUrl = allLocal[i]; break; }
    }
  } catch (e) {
    debugPrint('[ServerConfig] Subnet scan error: $e');
  }

  // Also check emulator loopback if no local IP found yet
  if (localUrl == null) {
    try {
      if (await _pingWithStrictTimeout(emulatorUrl, localTimeout)) {
        localUrl = emulatorUrl;
      }
    } catch (_) {}
  }

  // ── 3. Hybrid resolution (collect parallel cloud result) ─────────────────────
  final cloudUp = await cloudFuture;

  if (localUrl != null && cloudUp) {
    debugPrint('[ServerConfig] Hybrid detected: local=$localUrl + cloud');
    return _ServerDetectionResult(url: localUrl, isOnline: false, isHybrid: true);
  }
  if (localUrl != null) {
    debugPrint('[ServerConfig] Local server detected: $localUrl');
    return _ServerDetectionResult(url: localUrl, isOnline: false);
  }
  if (cloudUp) {
    debugPrint('[ServerConfig] Cloud detected (parallel check): $cloudUrl');
    return _ServerDetectionResult(url: cloudUrl, isOnline: true);
  }

  // ── 4. Slow 4G — give cloud a longer window ───────────────────────────────────
  if (await _pingWithStrictTimeout(cloudUrl, const Duration(seconds: 5))) {
    debugPrint('[ServerConfig] Cloud detected (slow 4G): $cloudUrl');
    return _ServerDetectionResult(url: cloudUrl, isOnline: true);
  }

  // ── 5. HTTP:5501 direct fallback (port 443 blocked on some networks) ─────────
  if (await _pingWithStrictTimeout(httpFallback, const Duration(seconds: 5))) {
    debugPrint('[ServerConfig] Cloud HTTP fallback detected: $httpFallback');
    return _ServerDetectionResult(url: httpFallback, isOnline: true);
  }

  // ── 6. Final cloud retry — last resort before giving up ──────────────────────
  if (await _pingWithStrictTimeout(cloudUrl, const Duration(seconds: 5))) {
    debugPrint('[ServerConfig] Cloud detected (last resort): $cloudUrl');
    return _ServerDetectionResult(url: cloudUrl, isOnline: true);
  }

  // ── 7. Nothing found ─────────────────────────────────────────────────────────
  debugPrint('[ServerConfig] No server detected. Falling back to default hotspot URL.');
  return _ServerDetectionResult(url: 'http://192.168.137.1:5501', isOnline: false);
}

/// Ping a URL with strict timeout to avoid UI jank.
Future<bool> _pingWithStrictTimeout(String url, Duration timeout) async {
  try {
    final response = await http
        .get(
          Uri.parse('$url/ping'),
          // Add explicit headers to avoid slowdowns
        )
        .timeout(timeout, onTimeout: () {
      throw TimeoutException('Ping timeout for $url');
    });
    return response.statusCode == 200;
  } catch (_) {
    // Silently fail; tried best effort
    return false;
  }
}


/// Centralized server address detection.
///
/// When running on the Android Emulator, the host machine is reachable via
/// the special loopback IP 10.0.2.2. When running on a real phone connected
/// to the Windows Mobile Hotspot, the server is at 192.168.137.1.
///
/// This service auto-detects the correct IP at startup and caches it.
/// Detection runs in a background isolate to prevent UI jank.
class ServerConfig {
  static final ServerConfig _instance = ServerConfig._internal();
  factory ServerConfig() => _instance;
  ServerConfig._internal();

  static const String _onlineUrl     = 'https://owhas.org';       // with reverse proxy
  static const String _onlineUrlHttp = 'http://owhas.org:5501';   // direct HTTP (no proxy)
  static const String _defaultEmulatorHost = '10.0.2.2';
  static const String _defaultHotspotHost = '192.168.137.1';
  static const int _defaultServerPort = 5501;

  String? _detectedUrl;
  bool _hasDetected = false;
  bool _isOnline = false;
  bool _isHybrid = false;

  /// The emulator host URL generated at runtime.
  String get emulatorUrl =>
      Uri(scheme: 'http', host: _defaultEmulatorHost, port: _defaultServerPort)
          .toString();

  /// The hotspot URL generated at runtime from the current hotspot host.
  String get hotspotUrl =>
      Uri(scheme: 'http', host: _defaultHotspotHost, port: _defaultServerPort)
          .toString();

  /// The fixed online cloud endpoint (HTTPS — requires reverse proxy on the server).
  String get onlineUrl => _onlineUrl;

  /// Direct HTTP access to the cloud server on port 5501 (no reverse proxy needed).
  String get onlineUrlHttp => _onlineUrlHttp;

  /// True if connected to the cloud, false if connected to local Intranet.
  bool get isOnline => _isOnline;

  /// True when both a local server and the cloud are reachable (VLAN + internet).
  bool get isHybrid => _isHybrid;

  /// The full base URL for API calls.
  String get baseUrl => _detectedUrl ?? hotspotUrl;

  /// The full URL for the poster QR code.
  String get baseQrUrl => '$baseUrl/public/hotspot.html';

  /// Fetch the dynamic QR URL from the server based on the hosting device's IP.
  Future<String> getDynamicQrUrl() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/qr-url')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final qrUrl = data['qrUrl'] as String?;
        if (qrUrl != null && qrUrl.isNotEmpty) {
          return qrUrl;
        }
      }
    } catch (e) {
      debugPrint('[ServerConfig] Failed to fetch dynamic QR URL: $e');
    }
    // Fallback to static URL
    return baseQrUrl;
  }

  /// The /24 subnet for network discovery scans.
  String get subnet {
    if (baseUrl.contains('10.0.2.2')) return '192.168.137.1';
    if (baseUrl.contains('owhas.org')) return 'owhas.org';
    return '192.168.137.1';
  }

  /// Auto-detect the correct server URL using background isolate.
  ///
  /// This method runs detection in a background isolate to prevent UI jank.
  /// It performs parallel scanning of common local IP addresses with strict
  /// timeouts, then falls back to default if no server is found.
  Future<void> detect() async {
    if (_hasDetected) return;

    try {
      // Run server detection in background isolate (prevents UI jank)
      final result = await compute<void, _ServerDetectionResult>(
        _detectServerInBackground,
        null,
      );

      if (result.url != null) {
        _detectedUrl = result.url;
        _isOnline    = result.isOnline;
        _isHybrid    = result.isHybrid;
        _hasDetected = true;
        debugPrint(
          '[ServerConfig] Server detection complete. '
          'URL: $_detectedUrl, Online: $_isOnline',
        );
      } else {
        // Graceful fallback (should not happen due to background logic)
        _detectedUrl = hotspotUrl;
        _isOnline = false;
        _hasDetected = true;
        debugPrint('[ServerConfig] Fallback to default hotspot URL');
      }
    } catch (e) {
      // Handle any unexpected errors gracefully
      debugPrint('[ServerConfig] Detection error: $e. Falling back to hotspot.');
      _detectedUrl = hotspotUrl;
      _isOnline = false;
      _hasDetected = true;
    }
  }

  void reset() {
    _hasDetected = false;
    _detectedUrl = null;
    _isOnline    = false;
    _isHybrid    = false;
  }
}

