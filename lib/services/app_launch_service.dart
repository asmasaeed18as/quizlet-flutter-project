import 'package:shared_preferences/shared_preferences.dart';

class AppLaunchService {
  AppLaunchService._();

  static const _onboardingSeenKey = 'onboarding_seen';

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSeenKey) ?? false;
  }

  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
  }
}
