import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:liveitbyazam/screens/loading_screen.dart';
import 'package:liveitbyazam/screens/login_screen.dart';
import 'package:liveitbyazam/screens/main_shell_screen.dart';
import 'package:liveitbyazam/screens/signup_screen.dart';
import 'package:liveitbyazam/services/audio_service.dart';
import 'package:liveitbyazam/services/auth_service.dart';
import 'package:liveitbyazam/theme/app_theme.dart';

class FakeFirebaseUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final String? photoURL;

  FakeFirebaseUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AuthService.instance.clearMockUser();
  });

  tearDown(() {
    AuthService.instance.clearMockUser();
  });

  group('Startup Auth State Routing Tests', () {
    testWidgets(
      'Signed-out startup routes to LoginScreen after LoadingScreen animation',
      (WidgetTester tester) async {
        final audioService = AudioPlayerService();
        AuthService.instance.clearMockUser();

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audioService,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const LoadingScreen(duration: Duration(milliseconds: 50)),
            ),
          ),
        );

        // Verify LoadingScreen is initially shown
        expect(find.byType(LoadingScreen), findsOneWidget);

        // Fast forward past the loading animation
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Verify routing to LoginScreen and NOT MainShellScreen
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(MainShellScreen), findsNothing);
      },
    );

    testWidgets(
      'Signed-in startup restores session and routes to MainShellScreen',
      (WidgetTester tester) async {
        final audioService = AudioPlayerService();
        final fakeUser = FakeFirebaseUser(
          uid: 'test_uchiha_101',
          email: 'itachi@liveit.com',
          displayName: 'Itachi Uchiha',
        );

        AuthService.instance.setMockUser(fakeUser);

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audioService,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const LoadingScreen(duration: Duration(milliseconds: 50)),
            ),
          ),
        );

        // Fast forward past loading animation
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Verify session restoration navigates to MainShellScreen and NOT LoginScreen
        expect(find.byType(MainShellScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);

        // Verify username was populated in AudioPlayerService
        expect(audioService.userName, 'Itachi');
      },
    );
  });

  group('LoginScreen Validation & Failure Safety Tests', () {
    testWidgets(
      'Empty credentials trigger SnackBar and stay on LoginScreen',
      (WidgetTester tester) async {
        final audioService = AudioPlayerService();

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audioService,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Login with empty fields
        final loginButton = find.widgetWithText(ElevatedButton, 'Login');
        expect(loginButton, findsOneWidget);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Must display error and NEVER grant access
        expect(
          find.text('Please enter your email and password'),
          findsOneWidget,
        );
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(MainShellScreen), findsNothing);
      },
    );

    testWidgets(
      'Invalid email format triggers validation error without routing to MainShellScreen',
      (WidgetTester tester) async {
        final audioService = AudioPlayerService();

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audioService,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter invalid email
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.first, 'invalid-email-address');
        await tester.enterText(textFields.last, 'password123');
        await tester.pump();

        final loginButton = find.widgetWithText(ElevatedButton, 'Login');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Verify validation error
        expect(
          find.text('Please enter a valid email address'),
          findsOneWidget,
        );
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(MainShellScreen), findsNothing);
      },
    );

    testWidgets(
      'Short password triggers validation error and remains on LoginScreen',
      (WidgetTester tester) async {
        final audioService = AudioPlayerService();

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audioService,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final textFields = find.byType(TextField);
        await tester.enterText(textFields.first, 'user@example.com');
        await tester.enterText(textFields.last, '123'); // < 6 chars
        await tester.pump();

        final loginButton = find.widgetWithText(ElevatedButton, 'Login');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        expect(
          find.text('Password must be at least 6 characters'),
          findsOneWidget,
        );
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(MainShellScreen), findsNothing);
      },
    );
  });

  group('SignupScreen Validation & Failure Safety Tests', () {
    testWidgets(
      'Password mismatch triggers error and stays on SignupScreen',
      (WidgetTester tester) async {
        final audioService = AudioPlayerService();

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audioService,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const SignupScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Locate textfields: Name, Email, Username, Password, Confirm Password
        final textFields = find.byType(TextField);
        expect(textFields, findsNWidgets(5));

        await tester.enterText(textFields.at(0), 'Sasuke Uchiha');
        await tester.enterText(textFields.at(1), 'sasuke@leaf.com');
        await tester.enterText(textFields.at(2), 'sasuke_u');
        await tester.enterText(textFields.at(3), 'chidori123');
        await tester.enterText(textFields.at(4), 'differentPassword');
        await tester.pump();

        final createAccountButton = find.widgetWithText(
          ElevatedButton,
          'Create Account',
        );
        expect(createAccountButton, findsOneWidget);
        await tester.tap(createAccountButton);
        await tester.pumpAndSettle();

        expect(find.text('Passwords do not match'), findsOneWidget);
        expect(find.byType(SignupScreen), findsOneWidget);
        expect(find.byType(MainShellScreen), findsNothing);
      },
    );

    testWidgets(
      'Short password on signup triggers error and stays on SignupScreen',
      (WidgetTester tester) async {
        final audioService = AudioPlayerService();

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audioService,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const SignupScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(0), 'Sasuke Uchiha');
        await tester.enterText(textFields.at(1), 'sasuke@leaf.com');
        await tester.enterText(textFields.at(2), 'sasuke_u');
        await tester.enterText(textFields.at(3), '123');
        await tester.enterText(textFields.at(4), '123');
        await tester.pump();

        final createAccountButton = find.widgetWithText(
          ElevatedButton,
          'Create Account',
        );
        await tester.tap(createAccountButton);
        await tester.pumpAndSettle();

        expect(
          find.text('Password must be at least 6 characters long'),
          findsOneWidget,
        );
        expect(find.byType(SignupScreen), findsOneWidget);
        expect(find.byType(MainShellScreen), findsNothing);
      },
    );
  });

  group('Sign-Out Flow Tests', () {
    testWidgets(
      'Calling logout on AudioPlayerService cleans up user and session',
      (WidgetTester tester) async {
        final audioService = AudioPlayerService();
        final fakeUser = FakeFirebaseUser(
          uid: 'uid_logout_test',
          email: 'logout@liveit.com',
          displayName: 'Logout User',
        );

        AuthService.instance.setMockUser(fakeUser);
        audioService.setUserName('Logout User');
        expect(audioService.userName, 'Logout User');
        expect(AuthService.instance.isAuthenticated, isTrue);

        await audioService.logout();

        // User session reset to empty and auth session cleared
        expect(audioService.userName, isEmpty);
        expect(AuthService.instance.currentUser, isNull);
      },
    );
  });
}
