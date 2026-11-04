/// Smart Gear Firebase Configuration
/// Project: smart-gear-bef4a
class FirebaseConfig {
  // ─── Web App Config (smart gear web) ────────────────────────────────────────
  static const String apiKey = 'AIzaSyDnR_C0oqTwr0zulIDWr3MOHkPL4p1rI6Q';
  static const String authDomain = 'smart-gear-bef4a.firebaseapp.com';
  static const String projectId = 'smart-gear-bef4a';
  static const String storageBucket = 'smart-gear-bef4a.firebasestorage.app';
  static const String messagingSenderId = '1037760086655';
  static const String appId = '1:1037760086655:web:7b8fbca8b7d987e455354a';
  static const String measurementId = 'G-3LKPCNGMMQ';

  // ─── Android App Config ──────────────────────────────────────────────────────
  static const String androidApiKey = 'AIzaSyBGNllC_mmTZBK4puSIHEuGUAj7ZIks3vg';
  static const String androidAppId = '1:1037760086655:android:c2dedc9feecd17e855354a';

  /// Always configured with real credentials
  static bool get isConfigured => apiKey.isNotEmpty;

  /// Gemini API Key (loaded via --dart-define=GEMINI_API_KEY=... or set at runtime)
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  static const String geminiModel = 'gemini-3.5-flash-lite';
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
}
