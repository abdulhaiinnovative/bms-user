import 'package:shared_preferences/shared_preferences.dart';

/// Utility class to manage onboarding preferences
/// Useful for testing and debugging
class OnboardingPreferences {
  static const String _keyHasSeenOnboarding = 'hasSeenOnboarding';

  /// Check if user has completed onboarding
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  /// Mark onboarding as completed
  static Future<bool> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyHasSeenOnboarding, true);
  }

  /// Reset onboarding (for testing purposes)
  /// Call this to show onboarding again
  static Future<bool> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_keyHasSeenOnboarding);
  }

  /// Clear all onboarding related preferences
  static Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
}
