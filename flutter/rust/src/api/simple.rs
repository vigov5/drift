#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    #[cfg(target_os = "android")]
    {
        use tracing_subscriber::prelude::*;
        let _ = tracing_subscriber::registry()
            .with(tracing_android::layer("drift").unwrap())
            .try_init();
    }
    #[cfg(not(target_os = "android"))]
    {
        use tracing_subscriber::EnvFilter;
        let filter = EnvFilter::try_from_default_env()
            .unwrap_or_else(|_| EnvFilter::new("drift_core=debug,drift_app=debug,warn"));
        let _ = tracing_subscriber::fmt().with_env_filter(filter).try_init();
    }
    // Ensures RUNTIME and static setup are touched when the Dart side initializes Rust.
}

#[flutter_rust_bridge::frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello, {name}")
}
