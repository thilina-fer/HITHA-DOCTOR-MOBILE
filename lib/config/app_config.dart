import 'dart:io';
import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const _customApiUrl = String.fromEnvironment('HITHA_API_URL');

  /// Dynamic API Base URL:
  /// - Uses `--dart-define=HITHA_API_URL=...` if provided.
  /// - In release builds, defaults to production backend: `https://api.hitha.lk/api/v1`.
  /// - Automatically routes to `http://10.0.2.2:8081/api/v1` on Android emulator in debug mode.
  /// - Defaults to `http://localhost:8081/api/v1` on desktop, iOS, and web in debug mode.
  static String get apiBaseUrl {
    if (_customApiUrl.isNotEmpty) return _customApiUrl;
    if (kReleaseMode) {
      return 'https://api.hitha.lk/api/v1';
    }
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8081/api/v1';
    }
    return 'http://localhost:8081/api/v1';
  }

  /// When true, auth/booking/wallet fall back to local simulation if the API
  /// is unreachable or offline. Accepts any 6-digit OTP offline.
  static const demoMode = bool.fromEnvironment('HITHA_DEMO', defaultValue: false);

  static const crisisHotline = '1926';
  static const livekitUrl = 'wss://livekit.hitha.lk';
}
