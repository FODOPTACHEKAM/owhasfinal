import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../services/server_config.dart';
import '../../../services/api_service.dart';

enum ServerConnectionStatus { checking, cloud, wifi, none }

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

    // 1. Try the URL that detection resolved (local hotspot or cloud).
    try {
      await ApiService().pingServer();
      _status = ServerConfig().isOnline
          ? ServerConnectionStatus.cloud
          : ServerConnectionStatus.wifi;
      notifyListeners();
      return;
    } catch (_) {}

    // 2. Primary failed — detection may have fallen back to the default hotspot
    //    address while the phone is on mobile data. Try both cloud variants
    //    directly before giving up.
    final cloudCandidates = [
      ServerConfig().onlineUrlHttp,  // http://owhas.org:5501 (direct, no proxy)
      ServerConfig().onlineUrl,      // https://owhas.org     (reverse proxy)
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
