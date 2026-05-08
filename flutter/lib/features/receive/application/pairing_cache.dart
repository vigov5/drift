import 'package:shared_preferences/shared_preferences.dart';

import 'state.dart';

const String _codeKey = 'receiver.pairing.code';
const String _expiresAtKey = 'receiver.pairing.expires_at';
const String _identityKey = 'receiver.pairing.identity';

/// Lightweight wrapper around `shared_preferences` for persisting the most
/// recent successful rendezvous registration. Used to seed the receiver UI
/// optimistically on cold start so the user sees a Ready code immediately
/// rather than "Unavailable" while the network roundtrip happens.
class PairingCacheRepository {
  PairingCacheRepository({required this.prefs});

  final SharedPreferences prefs;

  /// Returns the cached pairing code if it matches the supplied identity (so
  /// we never seed UI with stale codes from a different device or server) and
  /// has not yet expired. Returns `null` otherwise.
  PairingCodeState? loadIfFresh({required String identity}) {
    final storedIdentity = prefs.getString(_identityKey);
    if (storedIdentity != identity) return null;
    final code = prefs.getString(_codeKey);
    if (code == null || code.isEmpty) return null;
    final expiresAt = prefs.getString(_expiresAtKey);
    if (_isExpired(expiresAt)) return null;
    return PairingCodeState.active(code: code, expiresAt: expiresAt);
  }

  Future<void> save({
    required String identity,
    required String code,
    String? expiresAt,
  }) async {
    if (code.isEmpty) {
      await clear();
      return;
    }
    await prefs.setString(_identityKey, identity);
    await prefs.setString(_codeKey, code);
    if (expiresAt == null || expiresAt.isEmpty) {
      await prefs.remove(_expiresAtKey);
    } else {
      await prefs.setString(_expiresAtKey, expiresAt);
    }
  }

  Future<void> clear() async {
    await prefs.remove(_identityKey);
    await prefs.remove(_codeKey);
    await prefs.remove(_expiresAtKey);
  }

  /// Builds an opaque identity string that scopes the cache to a specific
  /// (deviceName, serverUrl) pair. Changing identity invalidates the cache.
  static String buildIdentity({
    required String deviceName,
    required String? serverUrl,
  }) {
    return '${deviceName.trim()}|${(serverUrl ?? '').trim()}';
  }

  bool _isExpired(String? expiresAt) {
    if (expiresAt == null || expiresAt.isEmpty) return false;
    final parsed = DateTime.tryParse(expiresAt);
    if (parsed == null) return false;
    // Consider the cache stale 30s before the server-stated expiry so we
    // don't ship a near-dead code to the UI.
    return DateTime.now().toUtc().isAfter(
      parsed.toUtc().subtract(const Duration(seconds: 30)),
    );
  }
}
