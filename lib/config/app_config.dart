abstract final class AppConfig {
  static const _customApiUrl = String.fromEnvironment('HITHA_API_URL');

  /// Dynamic API Base URL:
  /// - Uses `--dart-define=HITHA_API_URL=...` if provided.
  /// - Defaults directly to the deployed live production backend: `https://api.hitha.lk/api/v1`.
  static String get apiBaseUrl {
    if (_customApiUrl.isNotEmpty) return _customApiUrl;
    return 'https://api.hitha.lk/api/v1';
  }

  /// When true, auth/booking/wallet fall back to local simulation if the API
  /// is unreachable or offline. Accepts any 6-digit OTP offline.
  static const demoMode = bool.fromEnvironment('HITHA_DEMO', defaultValue: false);

  static const crisisHotline = '1926';
  static const livekitUrl = 'wss://livekit.hitha.lk';
}
