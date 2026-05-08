import 'package:app/features/receive/application/pairing_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<PairingCacheRepository> makeRepo() async {
    final prefs = await SharedPreferences.getInstance();
    return PairingCacheRepository(prefs: prefs);
  }

  test('returns null when nothing stored', () async {
    final repo = await makeRepo();
    final loaded = repo.loadIfFresh(
      identity: PairingCacheRepository.buildIdentity(
        deviceName: 'Maya',
        serverUrl: 'https://example',
      ),
    );
    expect(loaded, isNull);
  });

  test('save then load returns the stored code', () async {
    final repo = await makeRepo();
    final identity = PairingCacheRepository.buildIdentity(
      deviceName: 'Maya',
      serverUrl: 'https://example',
    );
    await repo.save(identity: identity, code: 'ABC123', expiresAt: null);
    final loaded = repo.loadIfFresh(identity: identity);
    expect(loaded, isNotNull);
    expect(loaded!.normalizedCode, 'ABC123');
    expect(loaded.isAvailable, isTrue);
  });

  test('returns null when identity differs', () async {
    final repo = await makeRepo();
    await repo.save(
      identity: PairingCacheRepository.buildIdentity(
        deviceName: 'Maya',
        serverUrl: 'https://example',
      ),
      code: 'ABC123',
    );
    final loaded = repo.loadIfFresh(
      identity: PairingCacheRepository.buildIdentity(
        deviceName: 'Bob',
        serverUrl: 'https://example',
      ),
    );
    expect(loaded, isNull);
  });

  test('returns null when expiresAt is in the past', () async {
    final repo = await makeRepo();
    final identity = PairingCacheRepository.buildIdentity(
      deviceName: 'Maya',
      serverUrl: 'https://example',
    );
    final pastIso = DateTime.now()
        .toUtc()
        .subtract(const Duration(minutes: 5))
        .toIso8601String();
    await repo.save(identity: identity, code: 'ABC123', expiresAt: pastIso);
    final loaded = repo.loadIfFresh(identity: identity);
    expect(loaded, isNull);
  });

  test('keeps loaded value when expiresAt is well in the future', () async {
    final repo = await makeRepo();
    final identity = PairingCacheRepository.buildIdentity(
      deviceName: 'Maya',
      serverUrl: 'https://example',
    );
    final futureIso = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 1))
        .toIso8601String();
    await repo.save(identity: identity, code: 'ABC123', expiresAt: futureIso);
    final loaded = repo.loadIfFresh(identity: identity);
    expect(loaded, isNotNull);
    expect(loaded!.normalizedCode, 'ABC123');
  });

  test('clear removes the cached entry', () async {
    final repo = await makeRepo();
    final identity = PairingCacheRepository.buildIdentity(
      deviceName: 'Maya',
      serverUrl: 'https://example',
    );
    await repo.save(identity: identity, code: 'ABC123');
    await repo.clear();
    expect(repo.loadIfFresh(identity: identity), isNull);
  });

  test('save with empty code clears the cache', () async {
    final repo = await makeRepo();
    final identity = PairingCacheRepository.buildIdentity(
      deviceName: 'Maya',
      serverUrl: 'https://example',
    );
    await repo.save(identity: identity, code: 'ABC123');
    await repo.save(identity: identity, code: '');
    expect(repo.loadIfFresh(identity: identity), isNull);
  });
}
