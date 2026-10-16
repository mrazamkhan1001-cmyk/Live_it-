
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:liveitbyazam/screens/edit_profile_screen.dart';
import 'package:liveitbyazam/screens/profile_screen.dart';
import 'package:liveitbyazam/services/audio_service.dart';
import 'package:liveitbyazam/services/auth_service.dart';
import 'package:liveitbyazam/services/storage_service.dart';
import 'package:liveitbyazam/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<dynamic> handleMethodCall(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'init':
        final dynamic args = methodCall.arguments;
        final String? id = args is Map ? args['id']?.toString() : null;
        if (id != null) {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                MethodChannel('com.ryanheise.just_audio.methods.$id'),
                handleMethodCall,
              );

          final eventChannel = 'com.ryanheise.just_audio.events.$id';
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(MethodChannel(eventChannel), (
                MethodCall call,
              ) async {
                if (call.method == 'listen') {
                  final eventData = {
                    'processingState': 2, // ready
                    'updatePosition': 0,
                    'updateTime': DateTime.now().millisecondsSinceEpoch,
                    'bufferedPosition': 180000000,
                    'duration': 180000000,
                    'icyMetadata': null,
                    'currentIndex': 0,
                    'androidAudioSessionId': null,
                  };
                  final encoded = const StandardMethodCodec()
                      .encodeSuccessEnvelope(eventData);
                  TestDefaultBinaryMessengerBinding
                      .instance
                      .defaultBinaryMessenger
                      .handlePlatformMessage(
                        eventChannel,
                        encoded,
                        (ByteData? reply) {},
                      );
                }
                return null;
              });
        }
        return {};
      case 'load':
        return {'duration': 180000000};
      case 'play':
      case 'pause':
      case 'stop':
      case 'seek':
      case 'setVolume':
      case 'setSpeed':
      case 'setLoopMode':
      case 'setShuffleMode':
      case 'dispose':
        return {};
      default:
        return {};
    }
  }

  const MethodChannel channel = MethodChannel(
    'com.ryanheise.just_audio.methods',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, handleMethodCall);

  late Directory testDir;
  late AudioPlayerService audioService;

  setUpAll(() async {
    testDir = await Directory.systemTemp.createTemp('live_it_profile_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => testDir.path,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider_windows'),
          (MethodCall methodCall) async => testDir.path,
        );
  });

  tearDownAll(() async {
    try {
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTesting();
    await StorageService.init();
    AuthService.instance.clearMockUser();
    audioService = AudioPlayerService();
    await audioService.initialized;
  });

  tearDown(() {
    AuthService.instance.clearMockUser();
  });

  group('Edit Profile Dynamic Functionality Tests', () {
    testWidgets('1. EditProfileScreen initializes with current user profile data', (
      WidgetTester tester,
    ) async {
      await audioService.updateUserProfile(
        const UserProfile(
          name: 'Sasuke Uchiha',
          username: 'sasuke_avenger',
          bio: 'My only goal is vengeance.',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const EditProfileScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify fields are populated from real user data, not hardcoded strings
      expect(find.widgetWithText(TextField, 'Sasuke Uchiha'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'sasuke_avenger'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'My only goal is vengeance.'), findsOneWidget);
    });

    testWidgets('2. Validation prevents saving invalid name and username', (
      WidgetTester tester,
    ) async {
      await audioService.updateUserProfile(
        const UserProfile(
          name: 'Valid Name',
          username: 'valid_user',
          bio: 'Initial bio',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const EditProfileScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Clear name
      final nameField = find.byType(TextField).at(0);
      await tester.enterText(nameField, '');
      await tester.pump();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify validation error
      expect(find.text('Name cannot be empty'), findsOneWidget);

      // Enter valid name, but invalid username (with spaces / special symbols)
      await tester.enterText(nameField, 'Good Name');
      final usernameField = find.byType(TextField).at(1);
      await tester.enterText(usernameField, 'invalid user!');
      await tester.pump();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Letters, numbers, and underscores only'), findsOneWidget);
    });

    testWidgets('3. No changes triggers informational message without save request', (
      WidgetTester tester,
    ) async {
      await audioService.updateUserProfile(
        const UserProfile(
          name: 'Azam Khan',
          username: 'azam_uchiha',
          bio: 'Music for the ones who understand...',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const EditProfileScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Save without modifying any field
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No changes to save'), findsOneWidget);
      // Screen should remain open
      expect(find.byType(EditProfileScreen), findsOneWidget);
    });

    testWidgets(
      '4. Saving updated profile synchronizes with AudioPlayerService and persists to Storage',
      (WidgetTester tester) async {
        await audioService.updateUserProfile(
          const UserProfile(
            name: 'Original Name',
            username: 'original_user',
            bio: 'Original bio',
          ),
        );

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audioService,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const EditProfileScreen(),
            ),
          ),
        );
        await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

        // Edit all three fields
        await tester.enterText(find.byType(TextField).at(0), 'Madara Uchiha');
        await tester.enterText(find.byType(TextField).at(1), 'madara_reborn');
        await tester.enterText(find.byType(TextField).at(2), 'Wake up to reality.');
        await tester.pump();

        // Tap Save
        await tester.tap(find.text('Save'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify AudioPlayerService received real updates
        expect(audioService.userProfile.name, 'Madara Uchiha');
        expect(audioService.userProfile.username, 'madara_reborn');
        expect(audioService.userProfile.bio, 'Wake up to reality.');

        // Verify persistent storage was updated
        final stored = await StorageService.getUserProfile();
        expect(stored.name, 'Madara Uchiha');
        expect(stored.username, 'madara_reborn');
        expect(stored.bio, 'Wake up to reality.');
      },
    );

    testWidgets(
      '5. ProfileScreen reactively displays updated profile without restart or reload',
      (WidgetTester tester) async {
        await audioService.updateUserProfile(
          const UserProfile(
            name: 'Itachi Uchiha',
            username: 'itachi_crow',
            bio: 'People live their lives bound by what they accept as correct.',
          ),
        );

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audioService,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const ProfileScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify initial profile values in ProfileScreen
        expect(find.text('Itachi Uchiha'), findsOneWidget);
        expect(find.text('@itachi_crow'), findsOneWidget);
        expect(
          find.text('"People live their lives bound by what they accept as correct."'),
          findsOneWidget,
        );

        // Update profile in AudioPlayerService
        await audioService.updateUserProfile(
          const UserProfile(
            name: 'Kakashi Hatake',
            username: 'copy_ninja',
            bio: 'In the shinobi world, those who break the rules are scum.',
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify ProfileScreen reactively updated immediately
        expect(find.text('Kakashi Hatake'), findsOneWidget);
        expect(find.text('@copy_ninja'), findsOneWidget);
        expect(
          find.text('"In the shinobi world, those who break the rules are scum."'),
          findsOneWidget,
        );
      },
    );

    testWidgets('6. User isolation prevents Account B from seeing Account A private profile', (
      WidgetTester tester,
    ) async {
      // 1. Account A saves a custom profile
      const userAProfile = UserProfile(
        name: 'Account A User',
        username: 'account_a_private',
        bio: 'Confidential bio for User A',
      );
      await StorageService.saveUserProfile(userAProfile, uid: 'uid_account_a');

      // 2. Account B loads profile
      final userBProfile = await StorageService.getUserProfile(uid: 'uid_account_b');

      // Account B should NOT see User A's private data
      expect(userBProfile.name, isNot('Account A User'));
      expect(userBProfile.username, isNot('account_a_private'));
      expect(userBProfile.bio, isNot('Confidential bio for User A'));

      // Account A still has their data preserved
      final userAReloaded = await StorageService.getUserProfile(uid: 'uid_account_a');
      expect(userAReloaded.name, 'Account A User');
      expect(userAReloaded.username, 'account_a_private');
      expect(userAReloaded.bio, 'Confidential bio for User A');
    });

    testWidgets('7. Empty bio is supported and correctly persisted', (
      WidgetTester tester,
    ) async {
      await audioService.updateUserProfile(
        const UserProfile(
          name: 'Silent Ninja',
          username: 'silent_ninja',
          bio: 'Old bio that will be cleared',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const EditProfileScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Clear bio (TextField at index 2)
      await tester.enterText(
        find.byType(TextField).at(2),
        '',
      );
      await tester.pump();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(audioService.userProfile.bio, '');
      final stored = await StorageService.getUserProfile();
      expect(stored.bio, '');
    });
  });
}
