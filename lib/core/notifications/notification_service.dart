import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const int _targetCount = 10;
  static const int _topUpThreshold = 3;
  static const String _channelId = 'spillr_reminders';
  static const String _channelName = 'Spillr Reminders';
  static const String _channelDesc =
      'Randomized reminders to open Spillr and play a card.';

  static const List<String> messageTemplates = [
    '[Name], not you ghosting the tea. Open Spillr and pull a card.',
    '[Name], one random question could expose the whole group chat.',
    'Your next card is waiting, [Name], and it\'s giving chaos.',
    'Social battery low, [Name]? Same. Still, one card won\'t hurt.',
    '[Name], the deck has something to ask. Don\'t leave it hanging.',
  ];

  static const List<String> _notificationTitles = [
    'Tea Check',
    'Group Chat Energy',
    'Chaos Incoming',
    'One Card Only',
    'Don\'t Make It Awkward',
  ];

  @visibleForTesting
  static bool testMode = false;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.defaultImportance,
          ),
        );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (testMode) return true;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  Future<void> scheduleAll({
    required String displayName,
    Random? random,
  }) async {
    if (testMode) return;
    await cancelAll();
    final rng = random ?? Random();
    final times = computeScheduleTimes(
      count: _targetCount,
      from: DateTime.now(),
      random: rng,
    );
    for (var i = 0; i < times.length; i++) {
      await _scheduleSingle(
        id: i + 1,
        displayName: displayName,
        scheduledTime: times[i],
        random: rng,
      );
    }
  }

  Future<void> topUpIfNeeded({
    required String displayName,
    Random? random,
  }) async {
    if (testMode) return;
    final pending = await _plugin.pendingNotificationRequests();
    if (pending.length >= _topUpThreshold) return;
    final needed = _targetCount - pending.length;
    final rng = random ?? Random();
    final times = computeScheduleTimes(
      count: needed,
      from: DateTime.now(),
      random: rng,
    );
    final usedIds = pending.map((n) => n.id).toSet();
    var idCursor = 1;
    for (final time in times) {
      while (usedIds.contains(idCursor)) {
        idCursor++;
      }
      await _scheduleSingle(
        id: idCursor,
        displayName: displayName,
        scheduledTime: time,
        random: rng,
      );
      usedIds.add(idCursor++);
    }
  }

  Future<void> cancelAll() async {
    if (testMode) return;
    await _plugin.cancelAll();
  }

  static String buildMessage(String template, String displayName) {
    final name = displayName.trim().isEmpty ? 'friend' : displayName.trim();
    return template.replaceAll('[Name]', name);
  }

  static List<DateTime> computeScheduleTimes({
    required int count,
    required DateTime from,
    Random? random,
  }) {
    final rng = random ?? Random();
    final times = <DateTime>[];
    // First notification: 30–240 min from now
    var cursor = from.add(Duration(minutes: 30 + rng.nextInt(211)));
    times.add(cursor);
    for (var i = 1; i < count; i++) {
      // Subsequent: 360–1080 min (6–18 hr) apart
      cursor = cursor.add(Duration(minutes: 360 + rng.nextInt(721)));
      times.add(cursor);
    }
    return times;
  }

  Future<void> _scheduleSingle({
    required int id,
    required String displayName,
    required DateTime scheduledTime,
    Random? random,
  }) async {
    final rng = random ?? Random();
    final idx = rng.nextInt(messageTemplates.length);
    final body = buildMessage(messageTemplates[idx], displayName);
    final title = _notificationTitles[idx];
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
