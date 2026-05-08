import 'package:flutter/widgets.dart';

import 'transfer_keepalive_channel.dart';

/// Safety-net observer that ensures the foreground keepalive service is
/// stopped when the app is paused with no active transfer. Per-transfer
/// start/stop is handled in the controllers; this observer only cleans up
/// orphan services if a code path forgets to call `stop`.
class KeepaliveLifecycleObserver with WidgetsBindingObserver {
  KeepaliveLifecycleObserver({required this.hasActiveTransfer});

  /// Returns true when any active sender or receiver transfer is in flight.
  /// The observer queries this on every lifecycle state change.
  final bool Function() hasActiveTransfer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.paused) return;
    if (!hasActiveTransfer()) {
      TransferKeepalive.stop().ignore();
    }
  }
}
