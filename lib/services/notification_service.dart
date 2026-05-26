import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Handles all local notifications for the lecturer device.
///
/// Strategy:
///   - When a session is CREATED  → schedule a notification at the exact expiry time.
///   - When a session is MANUALLY ENDED before expiry → cancel the scheduled
///     notification and show an immediate one with the final student count.
///   - When a session EXPIRES naturally (auto-end timer) → the scheduled
///     notification fires on its own, even if the app is in the background.
///
/// This ensures exactly one notification per session regardless of how it ends.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const int    _sessionEndId      = 1001;
  static const String _channelId         = 'owhas_session_end';
  static const String _channelName       = 'Session Notifications';
  static const String _channelDesc       =
      'Alerts the lecturer when an attendance session ends';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── Initialisation ────────────────────────────────────────────────────────

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Request POST_NOTIFICATIONS permission on Android 13+.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── Schedule (session created) ────────────────────────────────────────────

  /// Schedules a notification to fire at [endsAt].
  /// Any previous scheduled notification is cancelled first.
  /// Uses [inexactAllowWhileIdle] — no SCHEDULE_EXACT_ALARM permission needed,
  /// fires even when the device is in Doze mode.
  Future<void> scheduleSessionEnd({
    required String   courseName,
    required DateTime endsAt,
  }) async {
    await _plugin.cancel(_sessionEndId);

    final scheduledDate = tz.TZDateTime.from(endsAt, tz.local);

    // Guard: do not schedule a notification in the past.
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      _sessionEndId,
      'Session Ended',
      '$courseName session has ended.',
      scheduledDate,
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Immediate (manual end) ────────────────────────────────────────────────

  /// Cancels the scheduled notification and shows an immediate one
  /// that includes the final student count.
  Future<void> showSessionEnded({
    required String courseName,
    required int    totalStudents,
  }) async {
    await _plugin.cancel(_sessionEndId);

    final body = totalStudents == 0
        ? '$courseName ended — no students registered.'
        : '$courseName ended — '
          '$totalStudents student${totalStudents == 1 ? '' : 's'} registered.';

    await _plugin.show(_sessionEndId, 'Session Ended', body, _details());
  }

  // ── Cancel only ───────────────────────────────────────────────────────────

  /// Cancels a pending scheduled notification without showing a new one.
  /// Used if a session is cleaned up silently (e.g. expired at app startup).
  Future<void> cancelSessionEnd() async {
    await _plugin.cancel(_sessionEndId);
  }

  // ── Shared notification details ───────────────────────────────────────────

  NotificationDetails _details() => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance:         Importance.high,
      priority:           Priority.high,
      icon:               '@mipmap/ic_launcher',
      playSound:          true,
      enableVibration:    true,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );
}
