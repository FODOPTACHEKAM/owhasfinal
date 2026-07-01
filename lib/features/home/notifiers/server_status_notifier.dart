import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../services/server_config.dart';
import '../../../services/api_service.dart';

enum ServerConnectionStatus { checking, cloud, wifi, hybrid, workers, none }

class ServerStatusNotifier extends ChangeNotifier {
  ServerConnectionStatus _status    = ServerConnectionStatus.checking;
  String                 _serverUrl = '';

  ServerConnectionStatus get status    => _status;
  String                 get serverUrl => _serverUrl;

  /// Call once after app startup detection has already run.
  Future<void> initialize() => _updateStatus();

  /// Reset detection and re-probe from scratch.
  Future<void> refresh() async {
    _status = ServerConnectionStatus.checking;
    notifyListeners();
    ServerConfig().reset();
    await ServerConfig().detect();
    await _updateStatus();
  }

  Future<void> _updateStatus() async {
    _serverUrl = ServerConfig().baseUrl;

    // 1. Try the URL that detection resolved (local hotspot, cloud, or hybrid).
    //    ServerConfig already probed both local and cloud in parallel during
    //    detect(), so we just read the pre-computed flags — no extra round-trip.
    try {
      await ApiService().pingServer();
      final url = ServerConfig().baseUrl;
      final isWorkers = url.contains('10.13.14.');
      _status = isWorkers
          ? ServerConnectionStatus.workers
          : ServerConfig().isHybrid
              ? ServerConnectionStatus.hybrid
              : ServerConfig().isOnline
                  ? ServerConnectionStatus.cloud
                  : ServerConnectionStatus.wifi;
      notifyListeners();
      return;
    } catch (_) {}

    // 2. Primary failed — detection may have fallen back to the default hotspot
    //    address while the phone is on mobile data. Try cloud directly before
    //    giving up. HTTPS first (port 443 via Nginx); HTTP:5501 may be blocked.
    final cloudCandidates = [
      ServerConfig().onlineUrl,      // https://owhas.org     (reverse proxy, port 443)
      ServerConfig().onlineUrlHttp,  // http://owhas.org:5501 (fallback, may be blocked)
    ];
    for (final cloudUrl in cloudCandidates) {
      try {
        final res = await http
            .get(Uri.parse('$cloudUrl/ping'))
            .timeout(const Duration(seconds: 6));
        if (res.statusCode == 200) {
          _status    = ServerConnectionStatus.cloud;
          _serverUrl = cloudUrl;
          notifyListeners();
          return;
        }
      } catch (_) {}
    }

    _status = ServerConnectionStatus.none;
    notifyListeners();
  }
}
