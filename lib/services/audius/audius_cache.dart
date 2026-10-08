/// In-memory cache entry with TTL expiration tracking
class _CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  _CacheEntry({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Lightweight In-Memory TTL Cache for Audius Data Layer
class AudiusCache {
  final Map<String, _CacheEntry<dynamic>> _store = {};

  static const Duration defaultTrendingTtl = Duration(minutes: 10);
  static const Duration defaultSearchTtl = Duration(minutes: 5);
  static const Duration defaultDetailsTtl = Duration(minutes: 30);

  /// Retrieve cached value if present and unexpired
  T? get<T>(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _store.remove(key);
      return null;
    }
    return entry.data as T?;
  }

  /// Store value with custom or default TTL
  void set<T>(
    String key,
    T value, {
    Duration ttl = const Duration(minutes: 10),
  }) {
    _store[key] = _CacheEntry<T>(
      data: value,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  /// Invalidate a specific cache key
  void invalidate(String key) {
    _store.remove(key);
  }

  /// Clear all cache entries
  void clear() {
    _store.clear();
  }

  /// Number of active cache entries (including potentially expired ones)
  int get count => _store.length;
}
