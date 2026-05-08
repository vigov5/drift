use std::time::Duration;

use iroh::endpoint::QuicTransportConfig;

/// Tuned QUIC transport config for Android-friendly keepalive behaviour.
///
/// - `default_path_max_idle_timeout = 60s` gives ~2x the default tolerance for
///   CPU jitter when an Android Foreground Service is throttled by Doze.
/// - `default_path_keep_alive_interval = 15s` keeps NAT mappings warm in
///   middle-boxes whose UDP-binding TTL is typically 30-60s.
///
/// Backwards-compatible: QUIC negotiates the minimum of the two peers'
/// idle timeouts, so a tuned client still works with a default-config peer.
pub(crate) fn build_transport_config() -> QuicTransportConfig {
    QuicTransportConfig::builder()
        .default_path_max_idle_timeout(Duration::from_secs(60))
        .default_path_keep_alive_interval(Duration::from_secs(15))
        .build()
}

#[cfg(test)]
mod tests {
    use super::build_transport_config;

    #[test]
    fn build_transport_config_runs_without_panic() {
        // Smoke test: the builder accepts the chosen Durations and produces a
        // value. We can't easily assert internal state because iroh doesn't
        // expose getters on QuicTransportConfig — but a compile-and-run check
        // is enough to guard against API drift on iroh upgrades.
        let _ = build_transport_config();
    }
}
