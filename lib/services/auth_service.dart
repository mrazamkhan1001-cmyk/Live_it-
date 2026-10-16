import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import 'firestore_service.dart';

/// Firebase Authentication service for LIVE IT BY AZAM.
/// Supports Email/Password authentication, Google Sign-In, session persistence,
/// and deliberate profile-sync failure tracking across Web and Mobile platforms.
class AuthService {
  static final AuthService instance = AuthService._internal();

  AuthService._internal() {
    if (!kIsWeb) {
      try {
        GoogleSignIn.instance.initialize().catchError((e) {
          debugPrint('GoogleSignIn.initialize notice: $e');
        });
      } catch (e) {
        debugPrint('GoogleSignIn.initialize notice: $e');
      }
    }
  }

  FirebaseAuth? _customAuth;

  /// Visible for testing to inject custom FirebaseAuth instance
  void setCustomAuth(FirebaseAuth? auth) {
    _customAuth = auth;
  }

  /// Lazily retrieves FirebaseAuth instance or returns null if uninitialized
  FirebaseAuth? get authOrNull {
    try {
      return _customAuth ?? FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  // Mock user support for deterministic unit & widget testing
  User? _mockUser;
  bool _useMock = false;

  /// Tracks the most recent Firestore profile synchronization error, if any
  String? _lastProfileSyncError;
  String? get lastProfileSyncError => _lastProfileSyncError;

  /// Injects a mock user for testing auth gate routing
  void setMockUser(User? user) {
    _mockUser = user;
    _useMock = true;
  }

  /// Clears mock user state
  void clearMockUser() {
    _mockUser = null;
    _useMock = false;
  }

  /// Stream listening to authentication state changes
  Stream<User?> get authStateChanges {
    final auth = authOrNull;
    if (auth != null) {
      return auth.authStateChanges();
    }
    return Stream<User?>.value(_mockUser);
  }

  /// Currently logged in user, or null if unauthenticated
  User? get currentUser {
    if (_useMock) return _mockUser;
    try {
      return authOrNull?.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Whether a user session is active
  bool get isAuthenticated => currentUser != null;

  /// Sign in with Email and Password.
  /// Throws [FirebaseAuthException] or [Exception] on invalid credentials or failure.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    _lastProfileSyncError = null;
    final auth = authOrNull;
    if (auth == null) {
      throw FirebaseAuthException(
        code: 'no-app',
        message: 'Firebase has not been initialized. Please ensure config files are installed.',
      );
    }

    final cred = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (cred.user != null) {
      await _syncProfileDeliberately(cred.user!);
    }
    return cred;
  }

  /// Register new user with Email, Password, and Display Name.
  /// Throws [FirebaseAuthException] or [Exception] on registration failure.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? username,
  }) async {
    _lastProfileSyncError = null;
    final auth = authOrNull;
    if (auth == null) {
      throw FirebaseAuthException(
        code: 'no-app',
        message: 'Firebase has not been initialized. Please ensure config files are installed.',
      );
    }

    final cred = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (cred.user != null) {
      try {
        await cred.user!.updateDisplayName(displayName.trim());
      } catch (e) {
        debugPrint('Could not update display name: $e');
      }

      await _createProfileDeliberately(
        user: cred.user!,
        username: username,
      );
    }
    return cred;
  }

  /// Google Sign-In with Web Popup / Mobile native flow.
  /// Returns [UserCredential] on success, or `null` if user intentionally cancelled.
  /// Throws [Exception] or [FirebaseAuthException] on provider or configuration failures.
  Future<UserCredential?> signInWithGoogle() async {
    _lastProfileSyncError = null;
    final auth = authOrNull;
    if (auth == null) {
      throw FirebaseAuthException(
        code: 'no-app',
        message: 'Firebase has not been initialized. Please ensure config files are installed.',
      );
    }

    if (kIsWeb) {
      try {
        final GoogleAuthProvider authProvider = GoogleAuthProvider();
        final cred = await auth.signInWithPopup(authProvider);
        if (cred.user != null) {
          await _syncProfileDeliberately(cred.user!);
        }
        return cred;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'popup-closed-by-user' ||
            e.code == 'cancelled-popup-request') {
          debugPrint('Google Sign-In cancelled by user.');
          return null;
        }
        rethrow;
      }
    } else {
      try {
        final GoogleSignInAccount googleUser =
            await GoogleSignIn.instance.authenticate();

        final GoogleSignInAuthentication googleAuth =
            googleUser.authentication;

        final idToken = googleAuth.idToken;
        if (idToken == null || idToken.isEmpty) {
          throw FirebaseAuthException(
            code: 'missing-id-token',
            message:
                'Google authentication did not return an idToken. Ensure SHA-1 fingerprint and OAuth clients are registered in Firebase Console.',
          );
        }

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: idToken,
        );

        final cred = await auth.signInWithCredential(credential);
        if (cred.user != null) {
          await _syncProfileDeliberately(cred.user!);
        }
        return cred;
      } catch (e) {
        final errorString = e.toString().toLowerCase();
        // Check for user cancellation in native platform exceptions
        if (errorString.contains('canceled') ||
            errorString.contains('cancelled') ||
            errorString.contains('sign_in_canceled')) {
          debugPrint('Google Sign-In cancelled by user.');
          return null;
        }
        rethrow;
      }
    }
  }

  /// Internal helper to sync user profile and deliberately record sync failures
  Future<void> _syncProfileDeliberately(User user) async {
    try {
      await FirestoreService.instance.syncUserProfile(user);
    } catch (e) {
      _lastProfileSyncError = 'Profile sync failure: $e';
      debugPrint(_lastProfileSyncError);
      // We do not rethrow here to prevent aborting a valid auth session,
      // but the error is recorded deliberately in lastProfileSyncError.
    }
  }

  /// Internal helper to create user profile and deliberately record sync failures
  Future<void> _createProfileDeliberately({
    required User user,
    String? username,
  }) async {
    try {
      await FirestoreService.instance.createUserProfile(
        user: user,
        username: username,
      );
    } catch (e) {
      _lastProfileSyncError = 'Profile creation failure: $e';
      debugPrint(_lastProfileSyncError);
    }
  }

  /// Sign out current user from Firebase and Google (on mobile)
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (e) {
      debugPrint('Google signOut notice: $e');
    }
    try {
      await authOrNull?.signOut();
    } catch (e) {
      debugPrint('FirebaseAuth signOut notice: $e');
    }
    clearMockUser();
  }
}
