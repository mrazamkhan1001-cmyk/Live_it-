import 'package:flutter_test/flutter_test.dart';
import 'package:liveitbyazam/utils/user_utils.dart';

void main() {
  group('UserUtils.deriveNameFromEmail', () {
    test('handles standard email addresses with separators', () {
      expect(UserUtils.deriveNameFromEmail('mohd.azam@gmail.com'), 'Mohd Azam');
      expect(UserUtils.deriveNameFromEmail('azam_khan@gmail.com'), 'Azam Khan');
      expect(UserUtils.deriveNameFromEmail('john-doe@example.com'), 'John Doe');
      expect(UserUtils.deriveNameFromEmail('jane+music@example.com'), 'Jane Music');
    });

    test('handles trailing digits in usernames', () {
      expect(UserUtils.deriveNameFromEmail('azam123@gmail.com'), 'Azam');
      expect(UserUtils.deriveNameFromEmail('user999@yahoo.com'), 'User');
    });

    test('handles fused common names', () {
      expect(UserUtils.deriveNameFromEmail('azamkhan@gmail.com'), 'Azam Khan');
    });

    test('handles edge cases safely', () {
      expect(UserUtils.deriveNameFromEmail(''), 'User');
      expect(UserUtils.deriveNameFromEmail(null), 'User');
      expect(UserUtils.deriveNameFromEmail('   '), 'User');
      expect(UserUtils.deriveNameFromEmail('user@domain.com'), 'User');
    });
  });

  group('UserUtils.deriveUsernameFromEmail', () {
    test('derives clean usernames', () {
      expect(UserUtils.deriveUsernameFromEmail('mohd.azam@gmail.com'), 'mohd_azam');
      expect(UserUtils.deriveUsernameFromEmail('azam_khan@gmail.com'), 'azam_khan');
      expect(UserUtils.deriveUsernameFromEmail('azam123@gmail.com'), 'azam123');
      expect(UserUtils.deriveUsernameFromEmail('azamkhan@gmail.com'), 'azamkhan');
    });

    test('handles null and empty', () {
      expect(UserUtils.deriveUsernameFromEmail(null), 'user');
      expect(UserUtils.deriveUsernameFromEmail(''), 'user');
    });
  });

  group('UserUtils.resolveDisplayName', () {
    test('priority 1: explicitly saved name takes precedence', () {
      final result = UserUtils.resolveDisplayName(
        savedName: 'Custom Name',
        authDisplayName: 'Auth Name',
        email: 'mohd.azam@gmail.com',
      );
      expect(result, 'Custom Name');
    });

    test('ignores legacy default Azam Uchiha in saved name', () {
      final result = UserUtils.resolveDisplayName(
        savedName: 'Azam Uchiha',
        authDisplayName: 'Mohd Azam',
        email: 'mohd.azam@gmail.com',
      );
      expect(result, 'Mohd Azam');
    });

    test('priority 2: provider displayName takes precedence over email', () {
      final result = UserUtils.resolveDisplayName(
        savedName: null,
        authDisplayName: 'Google Provider Name',
        email: 'mohd.azam@gmail.com',
      );
      expect(result, 'Google Provider Name');
    });

    test('priority 3: derives from email when no saved name or auth name', () {
      final result = UserUtils.resolveDisplayName(
        savedName: null,
        authDisplayName: null,
        email: 'mohd.azam@gmail.com',
      );
      expect(result, 'Mohd Azam');
    });

    test('fallback to User when everything is missing', () {
      final result = UserUtils.resolveDisplayName(
        savedName: null,
        authDisplayName: null,
        email: null,
      );
      expect(result, 'User');
    });
  });

  group('UserUtils.resolveUsername', () {
    test('uses saved username if present and not default', () {
      expect(
        UserUtils.resolveUsername(
          savedUsername: 'my_handle',
          email: 'mohd.azam@gmail.com',
        ),
        'my_handle',
      );
    });

    test('ignores legacy azam_uchiha and derives from email', () {
      expect(
        UserUtils.resolveUsername(
          savedUsername: 'azam_uchiha',
          email: 'mohd.azam@gmail.com',
        ),
        'mohd_azam',
      );
    });

    test('falls back to user if email is also null', () {
      expect(
        UserUtils.resolveUsername(
          savedUsername: null,
          email: null,
        ),
        'user',
      );
    });
  });
}
