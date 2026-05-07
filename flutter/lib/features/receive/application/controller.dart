import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../settings/feature.dart';
import 'service.dart';
import 'state.dart';

part 'controller.g.dart';

@riverpod
ReceiverIdleViewState receiverIdleViewState(Ref ref) {
  final service = ref.watch(receiverServiceProvider);
  final snapshot = service.snapshot;
  final pairingCode = service.pairingCode;

  // Advertising is active when the receiver is ready AND the user has
  // discoverableByDefault enabled. This avoids timing issues with the
  // route-based advertisingActiveProvider.
  final discoverableByDefault = ref
      .watch(settingsControllerProvider)
      .settings
      .discoverableByDefault;
  final advertisingActive =
      discoverableByDefault && snapshot.lifecycle == ReceiverLifecycle.ready;

  final badge = switch (snapshot.lifecycle) {
    ReceiverLifecycle.starting => const ReceiverBadgeState.registering(),
    ReceiverLifecycle.ready =>
      pairingCode.isAvailable
          ? const ReceiverBadgeState.ready()
          : const ReceiverBadgeState.unavailable(),
    ReceiverLifecycle.stopped => const ReceiverBadgeState.unavailable(),
    ReceiverLifecycle.failed => const ReceiverBadgeState.unavailable(),
  };

  final code = pairingCode.isAvailable ? pairingCode.formattedCode : '......';
  final deviceName = ref.watch(settingsControllerProvider).settings.deviceName;

  return ReceiverIdleViewState(
    deviceName: deviceName,
    badge: badge,
    status: badge.label,
    code: code,
    clipboardCode: pairingCode.clipboardCode,
    lifecycle: snapshot.lifecycle,
    advertisingActive: advertisingActive,
  );
}
