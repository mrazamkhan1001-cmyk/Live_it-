/// Utility functions for user profile name and username resolution.
class UserUtils {
  /// Common name tokens that frequently appear fused without separators in emails.
  static const List<String> _commonSplitKeywords = [
    'khan',
    'kumar',
    'singh',
    'sharma',
    'patel',
    'gupta',
    'ali',
    'ahmed',
    'smith',
    'john',
    'azam',
  ];

  /// Derives a clean, capitalized human-readable name from an email address.
  ///
  /// Examples:
  /// - `azamkhan@gmail.com` -> `Azam Khan`
  /// - `mohd.azam@gmail.com` -> `Mohd Azam`
  /// - `azam_khan@gmail.com` -> `Azam Khan`
  /// - `azam123@gmail.com` -> `Azam`
  /// - `john-doe@example.com` -> `John Doe`
  static String deriveNameFromEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'User';
    }
    final trimmed = email.trim();
    final atIndex = trimmed.indexOf('@');
    var local = atIndex != -1 ? trimmed.substring(0, atIndex) : trimmed;
    local = local.trim();
    if (local.isEmpty) return 'User';

    // 1. Strip trailing numbers commonly appended for uniqueness (e.g. azam123 -> azam)
    // Keep numbers if local part contains no letters at all (e.g. 12345@domain.com)
    final strippedNumbers = local.replaceAll(RegExp(r'\d+$'), '');
    if (strippedNumbers.trim().isNotEmpty &&
        RegExp(r'[a-zA-Z]').hasMatch(strippedNumbers)) {
      local = strippedNumbers;
    }

    // 2. Separate camelCase boundaries (e.g. azamKhan -> azam Khan)
    local = local.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m[1]} ${m[2]}',
    );

    // 3. Convert common separators (. _ - +) into spaces
    local = local.replaceAll(RegExp(r'[._\-+]+'), ' ');

    // 4. Handle known fused name parts if no spaces are present yet (e.g. azamkhan -> azam khan)
    if (!local.contains(' ') && local.length >= 6) {
      final lower = local.toLowerCase();
      for (final kw in _commonSplitKeywords) {
        if (lower.endsWith(kw) && lower.length > kw.length + 2) {
          local =
              '${local.substring(0, local.length - kw.length)} ${local.substring(local.length - kw.length)}';
          break;
        } else if (lower.startsWith(kw) && lower.length > kw.length + 2) {
          local =
              '${local.substring(0, kw.length)} ${local.substring(kw.length)}';
          break;
        }
      }
    }

    // 5. Capitalize each word properly
    final parts =
        local.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'User';

    final capitalized = parts
        .map((part) {
          final clean = part.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
          if (clean.isEmpty) return '';
          if (clean.length == 1) return clean.toUpperCase();
          return clean[0].toUpperCase() + clean.substring(1).toLowerCase();
        })
        .where((p) => p.isNotEmpty)
        .join(' ');

    return capitalized.isNotEmpty ? capitalized : 'User';
  }

  /// Derives a clean username from an email local part.
  ///
  /// Examples:
  /// - `mohd.azam@gmail.com` -> `mohd_azam`
  /// - `azam_khan@gmail.com` -> `azam_khan`
  /// - `azam123@gmail.com` -> `azam123`
  static String deriveUsernameFromEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'user';
    }
    final trimmed = email.trim().toLowerCase();
    final atIndex = trimmed.indexOf('@');
    final local = atIndex != -1 ? trimmed.substring(0, atIndex) : trimmed;
    final cleaned = local
        .replaceAll(RegExp(r'[.\-+]+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return cleaned.isNotEmpty ? cleaned : 'user';
  }

  /// Resolves the effective display name for a user given their saved profile name,
  /// authenticated provider display name, and email address.
  ///
  /// Priority:
  /// 1. Explicitly saved display name (if not empty and not the legacy placeholder 'Azam Uchiha').
  /// 2. Authenticated provider's display name (if available, non-empty, and not a raw email).
  /// 3. Email-derived display name fallback.
  /// 4. 'User' default fallback.
  static String resolveDisplayName({
    String? savedName,
    String? authDisplayName,
    String? email,
  }) {
    if (savedName != null &&
        savedName.trim().isNotEmpty &&
        savedName.trim() != 'Azam Uchiha') {
      return savedName.trim();
    }

    if (authDisplayName != null &&
        authDisplayName.trim().isNotEmpty &&
        authDisplayName.trim() != 'Azam Uchiha' &&
        !authDisplayName.contains('@')) {
      return authDisplayName.trim();
    }

    if (email != null && email.trim().isNotEmpty) {
      return deriveNameFromEmail(email);
    }

    return 'User';
  }

  /// Resolves the effective username for a user.
  ///
  /// Priority:
  /// 1. Explicitly saved username (if not empty and not the legacy placeholder 'azam_uchiha').
  /// 2. Email-derived username.
  /// 3. 'user' default fallback.
  static String resolveUsername({
    String? savedUsername,
    String? email,
  }) {
    if (savedUsername != null &&
        savedUsername.trim().isNotEmpty &&
        savedUsername.trim() != 'azam_uchiha' &&
        savedUsername.trim() != 'Azam Uchiha') {
      var u = savedUsername.trim();
      if (u.startsWith('@')) u = u.substring(1);
      return u;
    }

    if (email != null && email.trim().isNotEmpty) {
      return deriveUsernameFromEmail(email);
    }

    return 'user';
  }
}
