import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/song.dart';

/// Service managing Cloud Firestore persistence for LIVE IT BY AZAM.
/// Handles user profile records, favorites, and playlists.
/// Sync errors are deliberately reported and propagated rather than silently swallowed.
class FirestoreService {
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();

  FirebaseFirestore? _customDb;

  void setCustomDb(FirebaseFirestore? db) {
    _customDb = db;
  }

  FirebaseFirestore? get dbOrNull {
    try {
      return _customDb ?? FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference? get _usersRef => dbOrNull?.collection('users');

  /// Create a new user profile document in /users/{uid}
  /// Throws on failure so callers can handle or report sync issues deliberately.
  Future<void> createUserProfile({
    required User user,
    String? username,
  }) async {
    final ref = _usersRef;
    if (ref == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Firestore is not initialized. Check Firebase options configuration.',
      );
    }
    try {
      final doc = ref.doc(user.uid);
      await doc.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'username': username ?? user.email?.split('@').first ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreService.createUserProfile error: $e');
      rethrow;
    }
  }

  /// Sync/update profile for existing user.
  /// Throws on failure so callers can handle or report sync issues deliberately.
  Future<void> syncUserProfile(User user) async {
    final ref = _usersRef;
    if (ref == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Firestore is not initialized. Check Firebase options configuration.',
      );
    }
    try {
      final doc = ref.doc(user.uid);
      await doc.set({
        'uid': user.uid,
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        if (user.photoURL != null && user.photoURL!.isNotEmpty)
          'photoUrl': user.photoURL!,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreService.syncUserProfile error: $e');
      rethrow;
    }
  }

  /// Update user profile in Firestore (/users/{uid})
  /// Sets uid explicitly to guarantee compliance with Firestore security rule request.resource.data.uid == userId.
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? username,
    String? bio,
    String? photoUrl,
  }) async {
    final ref = _usersRef;
    if (ref == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Firestore is not initialized.',
      );
    }
    try {
      final doc = ref.doc(uid);
      final data = <String, dynamic>{
        'uid': uid,
        if (displayName != null) 'displayName': displayName,
        if (username != null) 'username': username,
        if (bio != null) 'bio': bio,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await doc.set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreService.updateUserProfile error: $e');
      rethrow;
    }
  }

  /// Retrieve stored profile document from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final ref = _usersRef;
    if (ref == null) return null;
    try {
      final doc = await ref.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('FirestoreService.getUserProfile error: $e');
      return null;
    }
  }

  /// Real-time stream of user profile
  Stream<DocumentSnapshot>? streamUserProfile(String uid) {
    return _usersRef?.doc(uid).snapshots();
  }

  CollectionReference? _favoritesRef(String uid) =>
      _usersRef?.doc(uid).collection('favorites');

  /// Add a song to user's favorites in Firestore
  Future<void> saveFavorite(String uid, Song song) async {
    final ref = _favoritesRef(uid);
    if (ref == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Firestore is not initialized.',
      );
    }
    try {
      await ref.doc(song.id).set({
        'id': song.id,
        'title': song.title,
        'artist': song.artist,
        'album': song.album,
        'artworkUrl': song.artworkUrl,
        'streamUrl': song.streamUrl,
        'durationMs': song.durationMs,
        'likedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('FirestoreService.saveFavorite error: $e');
      rethrow;
    }
  }

  /// Remove a song from user's favorites in Firestore
  Future<void> removeFavorite(String uid, String songId) async {
    final ref = _favoritesRef(uid);
    if (ref == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Firestore is not initialized.',
      );
    }
    try {
      await ref.doc(songId).delete();
    } catch (e) {
      debugPrint('FirestoreService.removeFavorite error: $e');
      rethrow;
    }
  }

  /// Real-time stream of user favorites
  Stream<List<Song>> streamFavorites(String uid) {
    final ref = _favoritesRef(uid);
    if (ref == null) {
      return const Stream.empty();
    }
    return ref
        .orderBy('likedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Song(
          id: data['id'] as String? ?? doc.id,
          title: data['title'] as String? ?? '',
          artist: data['artist'] as String? ?? '',
          album: data['album'] as String? ?? '',
          artworkUrl: data['artworkUrl'] as String? ?? '',
          streamUrl: data['streamUrl'] as String? ?? '',
          durationMs: data['durationMs'] as int? ?? 0,
        );
      }).toList();
    });
  }
}
