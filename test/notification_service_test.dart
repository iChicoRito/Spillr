import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:spillr/core/notifications/notification_service.dart';

void main() {
  group('NotificationService.buildMessage', () {
    test('substitutes [Name] with the user display name in every template', () {
      for (final template in NotificationService.messageTemplates) {
        final result = NotificationService.buildMessage(template, 'Mika');
        expect(result, contains('Mika'));
        expect(result, isNot(contains('[Name]')));
      }
    });

    test('falls back to "friend" when name is empty', () {
      final result = NotificationService.buildMessage(
        NotificationService.messageTemplates.first,
        '',
      );
      expect(result, contains('friend'));
      expect(result, isNot(contains('[Name]')));
    });

    test('trims whitespace-only name and falls back to "friend"', () {
      final result = NotificationService.buildMessage(
        NotificationService.messageTemplates.first,
        '   ',
      );
      expect(result, contains('friend'));
    });
  });

  group('NotificationService.computeScheduleTimes', () {
    test('generates exactly the requested count', () {
      final times = NotificationService.computeScheduleTimes(
        count: 10,
        from: DateTime(2026, 6, 2, 12, 0),
        random: Random(42),
      );
      expect(times, hasLength(10));
    });

    test('first notification is 30–240 minutes from now', () {
      final now = DateTime(2026, 6, 2, 12, 0);
      for (var seed = 0; seed < 50; seed++) {
        final times = NotificationService.computeScheduleTimes(
          count: 1,
          from: now,
          random: Random(seed),
        );
        final diffMinutes = times.first.difference(now).inMinutes;
        expect(diffMinutes, greaterThanOrEqualTo(30));
        expect(diffMinutes, lessThanOrEqualTo(240));
      }
    });

    test('subsequent gaps are 360–1080 minutes (6–18 hr)', () {
      final now = DateTime(2026, 6, 2, 12, 0);
      final times = NotificationService.computeScheduleTimes(
        count: 5,
        from: now,
        random: Random(7),
      );
      for (var i = 1; i < times.length; i++) {
        final gapMinutes = times[i].difference(times[i - 1]).inMinutes;
        expect(gapMinutes, greaterThanOrEqualTo(360));
        expect(gapMinutes, lessThanOrEqualTo(1080));
      }
    });

    test('times are in strictly ascending order', () {
      final now = DateTime(2026, 6, 2, 12, 0);
      final times = NotificationService.computeScheduleTimes(
        count: 10,
        from: now,
        random: Random(99),
      );
      for (var i = 1; i < times.length; i++) {
        expect(times[i].isAfter(times[i - 1]), isTrue);
      }
    });
  });
}
